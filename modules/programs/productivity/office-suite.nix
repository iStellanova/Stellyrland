_: {
  # NixOS Office Suite Settings
  flake.modules.nixos.office-suite = {pkgs, ...}: {
    config = {
      environment.systemPackages = [pkgs.freeoffice];
    };
  };

  # Darwin Office Suite Settings
  flake.modules.darwin.office-suite = _: {
    config = {
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
}
