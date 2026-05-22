_: {
  config = {
    # NixOS Maintenance Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.maintenance.enable = lib.mkEnableOption "System maintenance tools";

      config = lib.mkIf config.aspects.programs.maintenance.enable {
        home-manager.users.${identity.name} = {
          home.packages = [pkgs.bleachbit];
        };
      };
    };

    # Darwin Maintenance Settings
    flake.modules.darwin.default = {
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
