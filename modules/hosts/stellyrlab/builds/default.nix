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
          git
          notify
          ;
      };
      commonEnvironment = [
        "HOME=${host.homeDir}"
        "PATH=${
          lib.makeBinPath [
            pkgs.git
            pkgs.nix
            pkgs.nix-eval-jobs
            pkgs.openssh
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
          TimeoutStartSec = "infinity";
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
          TimeoutStartSec = "infinity";
          Environment = commonEnvironment;
        };
      };

      systemd.user.services.nix-fleet-build-repair = {
        Unit = {
          Description = "Repair and report a failed x86 NixOS fleet build";
          After = [ "nix-fleet-build.service" ];
        };
        Service = {
          Type = "oneshot";
          WorkingDirectory = host.flakePath;
          ExecStart = repairFleet;
          TimeoutStartSec = "infinity";
          Environment = commonEnvironment;
        };
      };

      systemd.user.timers.nix-fleet-build = {
        Unit.Description = "Run the daily Nix fleet build";
        Timer = {
          OnCalendar = "*-*-* 05:00:00 America/Indianapolis";
          Persistent = true;
          Unit = "nix-fleet-build.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
