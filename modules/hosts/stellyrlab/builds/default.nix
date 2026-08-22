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
      hermes = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
      stateDir = "${host.homeDir}/.local/state/nix-fleet-build";
      discordChannel = "1540710403892453477";
      notify = import ./_notify.nix {
        inherit
          pkgs
          curl
          jq
          discordChannel
          ;
      };
      buildFleet = import ./_build.nix {
        inherit
          host
          pkgs
          lib
          nix
          nixStore
          git
          jq
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
    in
    {
      systemd.user.services = {
        nix-fleet-build = {
          Unit = {
            Description = "Refresh Tack and build the x86 NixOS fleet";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
            OnFailure = [ "nix-fleet-build-repair.service" ];
          };
          Service = {
            Type = "oneshot";
            WorkingDirectory = host.flakePath;
            ExecStart = buildFleet;
            TimeoutStartSec = "infinity";
            SuccessExitStatus = [ 77 ];
            Environment = [
              "HOME=${host.homeDir}"
              "PATH=${
                lib.makeBinPath [
                  pkgs.git
                  pkgs.nix
                  pkgs.openssh
                  pkgs.coreutils
                  pkgs.curl
                  pkgs.jq
                ]
              }"
            ];
          };
        };
        nix-fleet-build-repair = {
          Unit.Description = "Repair a failed scheduled Nix fleet build";
          Service = {
            Type = "oneshot";
            WorkingDirectory = host.flakePath;
            ExecStart = repairFleet;
            TimeoutStartSec = "infinity";
            Environment = [
              "HOME=${host.homeDir}"
              "PATH=${
                lib.makeBinPath [
                  pkgs.git
                  pkgs.nix
                  pkgs.openssh
                  pkgs.coreutils
                  pkgs.curl
                  pkgs.jq
                ]
              }"
            ];
          };
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
