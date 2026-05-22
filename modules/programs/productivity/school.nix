{
  nixosIdentity,
  darwinIdentity,
  ...
}: {
  config = {
    # NixOS School Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

      config = lib.mkIf config.aspects.programs.school.enable {
        home-manager.users.${nixosIdentity.name} = {
          home.packages = [pkgs.zoom-us];
        };
      };
    };

    # Darwin School Settings
    flake.modules.darwin.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

      config = lib.mkIf config.aspects.programs.school.enable {
        home-manager.users.${darwinIdentity.name} = {
          home.packages = [pkgs.zoom-us];
        };

        homebrew.masApps = {
          "School Assistant" = 1465687472;
        };
      };
    };
  };
}
