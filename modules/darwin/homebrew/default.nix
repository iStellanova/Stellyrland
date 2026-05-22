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
        "craft" # Craft - Notes Application
        "gimp" # GIMP - Image Editor
        "quicken" # Quicken
        "webex" # WebEx
        "zoom" # Zoom
      ];

      masApps = {
        "Dynamic wallpaper" = 1582358382; # Dynamic wallpaper - Wallpaper manager
        "School Assistant" = 1465687472; # School Assistant - School management
        "Xcode" = 497799835; # Xcode - Apple IDE
      };
    };
  };
}
