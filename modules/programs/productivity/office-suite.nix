_: {
  # NixOS Office Suite Settings
  flake.modules.nixos.office-suite = {lib, ...}: {
    options.aspects.programs.office-suite.enable = lib.mkEnableOption "Office suite";
  };

  # Darwin Office Suite Settings
  flake.modules.darwin.office-suite = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.office-suite.enable = lib.mkEnableOption "Office suite";

    config = lib.mkIf config.aspects.programs.office-suite.enable {
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
    };
  };

  # Home Manager Office Suite Settings
  flake.modules.homeManager.office-suite = {
    osConfig,
    pkgs,
    lib,
    ...
  }: let
    isDarwin = osConfig ? system.defaults;
  in
    lib.mkIf (osConfig ? aspects.programs.office-suite && osConfig.aspects.programs.office-suite.enable && !isDarwin) {
      home.packages = [pkgs.freeoffice];
    };
}
