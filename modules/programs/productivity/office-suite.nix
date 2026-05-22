{nixosIdentity, ...}: {
  config = {
    # NixOS Office Suite Settings
    flake.modules.nixos.office-suite = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.office-suite.enable = lib.mkEnableOption "Office suite";

      config = lib.mkIf config.aspects.programs.office-suite.enable {
        home-manager.users.${nixosIdentity.name} = {
          home.packages = [pkgs.freeoffice];
        };
      };
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
  };
}
