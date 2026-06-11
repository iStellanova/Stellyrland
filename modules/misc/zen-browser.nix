{
  inputs,
  ...
}: let
  browserOptions = lib: {
    enable = lib.mkEnableOption "Zen Browser";
    profileId = lib.mkOption {
      type = lib.types.str;
      default = "0ubhpx7e";
      description = "Zen profile directory ID (the hash before .Default Profile)";
    };
  };
in {
  flake-file.inputs.zen-browser.url = "github:youwen5/zen-browser-flake";

  sn.zen-browser.nixos = {lib, ...}: {
    options.programs.zen-browser = browserOptions lib;
  };

  sn.zen-browser.darwin = {lib, ...}: {
    options.programs.zen-browser = browserOptions lib;
    config = {
      homebrew.casks = ["zen"];
    };
  };

  sn.zen-browser.homeManager = {
    osConfig,
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optionals (!pkgs.stdenv.isDarwin) [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.file = lib.mkIf (!pkgs.stdenv.isDarwin) (let
      profile = "${osConfig.programs.zen-browser.profileId}.Default Profile";
    in {
      ".config/zen/${profile}/user.js".text = ''
        user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
        user_pref("widget.gtk.transparent-background", true);
        user_pref("browser.tabs.allow_transparent_browser", true);
        user_pref("zen.widget.linux.transparency", true);
      '';

      ".config/zen/${profile}/chrome/userChrome.css".text = ''
        /* Zen Browser — Translucent Sidebar
         * Requires: widget.gtk.transparent-background = true in user.js */

        /* 1. Tint the entire window frame (sidebar, gap, and chrome) for a uniform glass look. */
        :root, #main-window {
          background-color: rgba(36, 39, 58, 0.6) !important; /* Catppuccin Macchiato Base with glass transparency */
        }

        /* 2. Make all wrappers, sidebar, and content chrome transparent so they inherit the window tint without double-layering. */
        #browser, #zen-main-app-wrapper, #zen-appcontent-wrapper,
        #navigator-toolbox, .browser-toolbox-background {
          background: transparent !important;
          background-color: transparent !important;
        }

        /* 3. Keep webpage content area completely opaque. */
        #appcontent, #tabbrowser-tabpanels, browser {
          background-color: #1e2030 !important; /* Catppuccin Macchiato Mantle */
        }

        /* 4. Remove Zen's background overlay divs — these painted over the sidebar. */
        #zen-browser-background, #zen-toolbar-background,
        .zen-browser-generic-background, .zen-tol-background {
          display: none !important;
        }

        /* 5. Remove all borders, outlines, and box-shadows across all main UI components. */
        #navigator-toolbox,
        #zen-appcontent-wrapper,
        #zen-sidebar-splitter,
        #tabbrowser-tabpanels,
        #appcontent,
        browser {
          border: none !important;
          outline: none !important;
          box-shadow: none !important;
        }

        /* 6. Hide splitter visually — opacity keeps it functional and grabbable for resizing. */
        #zen-sidebar-splitter {
          background: transparent !important;
          background-color: transparent !important;
          opacity: 0 !important;
        }
      '';
    });
  };
}
