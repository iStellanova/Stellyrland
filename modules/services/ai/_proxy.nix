{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;
  proxyPort = cfg.letta.port + 1;

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

                # Emit role chunk first
                self.wfile.write(make_chunk(cid, name))
                self.wfile.flush()

                # Emit each assistant_message as content chunks
                msgs = resp.get("messages", [])
                for m in msgs:
                    if m.get("message_type") == "assistant_message":
                        content = m.get("content") or ""
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
      };
    };
  };
}
