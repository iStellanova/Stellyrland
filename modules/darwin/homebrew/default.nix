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
        "cava"
        "apple-music-discord-rpc"
      ];

      casks = [
        "antigravity"
        "dimentium/autoraise/autoraiseapp"
        "background-music"
        "balenaetcher"
        "bitwarden"
        "claude"
        "cleanmymac"
        "clion"
        "craft"
        "discord"
        "discord@canary"
        "discord@ptb"
        "firefox"
        "font-sf-pro"
        "gimp"
        "github"
        "google-drive"
        "google-earth-pro"
        "intellij-idea"
        "mactracker"
        "marta"
        "obs"
        "obsidian"
        "parallels"
        "prismlauncher"
        "pycharm"
        "quicken"
        "raycast"
        "steam"
        "utm"
        "visual-studio-code"
        "vlc"
        "webex"
        "zed"
        "zen"
        "zoom"
      ];

      masApps = {
        "Agenda" = 1287445660;
        "Beat" = 1549538329;
        "CleanMyMac" = 1339170533;
        "DaVinci Resolve" = 571213070;
        "Drafts" = 1435957248;
        "Dynamic wallpaper" = 1582358382;
        "Essayist" = 1537845384;
        "Friendly Streaming" = 553245401;
        "GarageBand" = 682658836;
        "iMovie" = 408981434;
        "Keynote" = 361285480;
        "Microsoft Excel" = 462058435;
        "Microsoft OneNote" = 784801555;
        "Microsoft Outlook" = 985367838;
        "Microsoft PowerPoint" = 462062816;
        "Microsoft Word" = 462054704;
        "Noizio Lite" = 1481029536;
        "Numbers" = 361304891;
        "OneDrive" = 823766827;
        "Pages" = 361309726;
        "School Assistant" = 1465687472;
        "Scrobbles for Last.fm" = 1344679160;
        "Speedtest" = 1153157709;
        "Xcode" = 497799835;
      };
    };
  };
}
