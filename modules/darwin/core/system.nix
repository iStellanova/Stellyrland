{ config, lib, identity, ... }:

{
  options.aspects.darwin.system.enable = lib.mkEnableOption "Darwin system configuration";

  config = lib.mkIf config.aspects.darwin.system.enable {
    # Networking
    networking.computerName = "Stellyrtop";
    networking.hostName = "stellyrtop";
    networking.localHostName = "stellyrtop";

    # Security
    security.pam.services.sudo_local.touchIdAuth = true;

    # System Defaults (Matched to current system settings)
    system.defaults = {
      # Dock
      dock.autohide = false;
      dock.mru-spaces = false;
      dock.orientation = "bottom";
      dock.show-recents = false;
      dock.static-only = false;
      dock.tilesize = 117;

      # Persistent Apps in Dock
      dock.persistent-apps = [
        "/System/Applications/App Store.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Passwords.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Stickies.app"
        "/Applications/DaVinci Resolve/DaVinci Resolve.app"
        "/Applications/Craft.app"
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
        "/Applications/IntelliJ IDEA.app"
        "/Applications/Beat.app"
        "/Applications/Zed.app"
        "/Applications/Claude.app"
        "/Applications/Nix Apps/Vesktop.app"
        "${identity.home}/Applications/Home Manager Apps/kitty.app"
        "/Applications/Zen Browser.app"
      ];

      # Finder
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "Nlsv";
      finder.AppleShowAllFiles = true;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = false;
      finder._FXShowPosixPathInTitle = true;

      # Login Window
      loginwindow.GuestEnabled = false;
      loginwindow.SHOWFULLNAME = true;

      # NSGlobalDomain
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      NSGlobalDomain.AppleKeyboardUIMode = 3;
      NSGlobalDomain.AppleMeasurementUnits = "Inches";
      NSGlobalDomain.AppleMetricUnits = 0;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleTemperatureUnit = "Fahrenheit";

      # Keyboard/Trackpad Performance (Matched to current defaults)
      NSGlobalDomain.InitialKeyRepeat = 25;
      NSGlobalDomain.KeyRepeat = 2;
      NSGlobalDomain."com.apple.swipescrolldirection" = true;
      NSGlobalDomain."com.apple.mouse.tapBehavior" = 1; # Tap to click

      # Trackpad specific
      trackpad.Clicking = true;
      trackpad.TrackpadThreeFingerDrag = true;

      # Clock & Menu Bar
      menuExtraClock.ShowAMPM = true;
      menuExtraClock.ShowDate = 1;
      menuExtraClock.ShowDayOfWeek = true;
    };

    # System-wide keyboard mapping
    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToControl = true;
  };
}
