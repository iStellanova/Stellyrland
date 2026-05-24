_: {
  config = {
    # NixOS School Settings
    flake.modules.nixos.school = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

      config = lib.mkIf config.aspects.programs.school.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = [pkgs.zoom-us];
        };
      };
    };

    # Darwin School Settings
    flake.modules.darwin.school = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

      config = lib.mkIf config.aspects.programs.school.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = [pkgs.zoom-us];
        };

        homebrew.masApps = {
          "School Assistant" = 1465687472;
        };
      };
    };
  };
}
