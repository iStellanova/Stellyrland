_: {
  config = {
    # NixOS Background Sounds Settings
    flake.modules.nixos.background-sounds = {lib, ...}: {
      options.aspects.programs.background-sounds.enable = lib.mkEnableOption "Ambient background sound tools";
    };

    # Darwin Background Sounds Settings
    flake.modules.darwin.background-sounds = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.background-sounds.enable = lib.mkEnableOption "Ambient background sound tools";

      config = lib.mkIf config.aspects.programs.background-sounds.enable {
        homebrew.masApps = {
          "Noizio Lite" = 1481029536;
        };
      };
    };

    # Home Manager Background Sounds Settings
    flake.modules.homeManager.background-sounds = {
      osConfig,
      pkgs,
      lib,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.background-sounds && osConfig.aspects.programs.background-sounds.enable && !isDarwin) {
        home.packages = [pkgs.blanket];
      };
  };
}
