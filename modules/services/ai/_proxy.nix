{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;
  proxyPort = cfg.letta.port + 1;
  thinkProxyPort = cfg.litellm.port + 1;

  # Routes Letta's LLM calls directly to Ollama (bypassing LiteLLM which strips think:false)
  # and injects think:false so qwen3 doesn't enter thinking mode.
  # Chat completions → Ollama directly (with model alias mapping + think:false)
  # Embeddings/models → LiteLLM (unchanged)
  thinkInjectorScript = pkgs.writeText "think-injector.py" ''
    import json, os, uuid
    from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
    import httpx

    OLLAMA      = os.environ["OLLAMA_UPSTREAM"]   # http://127.0.0.1:11434/v1
    LITELLM     = os.environ["LITELLM_UPSTREAM"]  # http://127.0.0.1:4000
    DRAFT_MODEL = os.environ.get("DRAFT_MODEL", "")  # draft model for speculative decoding
    # Model alias → actual Ollama model name
    MODELS      = json.loads(os.environ["MODEL_MAP"])

    def is_chat(path: str) -> bool:
        return "chat/completions" in path

    def wrap_as_send_message(resp_json: dict) -> dict:
        """If the model returned text instead of a tool call, convert to send_message.
        Letta requires all responses to go through tool calls — this bridges the gap
        when qwen3 sends a plain text reply after processing tool results."""
        choices = resp_json.get("choices", [])
        if not choices:
            return resp_json
        msg = choices[0].get("message", {})
        if msg.get("tool_calls"):
            return resp_json  # already has tool calls, pass through
        content = msg.get("content") or ""
        if not content.strip():
            return resp_json  # empty content, pass through as-is
        # Convert text response to send_message tool call
        msg["tool_calls"] = [{
            "id": f"call_{uuid.uuid4().hex[:8]}",
            "type": "function",
            "function": {
                "name": "send_message",
                "arguments": json.dumps({"message": content.strip()}),
            },
        }]
        msg["content"] = None
        choices[0]["finish_reason"] = "tool_calls"
        print(f"[think-injector] wrapped text→send_message: {content[:60]!r}", flush=True)
        return resp_json

    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(n))

            if is_chat(self.path):
                # Map alias → real model name, inject think:false, send direct to Ollama
                alias = body.get("model", "")
                body["model"] = MODELS.get(alias, alias)
                body["think"] = False
                # Speculative decoding: face uses a smaller draft model (same tokenizer family)
                # for 2-3x throughput. Ollama silently ignores this if not supported.
                if alias == "face" and DRAFT_MODEL:
                    body["speculative"] = DRAFT_MODEL
                upstream = f"{OLLAMA}/chat/completions"
            else:
                # Embeddings and other endpoints go through LiteLLM unchanged
                upstream = f"{LITELLM}{self.path}"

            data = json.dumps(body).encode()
            streaming = body.get("stream", False)
            with httpx.Client(timeout=300) as c:
                if streaming:
                    with c.stream("POST", upstream, content=data,
                                  headers={"Content-Type": "application/json"}) as r:
                        self.send_response(r.status_code)
                        for k, v in r.headers.items():
                            if k.lower() not in ("transfer-encoding", "connection", "content-length"):
                                self.send_header(k, v)
                        self.end_headers()
                        for chunk in r.iter_raw():
                            self.wfile.write(chunk)
                            self.wfile.flush()
                else:
                    r = c.post(upstream, content=data,
                               headers={"Content-Type": "application/json"})
                    if is_chat(self.path) and r.status_code == 200:
                        resp_json = wrap_as_send_message(r.json())
                        resp = json.dumps(resp_json).encode()
                    else:
                        resp = r.content
                    self.send_response(r.status_code)
                    for k, v in r.headers.items():
                        if k.lower() not in ("transfer-encoding", "connection", "content-length"):
                            self.send_header(k, v)
                    self.send_header("Content-Length", str(len(resp)))
                    self.end_headers()
                    self.wfile.write(resp)

        def do_GET(self):
            # /v1/models etc. — serve from LiteLLM so aliases are visible
            r = httpx.get(f"{LITELLM}{self.path}", timeout=10)
            data = r.content
            self.send_response(r.status_code)
            self.send_header("Content-Type", r.headers.get("content-type", "application/json"))
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def log_message(self, fmt, *args):
            pass

    port = int(os.environ["PROXY_PORT"])
    print(f"think-injector on 127.0.0.1:{port} → Ollama:{OLLAMA} / LiteLLM:{LITELLM}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
  '';

  # Proxy: translates OpenAI chat/completions requests to Letta's native
  # /v1/agents/{id}/messages/ API, then re-emits as OpenAI SSE.
  # Letta's /v1/chat/completions stub only returns content:null — unusable.
  proxyScript = pkgs.writeText "letta-proxy.py" ''
    import json, os, time, uuid
    from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
    import httpx

    LETTA = os.environ["LETTA_UPSTREAM"]
    _cache: dict[str, str] = {}

    def agent_id(name: str) -> str:
        if name.startswith("agent-"):
            return name
        if name not in _cache:
            try:
                r = httpx.get(f"{LETTA}/v1/agents/", params={"name": name}, timeout=10)
                agents = r.json()
                if agents:
                    _cache[name] = agents[0]["id"]
            except Exception:
                pass
        return _cache.get(name, name)

    def sse(obj: dict) -> bytes:
        return (f"data: {json.dumps(obj)}\n\n").encode()

    def make_chunk(cid: str, model: str, content: str | None = None, finish: str | None = None) -> bytes:
        delta = {"content": content} if content is not None else {}
        if finish is None and content is None:
            delta["role"] = "assistant"
        return sse({
            "id": cid, "object": "chat.completion.chunk",
            "created": int(time.time()), "model": model,
            "choices": [{"index": 0, "delta": delta, "finish_reason": finish}],
        })

    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(n))
            name = body.get("model", "")
            aid = agent_id(name)

            # Extract last user message to send to Letta
            messages = body.get("messages", [])
            user_text = next(
                (m["content"] for m in reversed(messages) if m.get("role") == "user"),
                ""
            )

            cid = f"chatcmpl-{uuid.uuid4().hex[:16]}"
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.end_headers()

            try:
                r = httpx.post(
                    f"{LETTA}/v1/agents/{aid}/messages",
                    json={"messages": [{"role": "user", "content": user_text}]},
                    timeout=300,
                )
                resp = r.json()

                # Collect content from assistant messages and send_message tool calls.
                # Letta may use either form depending on agent state:
                #   • assistant_message — direct text reply (simple exchanges)
                #   • tool_call_message with send_message — after multi-step tool loops
                msgs = resp.get("messages", []) if isinstance(resp, dict) else []
                content_parts = []
                for m in msgs:
                    mtype = m.get("message_type", "")
                    if mtype == "assistant_message":
                        c = m.get("content", "").strip()
                        if c:
                            content_parts.append(c)
                    elif mtype in ("tool_call_message", "tool_call"):
                        for tc in m.get("tool_calls", []):
                            fn = tc.get("function", {})
                            if fn.get("name") == "send_message":
                                try:
                                    args = json.loads(fn.get("arguments", "{}"))
                                    msg = args.get("message", "").strip()
                                    if msg:
                                        content_parts.append(msg)
                                except (json.JSONDecodeError, AttributeError):
                                    pass

                if not content_parts:
                    types = [m.get("message_type") for m in msgs]
                    keys = list(resp.keys()) if isinstance(resp, dict) else type(resp).__name__
                    detail = resp.get("detail", "") if isinstance(resp, dict) else ""
                    print(
                        f"[proxy] no content from {aid}: status={r.status_code}"
                        f" keys={keys} msg_types={types}"
                        + (f" detail={detail!r}" if detail else ""),
                        flush=True,
                    )
                    content_parts = ["(no response)"]

                # Emit role chunk then content
                self.wfile.write(make_chunk(cid, name))
                self.wfile.flush()
                for content in content_parts:
                    self.wfile.write(make_chunk(cid, name, content=content))
                    self.wfile.flush()

                # Finish
                self.wfile.write(make_chunk(cid, name, finish="stop"))
                self.wfile.write(b"data: [DONE]\n\n")
                self.wfile.flush()
            except Exception as e:
                err = sse({"error": {"message": str(e), "type": "proxy_error"}})
                self.wfile.write(err)
                self.wfile.flush()

        def do_GET(self):
            try:
                r = httpx.get(f"{LETTA}{self.path}", timeout=10)
                data = r.content
                self.send_response(r.status_code)
                self.send_header("Content-Type", r.headers.get("content-type", "application/json"))
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            except Exception:
                self.send_response(502)
                self.end_headers()

        def log_message(self, fmt, *args):
            pass

    port = int(os.environ["PROXY_PORT"])
    print(f"Letta proxy listening on 127.0.0.1:{port} → {LETTA}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
  '';
in {
  config = lib.mkIf cfg.letta.enable {
    # Routes Letta's LLM chat calls directly to Ollama with think:false injected,
    # bypassing LiteLLM which strips non-standard parameters.
    systemd.services.litellm-think-injector = {
      description = "Letta LLM Router (think:false injector)";
      after = ["litellm.service" "ollama.service"];
      requires = ["litellm.service" "ollama.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      environment = {
        OLLAMA_UPSTREAM = "http://127.0.0.1:11434/v1";
        LITELLM_UPSTREAM = "http://127.0.0.1:${toString cfg.litellm.port}";
        PROXY_PORT = toString thinkProxyPort;
        DRAFT_MODEL = cfg.models.draft;
        MODEL_MAP = builtins.toJSON {
          face = cfg.models.face;
          core = cfg.models.core;
          code = cfg.models.code;
        };
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = "${pkgs.letta}/bin/python3.11 ${thinkInjectorScript}";
        Restart = "on-failure";
        RestartSec = "3s";
        NoNewPrivileges = true;
      };
    };

    systemd.services.letta-proxy = {
      description = "Letta Agent Name Proxy";
      after = ["letta.service" "letta-agent-init.service"];
      requires = ["letta.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      environment = {
        LETTA_UPSTREAM = "http://127.0.0.1:${toString cfg.letta.port}";
        PROXY_PORT = toString proxyPort;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = "${pkgs.letta}/bin/python3.11 ${proxyScript}";
        Restart = "on-failure";
        RestartSec = "3s";
        NoNewPrivileges = true;
        StandardOutput = "append:/tmp/letta-proxy.log";
        StandardError = "append:/tmp/letta-proxy.log";
      };
    };
  };
}
