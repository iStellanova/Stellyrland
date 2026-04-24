{ config, lib, pkgs, ... }:

{
  options.aspects.core.nix-settings.enable = lib.mkEnableOption "Core nix settings" // { default = true; };

  config = lib.mkIf config.aspects.core.nix-settings.enable {
    # Nix Settings
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 25;
      auto-optimise-store = true;
      warn-dirty = false;
      min-free = 2147483648; # 2GB
      max-free = 5368709120; # 5GB
      builders-use-substitutes = true;
    };

    # NH cleaner
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 20";
      flake = "/etc/nixos";
    };

    # Support for dynamically linked executables
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];

    environment.systemPackages = with pkgs; [
      nix-output-monitor # Pipeline your nix-build to nom to get a better output
      nvd                # Diff tool for nix packages
    ];

    environment.variables = {
      FLAKE = "/etc/nixos";
      NIXOS_OZONE_WL = "1";
    };

    nixpkgs.config.allowUnfree = true;

    home-manager.users.stellanova.programs.zsh.shellAliases = {
      # Nix-specific maintenance
      clean = "nh clean all --keep 20 --optimise";
      cdn = "cd /etc/nixos/";

      # Scratch profile aliases
      nix-list = "nix profile list --profile ~/.local/state/nix/profiles/scratch";
      nix-clear = "rm -rf ~/.local/state/nix/profiles/scratch && nh clean all --keep 20";
    };

    home-manager.users.stellanova.programs.zsh.initContent = ''
      rebuild() {
        if [[ "$1" == "check" ]]; then
          git -C /etc/nixos add . && nh os build --diff always
        else
          (snapper -c home create -c timeline --description "Before rebuild" || true) && git -C /etc/nixos add . && nh os switch
        fi
      }

      upgrade() {
        if [[ "$1" == "check" ]]; then
          git -C /etc/nixos add . && nh os build --update --diff always
        else
          (snapper -c home create -c timeline --description "Before upgrade" || true) && flatpak update && git -C /etc/nixos add . && nh os switch --update
        fi
      }

      nix-add() { local profile="$HOME/.local/state/nix/profiles/scratch"; nix profile add --profile "$profile" nixpkgs#$1; }
      nix-remove() {
        if [[ ! -d ~/.local/state/nix/profiles/scratch ]]; then echo "Scratch profile doesn't exist"; return 1; fi
        nix profile remove --profile ~/.local/state/nix/profiles/scratch $1
      }
    '';
  };
}
