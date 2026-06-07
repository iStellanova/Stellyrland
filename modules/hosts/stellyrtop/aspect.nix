{den, ...}: {
  den.aspects.stellyrtop = {
    includes = [
      den.aspects.core
      den.aspects.nix-settings
      den.batteries.hostname
      den.aspects.networking
      den.aspects.users
      den.aspects.fonts
      den.aspects.homebrew
      den.aspects.services-base
      den.aspects.aerospace
      den.aspects.aesthetic
      den.aspects.vesktop
      den.aspects.nix-index
      den.aspects.ai-tools
      den.aspects.kitty
      den.aspects.ns
      den.aspects.ide-suite
      den.aspects.cli
      den.aspects.helix
      den.aspects.git
      den.aspects.yazi
      den.aspects.zed
      den.aspects.gaming
      den.aspects.background-sounds
      den.aspects.media-editing
      den.aspects.cava
      den.aspects.media
      den.aspects.office-suite
      den.aspects.school
      den.aspects.virtual-machines
      den.aspects.finance
      den.aspects.writing
      den.aspects.cloud-storage
      den.aspects.utils
      den.aspects.maintenance
      den.aspects.btop
      den.aspects.fastfetch
      den.aspects.bitwarden
      den.aspects.browser
      den.aspects.zsh
      den.aspects.discord-music-rpc
    ];

    darwin = {host, ...}: {
      system.stateVersion = 5;

      networking = {
        computerName = "Stellyrtop";
        localHostName = host.name;
      };

      darwin.system.dockApps = [
        "/System/Applications/App Store.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Passwords.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Stickies.app"
        "/Applications/DaVinci Resolve/DaVinci Resolve.app"
        "/Applications/Quicken.app"
        "/Applications/Microsoft Word.app"
        "/Applications/Microsoft PowerPoint.app"
        "/Applications/Microsoft Excel.app"
        "/Applications/Microsoft OneNote.app"
        "/Applications/Microsoft Outlook.app"
        "/Applications/School Assistant.app"
        "/System/Applications/Books.app"
        "/Applications/Pages Creator Studio.app"
        "/Applications/Keynote Creator Studio.app"
        "/Applications/Numbers Creator Studio.app"
        "/System/Applications/Music.app"
        "/Applications/Antigravity.app"
        "/Applications/Beat.app"
        "/Applications/Claude.app"
        "/Users/stellanova/Applications/Home Manager Apps/kitty.app"
        "/Applications/Zen Browser.app"
      ];
    };
  };
}
