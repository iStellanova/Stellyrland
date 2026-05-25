{
  lib,
  inputs,
  ...
}: {
  # Home Manager nix-index Settings
  flake.modules.homeManager.nix-index = {osConfig, ...}: {
    imports = [inputs.nix-index-database.homeModules.nix-index];

    config = lib.mkIf (osConfig ? aspects.programs.nix-index && osConfig.aspects.programs.nix-index.enable) {
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;
    };
  };

  # NixOS Options Declaration
  flake.modules.nixos.nix-index = {lib, ...}: {
    options.aspects.programs.nix-index.enable = lib.mkEnableOption "nix-index with pre-built database and comma";
  };

  # Darwin Options Declaration
  flake.modules.darwin.nix-index = {lib, ...}: {
    options.aspects.programs.nix-index.enable = lib.mkEnableOption "nix-index with pre-built database and comma";
  };
}
