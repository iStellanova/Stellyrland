{
  lib,
  inputs,
  ...
}: {
  # NixOS Core and Base Services configuration
  flake.modules.nixos.core = _: {
    config = {
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
  };

  # Darwin Core and System Defaults configuration
  flake.modules.darwin.core = {config, ...}: {
    imports = [inputs.mac-app-util.darwinModules.default];

    options = {
      darwin.system = {
        enable = lib.mkEnableOption "Darwin system configuration";
        dockApps = lib.mkOption {
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
      };
    };

    config = {
      time.timeZone = "America/Indiana/Indianapolis";

      security.pam.services.sudo_local.touchIdAuth = true;
      system.primaryUser = config.identity.username;

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
        NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;

        trackpad.Clicking = true;
        trackpad.TrackpadThreeFingerDrag = true;

        menuExtraClock.ShowAMPM = true;
        menuExtraClock.ShowDate = 1;
        menuExtraClock.ShowDayOfWeek = true;
      };

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToControl = true;
    };
  };

  # Home Manager Core Settings
  flake.modules.homeManager.core = {osConfig, ...}: {
    home.username = osConfig.identity.username;
    home.homeDirectory = osConfig.identity.homeDir;
    home.stateVersion = "25.11";
    home.sessionPath = ["$HOME/.local/state/nix/profiles/scratch/bin"];
  };
}
