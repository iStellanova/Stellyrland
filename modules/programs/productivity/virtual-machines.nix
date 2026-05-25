_: {
  config = {
    # NixOS Virtual Machines Settings
    flake.modules.nixos.virtual-machines = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.virtual-machines.enable = lib.mkEnableOption "Virtual machine tools";

      config = lib.mkIf config.aspects.programs.virtual-machines.enable {
        virtualisation.libvirtd.enable = true;
      };
    };

    # Darwin Virtual Machines Settings
    flake.modules.darwin.virtual-machines = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.virtual-machines.enable = lib.mkEnableOption "Virtual machine tools";

      config = lib.mkIf config.aspects.programs.virtual-machines.enable {
        homebrew.casks = ["utm"];
      };
    };

    # Home Manager Virtual Machines Settings
    flake.modules.homeManager.virtual-machines = {
      osConfig,
      pkgs,
      lib,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.virtual-machines && osConfig.aspects.programs.virtual-machines.enable && !isDarwin) {
        home.packages = [pkgs.virt-manager];
      };
  };
}
