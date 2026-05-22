{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.virtual-machines.enable = lib.mkEnableOption "Virtual machine tools";

  config = lib.mkIf config.aspects.programs.virtual-machines.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["utm"];
    })

    (lib.optionalAttrs (!isDarwin) {
      virtualisation.libvirtd.enable = true;

      home-manager.users.${identity.name} = {
        home.packages = [pkgs.virt-manager];
      };
    })
  ]);
}
