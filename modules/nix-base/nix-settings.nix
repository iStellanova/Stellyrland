{
  sn,
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
in {
  sn.nix-base = {includes = [sn.nix-settings];};

  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

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
      nixpkgs.overlays = [
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
            "https://attic.xuyh0120.win/lantian"
            "https://zen-browser.cachix.org"
            "https://noctalia.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
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

    environment.systemPackages = nixToolsPkgs pkgs;

    nixpkgs.config.allowUnfree = true;
  };
}
