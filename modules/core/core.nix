{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.mac-app-util.url = "github:hraban/mac-app-util";

  den.aspects.core.nixos = _: {
    time.timeZone = "America/Indianapolis";
    i18n.defaultLocale = "en_US.UTF-8";

    security.sudo-rs = {
      enable = true;
      extraConfig = "Defaults pwfeedback";
    };

    system.stateVersion = "25.11";
    programs.ssh.startAgent = true;
    services.gnome.gcr-ssh-agent.enable = false;
    systemd.oomd.enable = true;
    systemd.services."systemd-udevd".serviceConfig = {
      TimeoutStartSec = "10s";
      TimeoutStopSec = "10s";
    };
  };

  den.aspects.core.darwin = {
    host,
    config,
    ...
  }: {
    imports =
      if inputs ? mac-app-util
      then [inputs.mac-app-util.darwinModules.default]
      else [];

    options.darwin.system.dockApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/System/Applications/App Store.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Passwords.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Music.app"
        "/Applications/Zen Browser.app"
      ];
      description = "Persistent applications in the macOS Dock";
    };

    config = {
      time.timeZone = "America/Indiana/Indianapolis";

      security.pam.services.sudo_local.touchIdAuth = true;

      system.defaults = {
        dock.autohide = false;
        dock.mru-spaces = false;
        dock.orientation = "bottom";
        dock.show-recents = false;
        dock.static-only = false;
        dock.tilesize = 117;

        dock.persistent-apps = config.darwin.system.dockApps;

        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "Nlsv";
        finder.AppleShowAllFiles = true;
        finder.ShowPathbar = true;
        finder.ShowStatusBar = false;
        finder._FXShowPosixPathInTitle = true;

        loginwindow.GuestEnabled = false;
        loginwindow.SHOWFULLNAME = true;

        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.AppleKeyboardUIMode = 3;
        NSGlobalDomain.AppleMeasurementUnits = "Inches";
        NSGlobalDomain.AppleMetricUnits = 0;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleTemperatureUnit = "Fahrenheit";

        NSGlobalDomain.InitialKeyRepeat = 25;
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain."com.apple.swipescrolldirection" = true;

        trackpad.Clicking = false;
        trackpad.TrackpadThreeFingerDrag = false;
        trackpad.TrackpadThreeFingerHorizSwipeGesture = 0;

        menuExtraClock.ShowAMPM = true;
        menuExtraClock.ShowDate = 1;
        menuExtraClock.ShowDayOfWeek = true;
      };

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;

      system.activationScripts.postActivation.text = lib.mkAfter ''
        sudo -u ${host.username} defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
        sudo -u ${host.username} defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };
  };

  # home.username and homeDirectory are set in the stellanova user aspect.
  # home.stateVersion is applied universally via den.default in schema.nix.
  den.aspects.core.homeManager = _: {
    home.sessionPath = ["$HOME/.local/state/nix/profiles/scratch/bin"];
  };
}
