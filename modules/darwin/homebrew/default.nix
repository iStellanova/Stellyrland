{
  config,
  lib,
  ...
}: {
  options.aspects.darwin.homebrew.enable = lib.mkEnableOption "Darwin homebrew configuration";

  config = lib.mkIf config.aspects.darwin.homebrew.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };

      casks = [
        "background-music" # Background music
        "balenaetcher" # Balena Etcher
        "cleanmymac" # CleanMyMac
        "craft" # Craft - Notes Application
        "font-sf-pro" # SF Pro font
        "gimp" # GIMP - Image Editor
        "github" # GitHub Desktop
        "google-drive" # Google Drive
        "quicken" # Quicken
        "utm" # UTM - Virtual Machine Manager
        "webex" # WebEx
        "zoom" # Zoom
      ];

      masApps = {
        "Agenda" = 1287445660; # Agenda - Task management
        "Beat" = 1549538329; # Beat - Manuscripter
        "Dynamic wallpaper" = 1582358382; # Dynamic wallpaper - Wallpaper manager
        "Essayist" = 1537845384; # Essayist - Writing assistant
        "OneDrive" = 823766827; # OneDrive - Cloud storage
        "School Assistant" = 1465687472; # School Assistant - School management
        "Xcode" = 497799835; # Xcode - Apple IDE
      };
    };
  };
}
