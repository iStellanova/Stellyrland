{
  sn,
  lib,
  ...
}: let
  commonNixSettings = {
    experimental-features = ["nix-command" "flakes" "pipe-operator"];
    log-lines = 25;
    auto-optimise-store = true;
    warn-dirty = false;
    keep-outputs = true;
    min-free = 2147483648; # 2GB
    max-free = 5368709120; # 5GB
    builders-use-substitutes = true;
  };
  nixToolsPkgs = pkgs: with pkgs; [nix-output-monitor nvd];
in {
  sn.nix-base = {includes = [sn.nix-settings];};

  sn.nix-settings.nixos = {
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
      nix.enable = lib.mkDefault true;
      nix.daemonCPUSchedPolicy = "batch";
      nix.daemonIOSchedPriority = 7;
      nix.extraOptions = ''
        !include /etc/nix/access-tokens.conf
      '';
      nix.settings =
        commonNixSettings
        // {
          cores = config.core.nix-settings.cores;
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
        NIXOS_OZONE_WL = "1";
      };
    };
  };

  sn.nix-settings.darwin = {pkgs, ...}: {
    nixpkgs.overlays = [
      (_final: prev: {
        direnv = prev.direnv.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];

    nix.enable = lib.mkDefault false;
    nix.settings = commonNixSettings;
    nix.extraOptions = ''
      !include /etc/nix/access-tokens.conf
    '';

    environment.systemPackages = nixToolsPkgs pkgs;
  };

  sn.nix-settings.os = _: {
    nixpkgs.config.allowUnfree = true;
  };
}
