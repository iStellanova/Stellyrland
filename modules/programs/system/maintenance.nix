_: {
  # NixOS Maintenance Settings
  flake.modules.nixos.maintenance = {lib, ...}: {
    options.aspects.programs.maintenance.enable = lib.mkEnableOption "System maintenance tools";
  };

  # Darwin Maintenance Settings
  flake.modules.darwin.maintenance = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.maintenance.enable = lib.mkEnableOption "System maintenance tools";

    config = lib.mkIf config.aspects.programs.maintenance.enable {
      homebrew.casks = ["cleanmymac"];
    };
  };

  # Home Manager Maintenance Settings
  flake.modules.homeManager.maintenance = {
    osConfig,
    pkgs,
    lib,
    ...
  }: let
    isDarwin = osConfig ? system.defaults;
  in
    lib.mkIf (osConfig ? aspects.programs.maintenance && osConfig.aspects.programs.maintenance.enable && !isDarwin) {
      home.packages = [pkgs.bleachbit];
    };
}
