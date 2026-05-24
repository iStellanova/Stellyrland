_: {
  config = {
    # NixOS Maintenance Settings
    flake.modules.nixos.maintenance = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.maintenance.enable = lib.mkEnableOption "System maintenance tools";

      config = lib.mkIf config.aspects.programs.maintenance.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = [pkgs.bleachbit];
        };
      };
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
  };
}
