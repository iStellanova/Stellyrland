{
  den,
  sn,
  ...
}: {
  den.aspects.stellyrtop = {
    includes = [
      sn.nix-base
      den.batteries.hostname
      sn.system
      sn.terminal
      sn.dev
      sn.desktop
      sn.communication
      sn.av
      sn.gaming
      sn.productivity
      sn.maintenance
      sn.fastfetch
      sn.bitwarden
      sn.system-tools
      sn.protonvpn
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
