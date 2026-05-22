{nixosIdentity, ...}: {
  config = {
    # NixOS Maintenance Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.maintenance.enable = lib.mkEnableOption "System maintenance tools";

      config = lib.mkIf config.aspects.programs.maintenance.enable {
        home-manager.users.${nixosIdentity.name} = {
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
