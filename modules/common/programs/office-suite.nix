{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.office-suite.enable = lib.mkEnableOption "Office suite";

  config = lib.mkIf config.aspects.programs.office-suite.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.masApps = {
        "Keynote" = 361285480;
        "Microsoft Excel" = 462058435;
        "Microsoft OneNote" = 784801555;
        "Microsoft Outlook" = 985367838;
        "Microsoft PowerPoint" = 462062816;
        "Microsoft Word" = 462054704;
        "Numbers" = 361304891;
        "Pages" = 361309726;
      };
    })

    (lib.optionalAttrs (!isDarwin) {
      home-manager.users.${identity.name} = {
        home.packages = [pkgs.freeoffice];
      };
    })
  ]);
}
