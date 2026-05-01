{ config, lib, pkgs, identity, ... }:

{
  options.aspects.core.nix-settings.enable = lib.mkEnableOption "Core nix settings" // { default = true; };

  config = lib.mkIf config.aspects.core.nix-settings.enable (lib.mkMerge [

    # Nix Settings
    {
      nix.enable = lib.mkDefault (!pkgs.stdenv.isDarwin);
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        log-lines = 25;
        auto-optimise-store = true;
        warn-dirty = false;
        min-free = 2147483648; # 2GB
        max-free = 5368709120; # 5GB
        builders-use-substitutes = true;
      };

      # Cleaner nix output feedback and generation diffing.
      environment.systemPackages = with pkgs; [
        nix-output-monitor # Pipeline your nix-build to nom to get a better output
        nvd                # Diff tool to see exactly what changed between generations
      ];

      # Set the flake path based on the system type (Darwin/Linux).
      environment.variables = {
        FLAKE = if pkgs.stdenv.isDarwin then "${identity.home}/Documents/GitHub/Stellyrland" else "/etc/nixos";
      };

      # Allow unfree packages (e.g. proprietary software).
      nixpkgs.config.allowUnfree = true;

      # Home Manager configuration for maintenance aliases.
      home-manager.users.${identity.name} = {
        programs.zsh.shellAliases = {

          # Nix-specific maintenance
          clean = "nh clean all --keep 20"; # Clean up old generations. Leaves 20.
          cdn = "cd $FLAKE";  # Change directory to the flake.
          nixinfo = "nh os info"; # Checks generations.

          # Scratch profile aliases
          nix-list = "nix profile list --profile ~/.local/state/nix/profiles/scratch"; # List packages in the scratch profile.
          nix-clear = "rm -rf ~/.local/state/nix/profiles/scratch && nh clean all --keep 20"; # Clear the scratch profile and clean up old generations.
        };

        # Rebuild aliases.
        # rebuild
          # NixOS: Take a BTRFS snapshot, add the repo to git, rebuild and switch.
          # Darwin: Simply rebuild and switch.
        # upgrade
          # NixOS: Take a BTRFS snapshot, add the repo to git, upgrade flatpak, upgrade the system, and switch to the new generation.
          # Darwin: Upgrade the system.
        # nix-add: Add a package to the scratch profile.
        # nix-remove: Remove a package from the scratch profile.
        programs.zsh.initContent = ''
          rebuild() {
            if [[ "$1" == "check" ]]; then
              git -C $FLAKE add . && ${if pkgs.stdenv.isDarwin then "nh darwin build $FLAKE" else "nh os build --diff always"}
            else
              ${if pkgs.stdenv.isDarwin then "" else "(snapper -c home create -c timeline --description \"Before rebuild\" || true) && "}git -C $FLAKE add . && ${if pkgs.stdenv.isDarwin then "nh darwin switch $FLAKE" else "nh os switch"}
            fi
          }

          upgrade() {
            if [[ "$1" == "check" ]]; then
              git -C $FLAKE add . && ${if pkgs.stdenv.isDarwin then "nix flake update $FLAKE && nh darwin build $FLAKE" else "nh os build --update --diff always"}
            else
              ${if pkgs.stdenv.isDarwin then "" else "(snapper -c home create -c timeline --description \"Before upgrade\" || true) && flatpak update && "}git -C $FLAKE add . && ${if pkgs.stdenv.isDarwin then "nh darwin switch --update $FLAKE" else "nh os switch --update"}
            fi
          }

          nix-add() { local profile="$HOME/.local/state/nix/profiles/scratch"; nix profile add --profile "$profile" nixpkgs#$1; }
          nix-remove() {
            if [[ ! -d ~/.local/state/nix/profiles/scratch ]]; then echo "Scratch profile doesn't exist"; return 1; fi
            nix profile remove --profile ~/.local/state/nix/profiles/scratch $1
          }
        '';
        # nh - Yet another Nix Helper. Provides a cleaner CLI for builds and GC.
        programs.nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep 20";
          flake = if pkgs.stdenv.isDarwin then "${identity.home}/Documents/GitHub/Stellyrland" else "/etc/nixos";
        };
      };
    }
  ]);
}
