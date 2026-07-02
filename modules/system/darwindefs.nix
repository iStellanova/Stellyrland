{
  sn,
  inputs,
  lib,
  ...
}:
{
  sn.system = {
    includes = [ sn.darwindefs ];
  };

  # Deliberately not following our nixpkgs: mac-app-util pins an exact old
  # nixpkgs revision because its Common Lisp/SBCL build (docktuil) is
  # version-sensitive and breaks under a newer nixpkgs. Do not add
  # `inputs.nixpkgs.follows` here.
  flake-file.inputs.mac-app-util = {
    url = "github:hraban/mac-app-util";
  };

  sn.darwindefs.darwin =
    {
      host,
      config,
      ...
    }:
    {
      imports = [ inputs.mac-app-util.darwinModules.default ];

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
        # mac-app-util's frozen nixpkgs pin (and its own nixpkgs.lib fork) still
        # use syntax our own up-to-date nixpkgs has already dropped (`or` as an
        # identifier, old-style string escapes), which Lix's newer parser now
        # warns about. Scoped here, not in nix-settings.nix, since nothing else
        # in this repo still triggers these.
        # TODO: revisit next time mac-app-util or lix-module is bumped (added
        # 2026-07-01) — drop this once mac-app-util's pin catches up, or once Lix
        # removes the opt-back-in flag, whichever comes first.
        nix.settings.extra-deprecated-features = [
          "or-as-identifier"
          "broken-string-indentation"
          "broken-string-escape"
        ];

        # Canonical zoneinfo path, not the "America/Indianapolis" legacy alias used on
        # the NixOS host — macOS's systemsetup only accepts the canonical form.
        time.timeZone = "America/Indiana/Indianapolis";

        security.pam.services.sudo_local.touchIdAuth = true;

        system.defaults = {
          dock.autohide = true;
          dock.mru-spaces = false;
          dock.orientation = "bottom";
          dock.show-recents = false;
          dock.static-only = false;
          dock.tilesize = 117;
          dock.minimize-to-application = true;
          dock.mineffect = "scale";

          dock.persistent-apps = config.darwin.system.dockApps;

          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "Nlsv";
          finder.AppleShowAllFiles = true;
          finder.ShowPathbar = true;
          finder.ShowStatusBar = false;
          finder._FXShowPosixPathInTitle = true;
          finder._FXSortFoldersFirst = true;
          finder.FXDefaultSearchScope = "SCcf";
          finder.FXEnableExtensionChangeWarning = false;
          finder.FXRemoveOldTrashItems = true;
          finder.NewWindowTarget = "Home";
          finder.QuitMenuItem = true;

          loginwindow.GuestEnabled = false;
          loginwindow.SHOWFULLNAME = true;

          screencapture.location = "/Users/${host.username}/Pictures/Screenshots";
          screencapture.disable-shadow = true;
          screencapture.show-thumbnail = false;

          NSGlobalDomain.AppleInterfaceStyle = "Dark";
          NSGlobalDomain.AppleKeyboardUIMode = 3;
          NSGlobalDomain.AppleMeasurementUnits = "Inches";
          NSGlobalDomain.AppleMetricUnits = 0;
          NSGlobalDomain.AppleShowAllExtensions = true;
          NSGlobalDomain.AppleTemperatureUnit = "Fahrenheit";
          NSGlobalDomain.AppleFontSmoothing = 1;

          # Required for InitialKeyRepeat/KeyRepeat to actually fire (disables accent char popup)
          NSGlobalDomain.ApplePressAndHoldEnabled = false;
          NSGlobalDomain.InitialKeyRepeat = 25;
          NSGlobalDomain.KeyRepeat = 2;
          NSGlobalDomain."com.apple.swipescrolldirection" = true;

          NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
          NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
          NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
          NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
          NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
          NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
          NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;

          NSGlobalDomain.NSWindowShouldDragOnGesture = true;
          NSGlobalDomain.AppleSpacesSwitchOnActivate = false;
          NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
          NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
          NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;

          # Catppuccin Macchiato sapphire accent (closest named: Blue = 4)
          # Also tints folder icons on macOS Sequoia+
          CustomUserPreferences."NSGlobalDomain" = {
            AppleAccentColor = 4;
            AppleHighlightColor = "0.490196 0.768627 0.894118 Other";
          };

          trackpad.Clicking = false;
          trackpad.TrackpadThreeFingerDrag = false;
          trackpad.TrackpadThreeFingerHorizSwipeGesture = 0;
          trackpad.TrackpadFourFingerHorizSwipeGesture = 2;

          menuExtraClock.ShowAMPM = true;
          menuExtraClock.ShowDate = 1;
          menuExtraClock.ShowDayOfWeek = true;
        };

        system.keyboard.enableKeyMapping = true;
        system.keyboard.remapCapsLockToControl = true;

        system.activationScripts.postActivation.text = lib.mkAfter ''
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
      };
    };
}
