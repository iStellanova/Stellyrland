_: {
  config = {
    # NixOS School Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

      config = lib.mkIf config.aspects.programs.school.enable {
        home-manager.users.${identity.name} = {
          home.packages = [pkgs.zoom-us];
        };
      };
    };

    # Darwin School Settings
    flake.modules.darwin.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

      config = lib.mkIf config.aspects.programs.school.enable {
        home-manager.users.${identity.name} = {
          home.packages = [pkgs.zoom-us];
        };

        homebrew.masApps = {
          "School Assistant" = 1465687472;
        };
      };
    };
  };
}
