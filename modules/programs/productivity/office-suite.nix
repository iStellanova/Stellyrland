_: {
  config = {
    # NixOS Office Suite Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.office-suite.enable = lib.mkEnableOption "Office suite";

      config = lib.mkIf config.aspects.programs.office-suite.enable {
        home-manager.users.${identity.name} = {
          home.packages = [pkgs.freeoffice];
        };
      };
    };

    # Darwin Office Suite Settings
    flake.modules.darwin.default = {
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
  };
}
