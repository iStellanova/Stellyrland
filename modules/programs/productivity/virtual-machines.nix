_: {
  config = {
    # NixOS Virtual Machines Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.virtual-machines.enable = lib.mkEnableOption "Virtual machine tools";

      config = lib.mkIf config.aspects.programs.virtual-machines.enable {
        virtualisation.libvirtd.enable = true;

        home-manager.users.${identity.name} = {
          home.packages = [pkgs.virt-manager];
        };
      };
    };

    # Darwin Virtual Machines Settings
    flake.modules.darwin.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.virtual-machines.enable = lib.mkEnableOption "Virtual machine tools";

      config = lib.mkIf config.aspects.programs.virtual-machines.enable {
        homebrew.casks = ["utm"];
      };
    };
  };
}
