_: {
  den.aspects.office-suite.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.freeoffice];
  };

  den.aspects.office-suite.darwin = _: {
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
}
