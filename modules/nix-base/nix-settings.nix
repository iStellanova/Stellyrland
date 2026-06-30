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
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nixToolsPkgs = pkgs: with pkgs; [nix-output-monitor dix];
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
      nix.settings = commonNixSettings // {cores = config.core.nix-settings.cores;};

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

      environment.variables = {
        NIXOS_OZONE_WL = "1";
      };
    };
  };

  sn.nix-settings.darwin = _: {
    nixpkgs.overlays = [
      (_final: prev: {
        direnv = prev.direnv.overrideAttrs (_old: {
          doCheck = false;
        });
      })
    ];

    # mkDefault false — lix.nix overrides to true when Lix manages the daemon.
    nix.enable = lib.mkDefault false;
    nix.settings = commonNixSettings;
  };

  sn.nix-settings.os = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    # TODO: remove once nixpkgs bumps pnpm past 10.29.2 (build-time dep of vesktop, still present 2026-06-29)
    nixpkgs.config.permittedInsecurePackages = ["pnpm-10.29.2"];
    nix.extraOptions = ''
      !include /etc/nix/access-tokens.conf
    '';
    environment.systemPackages = nixToolsPkgs pkgs;
  };
}
