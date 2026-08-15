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
  osShared = { ... }: {
    nix.nixPath = [ ];
    nixpkgs.config.allowUnfree = true;
    nix.extraOptions = ''
      !include /etc/nix/access-tokens.conf
    '';
  };
in
{
  flake.modules.nixos.nix-settings = {
    imports = [
      osShared
      (
        { ... }:
        {
          config = {
            nix.enable = lib.mkDefault true;
            nix.settings = commonNixSettings;
            programs.nix-ld.enable = true;
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
