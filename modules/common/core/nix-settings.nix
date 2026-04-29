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
        cores = 24;                       # Leave 8 threads free for system/driver
        builders-use-substitutes = true;

        # CachyOS Binary Cache
        substituters = [
          "https://cache.nixos.org"
          "https://nix-cachyos-kernel.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-cachyos-kernel.cachix.org-1:7Xf057/lP09V9q3l3qH6K25W/vV6J7S07V/1ZqX8L/A="
        ];
      };

      environment.systemPackages = with pkgs; [
        nix-output-monitor # Pipeline your nix-build to nom to get a better output
        nvd                # Diff tool for nix packages
      ];

      environment.variables = {
        FLAKE = if pkgs.stdenv.isDarwin then "${identity.home}/Documents/GitHub/Stellyrland" else "/etc/nixos";
      };

    nixpkgs.config.allowUnfree = true;

      home-manager.users.${identity.name} = {
        programs.zsh.shellAliases = {
          # Nix-specific maintenance
          clean = "nh clean all --keep 20";
          cdn = "cd $FLAKE";
          nixinfo = if pkgs.stdenv.isDarwin then "nix-shell -p nix-info --run nix-info" else "nh os info";

          # Scratch profile aliases
          nix-list = "nix profile list --profile ~/.local/state/nix/profiles/scratch";
          nix-clear = "rm -rf ~/.local/state/nix/profiles/scratch && nh clean all --keep 20";
        };

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
