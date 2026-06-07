{
  inputs,
  lib,
  ...
}: let
  commonNixSettings = {
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    log-lines = 25;
    auto-optimise-store = true;
    warn-dirty = false;
    min-free = 2147483648; # 2GB
    max-free = 5368709120; # 5GB
    builders-use-substitutes = true;
  };
  nixToolsPkgs = pkgs: with pkgs; [nix-output-monitor nvd];
  unityTestOverlay = _final: prev: {
    unity-test = prev.unity-test.overrideAttrs (_old: {
      doCheck = false;
    });
  };
in {
  den.aspects.nix-settings.nixos = {
    config,
    pkgs,
    ...
  }: {
    options.core.nix-settings.cores = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 0;
      description = "Cores available to the Nix daemon per build (0 = all cores).";
    };

    config = {
      nixpkgs.overlays = [
        unityTestOverlay
        inputs.cachyos-kernel.overlays.default
      ];

      nix.enable = lib.mkDefault true;
      nix.daemonCPUSchedPolicy = "batch";
      nix.daemonIOSchedPriority = 7;
      nix.settings =
        commonNixSettings
        // {
          cores = config.core.nix-settings.cores;
          substituters = [
            "https://cache.nixos.org"
            "https://hyprland.cachix.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };

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

      environment.systemPackages = nixToolsPkgs pkgs;

      environment.variables = {
        FLAKE = "/etc/nixos";
        NIXOS_OZONE_WL = "1";
      };

      nixpkgs.config.allowUnfree = true;
    };
  };

  den.aspects.nix-settings.darwin = {pkgs, ...}: {
    nixpkgs.overlays = [
      unityTestOverlay
      (_final: prev: {
        direnv = prev.direnv.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];

    nix.enable = lib.mkDefault false;
    nix.settings = commonNixSettings;

    environment.systemPackages = nixToolsPkgs pkgs;

    nixpkgs.config.allowUnfree = true;
  };

  den.aspects.nix-settings.homeManager = {
    host,
    pkgs,
    ...
  }: {
    programs.zsh.shellAliases = {
      clean = "nh clean all --keep 20";
      cdn = "cd $FLAKE";
      nixinfo = "nh os info";
      nix-list = "nix profile list --profile ~/.local/state/nix/profiles/scratch";
      nix-clear = "rm -rf ~/.local/state/nix/profiles/scratch && nh clean all --keep 20";
    };

    programs.zsh.initContent = ''
      rebuild() {
        if [[ "$1" == "check" ]]; then
          git -C $FLAKE add . && ${
        if pkgs.stdenv.isDarwin
        then "nh darwin build $FLAKE && rm ./result"
        else "nh os build --diff always && rm ./result"
      }
        else
          git -C $FLAKE add . && (cd $FLAKE && nix fmt) && ${
        if pkgs.stdenv.isDarwin
        then "nh darwin switch $FLAKE"
        else "nh os switch"
      }
        fi
      }

      upgrade() {
        if [[ "$1" == "check" ]]; then
          git -C $FLAKE add . && ${
        if pkgs.stdenv.isDarwin
        then "nix flake update $FLAKE && nh darwin build $FLAKE && rm ./result"
        else "nh os build --update --diff always && rm ./result"
      }
        else
          git -C $FLAKE add . && (cd $FLAKE && nix fmt) && ${
        if pkgs.stdenv.isDarwin
        then "nh darwin switch --update $FLAKE"
        else "nh os switch --update"
      }
        fi
      }

      nix-add() { local profile="$HOME/.local/state/nix/profiles/scratch"; NIXPKGS_ALLOW_UNFREE=1 nix profile add --profile "$profile" --impure nixpkgs#$1; }
      nix-remove() {
        if [[ ! -d ~/.local/state/nix/profiles/scratch ]]; then echo "Scratch profile doesn't exist"; return 1; fi
        nix profile remove --profile ~/.local/state/nix/profiles/scratch $1
      }
    '';

    # FLAKE env var is set by each OS body pointing to the host-specific path.
    # nh.flake mirrors it so nh commands find the flake without a flag.
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 20 --optimise";
      flake = host.flakePath;
    };

    home.sessionVariables.FLAKE = host.flakePath;
  };
}
