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
        "craft" # Craft - Notes Application
        "gimp" # GIMP - Image Editor
        "github" # GitHub Desktop
        "quicken" # Quicken
        "webex" # WebEx
        "zoom" # Zoom
      ];

      masApps = {
        "Agenda" = 1287445660; # Agenda - Task management
        "Beat" = 1549538329; # Beat - Manuscripter
        "Dynamic wallpaper" = 1582358382; # Dynamic wallpaper - Wallpaper manager
        "Essayist" = 1537845384; # Essayist - Writing assistant
        "School Assistant" = 1465687472; # School Assistant - School management
        "Xcode" = 497799835; # Xcode - Apple IDE
      };
    };
  };
}
