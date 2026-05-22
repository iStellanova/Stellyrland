{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.maintenance.enable = lib.mkEnableOption "System maintenance tools";

  config = lib.mkIf config.aspects.programs.maintenance.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["cleanmymac"];
    })

    (lib.optionalAttrs (!isDarwin) {
      home-manager.users.${identity.name} = {
        home.packages = [pkgs.bleachbit];
      };
    })
  ]);
}
