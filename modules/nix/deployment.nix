_:
let
  targets = {
    ItsRedFlame = {
      hostNames = [ "itsredflame.tailb15b96.ts.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgWFxH/qllaNX5axfrDfplGpn/URESTGNX/t4TGgJ6q";
    };
    plasmapulsefinale = {
      hostNames = [ "plasmapulsefinale.tailb15b96.ts.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+IEKcruyMNZYEp9PHYHC6Z/AkEoJnxByunqql9zO71";
    };
    stellyrland = {
      hostNames = [
        "stellyrland.local"
        "stellyrland.tailb15b96.ts.net"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA";
    };

  };
in
{
  flake.modules.nixos.deployment-distributor =
    {
      config,
      host,
      lib,
      ...
    }:
    {
      sops.secrets.stellyrlab-deploy-key = {
        owner = host.username;
        mode = "0600";
      };

      programs.ssh.knownHosts = lib.mapAttrs (_: target: {
        inherit (target) hostNames publicKey;
      }) targets;

      nix = {
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = builtins.head targets.stellyrland.hostNames;
            system = "x86_64-linux";
            protocol = "ssh-ng";
            sshUser = host.username;
            sshKey = config.sops.secrets.stellyrlab-deploy-key.path;
            supportedFeatures = [ "big-parallel" ];
            maxJobs = 1;
            speedFactor = 10;
          }
        ];
      };

    };

  flake.modules.homeManager.deployment-distributor =
    { lib, pkgs, ... }:
    let
      deploymentKnownHosts = pkgs.writeText "deployment-known-hosts" (
        lib.concatStringsSep "\n" (
          lib.concatMap (target: map (hostName: "${hostName} ${target.publicKey}") target.hostNames) (
            builtins.attrValues targets
          )
        )
      );
      deploymentSSHAliases = lib.listToAttrs (
        lib.mapAttrsToList (name: target: {
          name = "deploy-${name}";
          value = {
            HostName = builtins.head target.hostNames;
            User = "stellanova";
            IdentityFile = "/run/secrets/stellyrlab-deploy-key";
            IdentitiesOnly = "yes";
            BatchMode = "yes";
            StrictHostKeyChecking = "yes";
            UserKnownHostsFile = toString deploymentKnownHosts;
          };
        }) targets
      );
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = deploymentSSHAliases;
      };
      programs.zsh.initContent = ''
        deploy() {
          if [[ -z "$1" ]]; then
            echo "Usage: deploy <host> [check]"
            return 1
          fi

          local target="$1"
          local check="''${2:-}"
          local dry=""
          if [[ -n "$check" && "$check" != check ]]; then
            echo "Usage: deploy <host> [check]"
            return 1
          fi
          [[ "$check" == check ]] && dry="--dry"
          local remote="deploy-$target"
          if [[ "$target" == "$(hostname)" ]]; then
            nh os switch "$FLAKE#$target" --hostname "$target" --elevation-strategy=run0 $dry --diff always
          else
            nh os switch "$FLAKE#$target" --hostname "$target" --target-host "$remote" --elevation-strategy=program:sudo $dry --diff always
          fi
        }
      '';
    };
}
