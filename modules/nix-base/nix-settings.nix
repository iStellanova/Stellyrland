{ lib, ... }:
let
  commonNixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operator"
    ];
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
  nixToolsPkgs =
    pkgs: with pkgs; [
      nix-output-monitor
      dix
    ];
  osShared = { pkgs, ... }: {
    nix.nixPath = [ ];
    nixpkgs.config.allowUnfree = true;
    # TODO: drop once nixpkgs bumps vesktop (nixcord) past Electron 41 —
    # upstream Vesktop is still on 1.6.5 (electron_40), and nixpkgs marked
    # electron_40 EOL/insecure on 2026-07-14 (commit 05151e55).
    nixpkgs.config.permittedInsecurePackages = [ "electron-40.10.5" ];
    nix.extraOptions = ''
      !include /etc/nix/access-tokens.conf
    '';
    environment.systemPackages = nixToolsPkgs pkgs;
  };
in
{
  flake.modules.nixos.nix-settings = {
    imports = [
      osShared
      (
        { config, pkgs, ... }:
        {
          options.core.nix-settings.cores = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 0;
            description = "Cores available to the Nix daemon per build (0 = all cores).";
          };

          config = {
            nix.enable = lib.mkDefault true;
            nix.daemonCPUSchedPolicy = "batch";
            nix.daemonIOSchedPriority = 7;
            nix.settings = commonNixSettings // {
              cores = config.core.nix-settings.cores;
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

            environment.variables = {
              NIXOS_OZONE_WL = "1";
            };
          };
        }
      )
    ];
  };

  flake.modules.darwin.nix-settings = {
    imports = [
      osShared
      (_: {
        nixpkgs.overlays = [
          (_final: prev: {
            mcp-nixos = prev.mcp-nixos.overrideAttrs (old: {
              disabledTests = (old.disabledTests or [ ]) ++ [ "test_read_text_file" ];
            });
          })
        ];

        nix.enable = lib.mkDefault false;
        nix.settings = commonNixSettings;
      })
    ];
  };
}
