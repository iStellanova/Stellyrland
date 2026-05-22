{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.background-sounds.enable = lib.mkEnableOption "Ambient background sound tools";

  config = lib.mkIf config.aspects.programs.background-sounds.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.masApps = {
        "Noizio Lite" = 1481029536;
      };
    })

    (lib.optionalAttrs (!isDarwin) {
      home-manager.users.${identity.name} = {
        home.packages = [pkgs.blanket];
      };
    })
  ]);
}
