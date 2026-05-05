{ config, lib, ... }:

{
  options.aspects.darwin.homebrew.enable = lib.mkEnableOption "Darwin homebrew configuration";

  config = lib.mkIf config.aspects.darwin.homebrew.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };

      taps = [
        "nextfire/tap"
        "dimentium/autoraise"
        "felixkratz/formulae"
        "nikitabobko/tap"
      ];

      brews = [
        "cava"                                 # Audio visualization
        "apple-music-discord-rpc"              # Discord RPC for Apple Music
      ];

      casks = [
        "antigravity"                          # Antigravity IDE
        "dimentium/autoraise/autoraiseapp"     # Auto-raise
        "background-music"                     # Background music
        "balenaetcher"                        # Balena Etcher
        "bitwarden"                           # Bitwarden
        "claude"                              # Claude
        "cleanmymac"                          # CleanMyMac
        "clion"                               # IntelliJ CLion
        "craft"                               # Craft - Notes Application
        "discord"                             # Discord
        "font-sf-pro"                         # SF Pro font
        "gimp"                                # GIMP - Image Editor
        "github"                              # GitHub Desktop
        "google-drive"                        # Google Drive
        "intellij-idea"                       # IntelliJ IDEA
        "mactracker"                          # MacTracker - Mac Information
        "obs"                                 # OBS Studio
        "prismlauncher"                       # Prism Launcher
        "pycharm"                             # IntelliJ PyCharm - Python IDE
        "quicken"                             # Quicken
        "steam"                               # Steam
        "utm"                                 # UTM - Virtual Machine Manager
        "vlc"                                 # VLC
        "webex"                               # WebEx
        "zed"                                 # Zed
        "zen"                                 # Zen
        "zoom"                                # Zoom
      ];

      masApps = {
        "Agenda" = 1287445660;                # Agenda - Task management
        "Beat" = 1549538329;                  # Beat - Manuscripter
        "DaVinci Resolve" = 571213070;        # DaVinci Resolve - Video editing
        "Dynamic wallpaper" = 1582358382;     # Dynamic wallpaper - Wallpaper manager
        "Essayist" = 1537845384;              # Essayist - Writing assistant
        "GarageBand" = 682658836;             # GarageBand - Music production
        "iMovie" = 408981434;                 # iMovie - Movie editing
        "Keynote" = 361285480;                # Keynote - Presentation software
        "Microsoft Excel" = 462058435;        # Microsoft Excel - Spreadsheet software
        "Microsoft OneNote" = 784801555;      # Microsoft OneNote - Note-taking
        "Microsoft Outlook" = 985367838;      # Microsoft Outlook - Email client
        "Microsoft PowerPoint" = 462062816;   # Microsoft PowerPoint - Presentation software
        "Microsoft Word" = 462054704;         # Microsoft Word - Word processing software
        "Noizio Lite" = 1481029536;           # Noizio Lite - White Noise
        "Numbers" = 361304891;                # Numbers - Spreadsheet software
        "OneDrive" = 823766827;               # OneDrive - Cloud storage
        "Pages" = 361309726;                  # Pages - Word processing software
        "School Assistant" = 1465687472;      # School Assistant - School management
        "Xcode" = 497799835;                  # Xcode - Apple IDE
      };
    };
  };
}
