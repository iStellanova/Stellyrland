{ inputs, ... }:
{
  flake.modules.homeManager.fleet-build =
    {
      host,
      lib,
      pkgs,
      ...
    }:
    let
      nix = "${pkgs.nix}/bin/nix";
      nixStore = "${pkgs.nix}/bin/nix-store";
      git = "${pkgs.git}/bin/git";
      flock = "${pkgs.util-linux}/bin/flock";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      curl = "${pkgs.curl}/bin/curl";
      jq = "${pkgs.jq}/bin/jq";
      stateDir = "${host.homeDir}/.local/state/nix-fleet-build";
      hermes = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
      notify = import ./_notify.nix { inherit pkgs curl jq; };
      buildFleet = import ./_build.nix {
        inherit
          host
          pkgs
          lib
          nix
          git
          flock
          stateDir
          ;
      };
      reportFleet = import ./_report.nix {
        inherit
          host
          pkgs
          lib
          nix
          nixStore
          jq
          git
          stateDir
          notify
          ;
      };
      repairFleet = import ./_repair.nix {
        inherit
          host
          pkgs
          lib
          hermes
          systemctl
          stateDir
          ;
      };
      startFleet = pkgs.writeShellScript "nix-fleet-build-start" ''
        set -euo pipefail
        state_dir=${lib.escapeShellArg stateDir}
        ${pkgs.coreutils}/bin/rm -f "$state_dir/retry" "$state_dir/attempt"
        exec ${systemctl} --user start --no-block nix-fleet-build.service
      '';
      commonEnvironment = [
        "HOME=${host.homeDir}"
        "PATH=${
          lib.makeBinPath [
            pkgs.git
            pkgs.nix
            pkgs.util-linux
            pkgs.coreutils
            pkgs.curl
            pkgs.jq
          ]
        }"
      ];
    in
    {
      systemd.user.services.nix-fleet-build = {
        Unit = {
          Description = "Build the x86 NixOS fleet";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
          OnSuccess = [ "nix-fleet-build-report.service" ];
          OnFailure = [ "nix-fleet-build-repair.service" ];
        };
        Service = {
          Type = "oneshot";
          WorkingDirectory = host.flakePath;
          ExecStart = buildFleet;
          TimeoutStartSec = "2h";
          Environment = commonEnvironment;
        };
      };

      systemd.user.services.nix-fleet-build-start = {
        Unit = {
          Description = "Start a fresh x86 NixOS fleet build";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = startFleet;
          TimeoutStartSec = "1min";
          Environment = commonEnvironment;
        };
      };

      systemd.user.services.nix-fleet-build-report = {
        Unit = {
          Description = "Report a successful x86 NixOS fleet build";
          After = [ "nix-fleet-build.service" ];
        };
        Service = {
          Type = "oneshot";
          WorkingDirectory = host.flakePath;
          ExecStart = reportFleet;
          TimeoutStartSec = "5min";
          Environment = commonEnvironment;
        };
      };

      systemd.user.services.nix-fleet-build-repair = {
        Unit = {
          Description = "Repair a failed x86 NixOS fleet build";
          After = [ "nix-fleet-build.service" ];
        };
        Service = {
          Type = "oneshot";
          WorkingDirectory = host.flakePath;
          ExecStart = repairFleet;
          TimeoutStartSec = "20min";
          Environment = commonEnvironment;
        };
      };

      systemd.user.services.nix-fleet-build-retry = {
        Unit = {
          Description = "Retry the x86 NixOS fleet build after repair";
          After = [ "nix-fleet-build-repair.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${systemctl} --user start --no-block nix-fleet-build.service";
          TimeoutStartSec = "1min";
          Environment = commonEnvironment;
        };
      };

      systemd.user.timers.nix-fleet-build = {
        Unit.Description = "Run the daily Nix fleet build";
        Timer = {
          OnCalendar = "*-*-* 05:00:00 America/Indianapolis";
          Persistent = true;
          Unit = "nix-fleet-build-start.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
