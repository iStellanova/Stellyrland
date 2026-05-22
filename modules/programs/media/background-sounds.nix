{nixosIdentity, ...}: {
  config = {
    # NixOS Background Sounds Settings
    flake.modules.nixos.background-sounds = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.background-sounds.enable = lib.mkEnableOption "Ambient background sound tools";

      config = lib.mkIf config.aspects.programs.background-sounds.enable {
        home-manager.users.${nixosIdentity.name} = {
          home.packages = [pkgs.blanket];
        };
      };
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
  };
}
