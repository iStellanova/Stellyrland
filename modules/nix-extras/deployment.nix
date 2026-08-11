_:
let
  targets = {
    plasmapulsefinale = {
      kind = "nixos";
      hostName = "plasmapulsefinale.tailb15b96.ts.net";
      hostNames = [ "plasmapulsefinale.tailb15b96.ts.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+IEKcruyMNZYEp9PHYHC6Z/AkEoJnxByunqql9zO71";
    };
    stellyrland = {
      kind = "nixos";
      hostName = "stellyrland.tailb15b96.ts.net";
      hostNames = [
        "stellyrland.local"
        "stellyrland.tailb15b96.ts.net"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA";
    };
    stellyrtop = {
      kind = "darwin";
      hostName = "stellyrtop.tailb15b96.ts.net";
      hostNames = [ "stellyrtop.tailb15b96.ts.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuUvoUL9cDXQKdtmHxidbuOK8iuC/ItVWyPFzXySxSm";
    };
  };
in
{
  flake.modules.nixos.deployment-controller =
    {
      config,
      host,
      lib,
      pkgs,
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
            inherit (targets.stellyrland) hostName;
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

      systemd.services.tailscale-settings.script = lib.mkForce "${pkgs.tailscale}/bin/tailscale set --accept-dns=true --accept-routes=false --ssh=false";

      services.tailscale = {
        interfaceName = lib.mkForce "tailscale0";
        extraUpFlags = lib.mkForce [
          "--accept-dns=true"
          "--accept-routes=false"
          "--ssh=false"
        ];
      };
    };

  flake.modules.homeManager.deployment-controller =
    { lib, pkgs, ... }:
    let
      deploymentKnownHosts = pkgs.writeText "deployment-known-hosts" (
        lib.concatStringsSep "\n" (
          lib.concatMap (target: map (hostName: "${hostName} ${target.publicKey}") target.hostNames) (
            builtins.attrValues targets
          )
        )
      );
      deploymentAliases = lib.listToAttrs (
        lib.mapAttrsToList (name: target: {
          inherit name;
          value = {
            HostName = target.hostName;
            User = "stellanova";
            IdentityFile = "/run/secrets/stellyrlab-deploy-key";
            IdentitiesOnly = "yes";
            BatchMode = "yes";
            SetEnv.TERM = "xterm-256color";
            StrictHostKeyChecking = "yes";
            UserKnownHostsFile = toString deploymentKnownHosts;
          };
        }) targets
      );
      deploymentTypes = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: target: "  ${name} ${target.kind}") targets
      );
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = deploymentAliases;
      };

      programs.zsh.initContent = ''
                _deployment_prep() {
                  (cd "$FLAKE" && nix fmt -- --ci) && git -C "$FLAKE" --no-pager diff --check
                }

                typeset -A _deployment_types=(
        ${deploymentTypes}
                )

                deploy() {
                  if [[ -z "$1" ]]; then
                    echo "Usage: deploy <host> [check|extra-args...]"
                    return 1
                  fi
                  local target="$1"
                  shift

                  if [[ "$target" == stellyrlab ]]; then
                    if [[ "$1" == "check" ]]; then
                      shift
                      _deployment_prep && nixos-rebuild build --flake "$FLAKE#$target" "$@"
                    else
                      _deployment_prep && nixos-rebuild switch --flake "$FLAKE#$target" --elevate=run0 "$@"
                    fi
                    return $?
                  fi

                  local deployment_type="''${_deployment_types[$target]}"
                  case "$deployment_type" in
                    nixos)
                      local target_host=(--target-host "$target")
                      if [[ "$1" == "check" ]]; then
                        shift
                        _deployment_prep && nh os switch "$FLAKE#$target" --hostname "$target" "''${target_host[@]}" --elevation-strategy=program:sudo --dry --diff always "$@"
                      else
                        _deployment_prep && nh os switch "$FLAKE#$target" --hostname "$target" "''${target_host[@]}" --elevation-strategy=program:sudo --diff always "$@"
                      fi
                      ;;
                    darwin)
                      local source_flake="github:iStellanova/Stellyrland/$(git -C "$FLAKE" rev-parse HEAD)"
                      if [[ "$1" == "check" ]]; then
                        shift
                        _deployment_prep && ssh "$target" "nh darwin build '$source_flake#$target' --hostname '$target' --diff always"
                      else
                        _deployment_prep && ssh -tt "$target" "nh darwin switch '$source_flake#$target' --hostname '$target' --elevation-strategy=program:sudo --diff always"
                      fi
                      ;;
                    *)
                      echo "No controller deployment path for $target"
                      return 1
                      ;;
                  esac
                }
      '';
    };
}
