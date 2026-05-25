_: {
  # NixOS School Settings
  flake.modules.nixos.school = {lib, ...}: {
    options.aspects.programs.school.enable = lib.mkEnableOption "School tools";
  };

  # Darwin School Settings
  flake.modules.darwin.school = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

    config = lib.mkIf config.aspects.programs.school.enable {
      homebrew.masApps = {
        "School Assistant" = 1465687472;
      };
    };
  };

  # Home Manager School Settings
  flake.modules.homeManager.school = {
    osConfig,
    pkgs,
    lib,
    ...
  }:
    lib.mkIf (osConfig ? aspects.programs.school && osConfig.aspects.programs.school.enable) {
      home.packages = [pkgs.zoom-us];
    };
}
