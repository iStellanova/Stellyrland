{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.school.enable = lib.mkEnableOption "School tools";

  config = lib.mkIf config.aspects.programs.school.enable (lib.mkMerge [
    {
      home-manager.users.${identity.name} = {
        home.packages = [pkgs.zoom-us];
      };
    }

    (lib.optionalAttrs isDarwin {
      homebrew.masApps = {
        "School Assistant" = 1465687472;
      };
    })
  ]);
}
