{lib, ...}: {
  config = {
    # NixOS Core and Base Services configuration
    flake.modules.nixos.core = {config, ...}: {
      options.aspects.core = {
        enable = lib.mkEnableOption "Core system configuration";
        services-base.enable = lib.mkEnableOption "Base system services";
      };

      config = lib.mkMerge [
        (lib.mkIf config.aspects.core.enable {
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
        })

        (lib.mkIf config.aspects.core.services-base.enable {
          services.udisks2.enable = true;
          services.gvfs.enable = true;
          services.libinput.enable = true;
          services.gnome.gnome-keyring.enable = true;
          security.polkit.enable = true;
          networking.networkmanager.enable = true;
          programs.dconf.enable = true;
          services.dbus.implementation = "broker";

          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = false;
              KbdInteractiveAuthentication = false;
              PermitRootLogin = "no";
            };
          };

          networking.firewall = {
            enable = true;
            checkReversePath = "loose";
            allowedUDPPorts = [41641]; # Tailscale
            allowedUDPPortRanges = [
              {
                from = 50000;
                to = 65535;
              }
            ];
          };
        })
      ];
    };

    # Darwin Core and System Defaults configuration
    flake.modules.darwin.core = {config, ...}: {
      options.aspects = {
        core.enable = lib.mkEnableOption "Core system configuration";
        darwin.system.enable = lib.mkEnableOption "Darwin system configuration";
      };

      config = lib.mkMerge [
        (lib.mkIf config.aspects.core.enable {
          time.timeZone = "America/Indiana/Indianapolis";
        })

        (lib.mkIf config.aspects.darwin.system.enable {
          security.pam.services.sudo_local.touchIdAuth = true;
          system.primaryUser = config.identity.username;

          system.defaults = {
            dock.autohide = false;
            dock.mru-spaces = false;
            dock.orientation = "bottom";
            dock.show-recents = false;
            dock.static-only = false;
            dock.tilesize = 117;

            dock.persistent-apps = [
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
              "/Applications/Zed.app"
              "/Applications/Claude.app"
              "${config.identity.homeDir}/Applications/Home Manager Apps/kitty.app"
              "/Applications/Zen Browser.app"
            ];

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
        })
      ];
    };

    # Home Manager Core Settings
    flake.modules.homeManager.core = {osConfig, ...}:
      lib.mkIf (osConfig ? aspects.core && osConfig.aspects.core.enable) {
        home.username = osConfig.identity.username;
        home.homeDirectory = osConfig.identity.homeDir;
        home.stateVersion = "25.11";
        home.sessionPath = ["$HOME/.local/state/nix/profiles/scratch/bin"];
      };
  };
}
