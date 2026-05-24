{
  config,
  lib,
  inputs,
  ...
}: let
  # Import the standard stellyrland host builder cleanly once.
  inherit ((import ../../lib/default.nix {inherit lib;})) mkHost;
in {
  config.flake = {
    nixosConfigurations =
      lib.mapAttrs (
        _name: host:
          mkHost {inherit config inputs;} {
            inherit (host) system;
            isDarwin = false;
            extraModules = host.modules;
          }
      )
      config.hosts.nixos;

    darwinConfigurations =
      lib.mapAttrs (
        _name: host:
          mkHost {inherit config inputs;} {
            inherit (host) system;
            isDarwin = true;
            extraModules = host.modules;
          }
      )
      config.hosts.darwin;

    # Re-export discovered modules individually and as a bundled default
    nixosModules =
      config.flake.modules.nixos
      // {
        default = {
          imports = lib.attrValues config.flake.modules.nixos;
        };
      };
    darwinModules =
      config.flake.modules.darwin
      // {
        default = {
          imports = lib.attrValues config.flake.modules.darwin;
        };
      };
    homeManagerModules =
      config.flake.modules.homeManager
      // {
        default = {
          imports = lib.attrValues config.flake.modules.homeManager;
        };
      };
  };
}
