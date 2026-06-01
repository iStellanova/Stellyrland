{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;

  # Firejail path used in the sandbox tool. NixOS puts setuid wrappers here.
  firejailBin = "/run/wrappers/bin/firejail";

  # Tool: run arbitrary Python/bash code in a Firejail sandbox.
  # The coder agent uses this to verify code it writes before returning it.
  sandboxToolSource = pkgs.writeText "run-code-sandbox.py" ''
    def run_code_sandbox(code: str, language: str = "python") -> str:
        """Execute code in an isolated sandbox and return the output.

        Use this to test, verify, or run code snippets you have written.
        Network access is blocked. Execution is limited to 30 seconds.

        Args:
            code: Source code to execute
            language: Programming language - 'python' (default) or 'bash'

        Returns:
            Execution result with exit code, stdout, and stderr
        """
        import subprocess
        import tempfile
        import os
        import sys

        if language not in ("python", "bash"):
            return f"Unsupported language: {language!r}. Use 'python' or 'bash'."

        suffix = ".py" if language == "python" else ".sh"
        interpreter = sys.executable if language == "python" else "/bin/sh"

        with tempfile.NamedTemporaryFile(suffix=suffix, mode="w", delete=False) as f:
            f.write(code)
            fname = f.name

        sandbox = "${firejailBin}"
        use_firejail = os.path.exists(sandbox)

        try:
            if use_firejail:
                cmd = [sandbox, "--quiet", "--net=none", interpreter, fname]
            else:
                cmd = [interpreter, fname]

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                env={"PATH": "/run/current-system/sw/bin:/usr/bin:/bin", "HOME": "/tmp"},
            )
            output = f"exit_code: {result.returncode}"
            if result.stdout:
                output += f"\nstdout:\n{result.stdout.rstrip()}"
            if result.stderr:
                output += f"\nstderr:\n{result.stderr.rstrip()}"
            if not result.stdout and not result.stderr:
                output += "\n(no output)"
            return output
        except subprocess.TimeoutExpired:
            return "exit_code: 1\nstderr: Execution timed out (30 second limit)"
        finally:
            try:
                os.unlink(fname)
            except OSError:
                pass
  '';

  # Tool: analyze an image via the local vision model (calls Ollama directly).
  # Echo uses this when the user asks about a screenshot or file.
  visionToolSource = pkgs.writeText "analyze-image.py" ''
    def analyze_image(image_path: str, question: str = "Describe this image in detail.") -> str:
        """Analyze an image and answer questions about it using the vision model.

        The image must be a local file path on the system.
        Supports PNG, JPEG, GIF, and WebP formats.

        Args:
            image_path: Absolute path to the image file
            question: What to ask about the image (default: describe the image)

        Returns:
            Vision model analysis or answer to the question
        """
        import base64
        import json
        import urllib.request
        import os

        if not os.path.isfile(image_path):
            return f"Error: File not found: {image_path!r}"

        with open(image_path, "rb") as f:
            image_data = base64.b64encode(f.read()).decode("utf-8")

        payload = json.dumps({
            "model": "${cfg.models.vision}",
            "prompt": question,
            "images": [image_data],
            "stream": False,
        }).encode()

        req = urllib.request.Request(
            "http://127.0.0.1:11434/api/generate",
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                result = json.load(r)
                return result.get("response", "No response from vision model")
        except Exception as e:
            return f"Error calling vision model ({type(e).__name__}): {e}"
  '';

  # Python script that creates/updates tools and attaches them to agents.
  # Safe to re-run: PUT /v1/tools/ is an upsert; attaches are idempotent.
  toolInitPy = pkgs.writeText "letta-tool-init.py" ''
    import json, re, time, urllib.request

    LETTA = "http://127.0.0.1:${toString cfg.letta.port}"

    def req(method, path, data=None):
        payload = json.dumps(data).encode() if data is not None else None
        r = urllib.request.Request(
            f"{LETTA}{path}",
            data=payload,
            headers={"Content-Type": "application/json"} if payload else {},
            method=method,
        )
        with urllib.request.urlopen(r, timeout=30) as resp:
            return json.load(resp)

    for _ in range(30):
        try:
            req("GET", "/v1/health")
            break
        except Exception:
            time.sleep(2)
    else:
        raise SystemExit("Letta did not become healthy in time")

    def upsert_tool(source_path: str) -> str:
        source_code = open(source_path).read()
        result = req("PUT", "/v1/tools/", {"source_code": source_code, "source_type": "python"})
        tid = result["id"]
        print(f"Tool upserted: {result.get('name', '?')} ({tid})")
        return tid

    def get_tool_id(name: str):
        """Look up a tool ID by name — works for custom and built-in tools."""
        for t in req("GET", "/v1/tools/?limit=100"):
            if t.get("name") == name:
                return t["id"]
        return None

    def attach_tool(agent_name: str, tool_id: str) -> None:
        agents = req("GET", f"/v1/agents/?name={agent_name}")
        if not isinstance(agents, list) or not agents:
            print(f"Agent {agent_name!r} not found, skipping attach")
            return
        agent_id = agents[0]["id"]
        if any(t["id"] == tool_id for t in (req("GET", f"/v1/agents/{agent_id}/tools") or [])):
            print(f"Tool already attached to {agent_name}")
            return
        req("PATCH", f"/v1/agents/{agent_id}/tools/attach/{tool_id}")
        print(f"Attached tool to {agent_name}")

    def update_block(block_id: str, value: str) -> None:
        req("PATCH", f"/v1/blocks/{block_id}", {"value": value})

    # --- Custom tools ---
    sandbox_id = upsert_tool("${sandboxToolSource}")
    vision_id  = upsert_tool("${visionToolSource}")
    attach_tool("coder", sandbox_id)
    attach_tool("echo",  vision_id)

    # send_message_to_agent_and_wait_for_reply is attached to echo so it's available
    # if the model ever chooses to use it voluntarily. Routing is not forced — models
    # at this scale don't reliably follow delegation instructions. Use `code` alias
    # to reach the coder agent directly.
    coder_agents = req("GET", "/v1/agents/?name=coder")
    echo_agents  = req("GET", "/v1/agents/?name=echo")

    if coder_agents and echo_agents:
        coder_id = coder_agents[0]["id"]
        echo_id  = echo_agents[0]["id"]
        delegate_tid = get_tool_id("send_message_to_agent_and_wait_for_reply")
        if delegate_tid:
            attach_tool("echo", delegate_tid)
    else:
        print("Skipping delegation tool attach: coder or echo agent not found")

    print("Tool init complete.")
  '';

  toolInitScript = pkgs.writeShellScript "letta-tool-init" ''
    exec ${pkgs.letta}/bin/python3.11 ${toolInitPy}
  '';
in {
  config = lib.mkIf cfg.letta.enable {
    # Firejail setuid wrapper so the sandbox tool can drop network access
    programs.firejail.enable = lib.mkIf cfg.sandbox.enable true;

    systemd.services.letta-tool-init = {
      description = "Register Letta tools and wire agent capabilities";
      after = ["letta-agent-init.service"];
      requires = ["letta.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = toolInitScript;
        RemainAfterExit = true;
      };
    };
  };
}
