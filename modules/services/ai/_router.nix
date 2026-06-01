{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;
  routerPort = cfg.router.port;
  proxyPort = cfg.letta.port + 1;

  routerScript = pkgs.writeText "letta-router.py" ''
    import json, os, re
    from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
    import httpx

    PROXY  = os.environ["PROXY_UPSTREAM"]
    OLLAMA = os.environ["OLLAMA_UPSTREAM"]
    DRAFT  = os.environ["CLASSIFIER_MODEL"]
    PORT   = int(os.environ["ROUTER_PORT"])

    PREFIX_MAP = {"@echo": "echo", "@coder": "coder", "@core": "core"}
    VALID      = {"echo", "coder", "core"}

    SYSTEM = (
        "Classify the user message. Reply with exactly one word — no punctuation, no explanation:\n"
        "  echo   — conversation, memory recall, general questions, opinions\n"
        "  coder  — code, scripts, configs, NixOS, technical files, implementations\n"
        "  core   — complex reasoning, architecture decisions, analysis, hard trade-offs"
    )

    def llm_classify(messages: list) -> str:
        recent = messages[-3:]
        lines  = []
        for m in recent:
            role    = m.get("role") or ""
            content = (m.get("content") or "").strip()
            if content:
                lines.append(f"{role}: {content}")
        try:
            r = httpx.post(
                f"{OLLAMA}/api/generate",
                json={
                    "model":       DRAFT,
                    "system":      SYSTEM,
                    "prompt":      "\n".join(lines),
                    "think":       False,
                    "stream":      False,
                    "temperature": 0,
                    "num_predict": 3,
                },
                timeout=10,
            )
            raw  = r.json().get("response", "").strip().lower()
            word = re.sub(r"[^a-z]", "", raw.split()[0]) if raw.split() else ""
            if word in VALID:
                print(f"[router] classified → {word}", flush=True)
                return word
            print(f"[router] unexpected output {raw!r} → echo", flush=True)
        except Exception as e:
            print(f"[router] classifier error: {e} → echo", flush=True)
        return "echo"

    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            n    = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(n))
            msgs = body.get("messages", [])

            agent     = "echo"
            user_msgs = [m for m in msgs
                         if m.get("role") == "user" and isinstance(m.get("content"), str)]
            if user_msgs:
                last    = user_msgs[-1]
                content = last["content"].strip()
                low     = content.lower()
                matched = next((p for p in PREFIX_MAP
                                if low.startswith(p + " ") or low == p), None)
                if matched:
                    agent           = PREFIX_MAP[matched]
                    last["content"] = content[len(matched):].strip()
                    print(f"[router] prefix {matched} → {agent}", flush=True)
                else:
                    agent = llm_classify(msgs)

            body["model"] = agent
            data      = json.dumps(body).encode()
            streaming = body.get("stream", False)
            target    = f"{PROXY}/v1/chat/completions"

            with httpx.Client(timeout=300) as c:
                if streaming:
                    with c.stream("POST", target, content=data,
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
                    r    = c.post(target, content=data, headers={"Content-Type": "application/json"})
                    resp = r.content
                    self.send_response(r.status_code)
                    for k, v in r.headers.items():
                        if k.lower() not in ("transfer-encoding", "connection", "content-length"):
                            self.send_header(k, v)
                    self.send_header("Content-Length", str(len(resp)))
                    self.end_headers()
                    self.wfile.write(resp)

        def do_GET(self):
            r    = httpx.get(f"{PROXY}{self.path}", timeout=10)
            data = r.content
            self.send_response(r.status_code)
            self.send_header("Content-Type", r.headers.get("content-type", "application/json"))
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def log_message(self, fmt, *args):
            pass

    print(f"[router] 127.0.0.1:{PORT} → proxy:{PROXY} classifier:{DRAFT}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
  '';
in {
  config = lib.mkIf (cfg.letta.enable && cfg.router.enable) {
    systemd.services.letta-router = {
      description = "Letta Agent Router (qwen3:1.7b classifier + @prefix dispatch)";
      after = ["letta-proxy.service" "ollama.service"];
      requires = ["letta-proxy.service" "ollama.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      environment = {
        PROXY_UPSTREAM = "http://127.0.0.1:${toString proxyPort}";
        OLLAMA_UPSTREAM = "http://127.0.0.1:11434";
        CLASSIFIER_MODEL = cfg.models.draft;
        ROUTER_PORT = toString routerPort;
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = "${pkgs.letta}/bin/python3.11 ${routerScript}";
        Restart = "on-failure";
        RestartSec = "3s";
        NoNewPrivileges = true;
        StandardOutput = "append:/tmp/letta-router.log";
        StandardError = "append:/tmp/letta-router.log";
      };
    };
  };
}
