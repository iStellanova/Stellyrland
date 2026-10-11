{ inputs, ... }:
{
  modules.homeManager.fleet-build = { host, lib, pkgs, ... }:
    let
      pnix = inputs.pnix.packages.${pkgs.stdenv.hostPlatform.system}.default;
      statusApi = pkgs.writeShellScript "nix-fleet-build-status-api" ''
        exec ${pkgs.python3}/bin/python3 - <<'PY'
        import json
        import subprocess
        from http.server import BaseHTTPRequestHandler, HTTPServer

        systemctl = "${pkgs.systemd}/bin/systemctl"

        def read_status():
            properties = [
                "ActiveState",
                "Result",
                "ExecMainStartTimestamp",
                "ExecMainExitTimestamp",
            ]
            result = subprocess.run(
                [systemctl, "--user", "show", "nix-fleet-build.service", "--property=" + ",".join(properties)],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode != 0:
                return {"status": "unknown", "updated": None}
            values = dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)
            active = values.get("ActiveState")
            started = values.get("ExecMainStartTimestamp")
            if active in {"activating", "active"}:
                status = "running"
            elif values.get("Result") == "success" and started:
                status = "success"
            elif values.get("Result") in {"exit-code", "signal", "core-dump", "timeout", "watchdog"}:
                status = "failed"
            else:
                status = "unknown"
            return {
                "status": status,
                "updated": values.get("ExecMainExitTimestamp") or started,
            }

        class Handler(BaseHTTPRequestHandler):
            def do_GET(self):
                if self.path != "/status":
                    self.send_error(404)
                    return
                payload = json.dumps(read_status()).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)

            def log_message(self, *_):
                pass

        HTTPServer(("127.0.0.1", 9118), Handler).serve_forever()
        PY
      '';
    in
    {
      systemd.user.services.nix-fleet-build = {
        Unit = {
          Description = "Update and build the x86 NixOS fleet";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          WorkingDirectory = host.flakePath;
          ExecStartPre = "${pnix}/bin/pnix update";
          ExecStart = "${pkgs.nix-fast-build}/bin/nix-fast-build ${lib.escapeShellArgs [
            "--flake"
            "${host.flakePath}#nixosConfigurations"
            "--systems"
            "x86_64-linux"
            "--max-jobs"
            "1"
            "--no-link"
            "--select"
            "configs: builtins.mapAttrs (name: config: config.config.system.build.toplevel) configs"
          ]}";
          TimeoutStartSec = "infinity";
          Environment = [
            "HOME=${host.homeDir}"
            "NIX_CONFIG=extra-experimental-features = pipe-operator"
            "PATH=${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.git
                pkgs.nix
                pkgs.nix-fast-build
                pkgs.openssh
                pnix
              ]
            }"
          ];
        };
      };

      systemd.user.services.nix-fleet-build-status-api = {
        Unit.Description = "Nix fleet build status API";
        Service = {
          ExecStart = statusApi;
          Restart = "always";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.timers.nix-fleet-build = {
        Unit.Description = "Run the daily Nix fleet build";
        Timer = {
          OnCalendar = "*-*-* 05:00:00 America/Indianapolis";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
