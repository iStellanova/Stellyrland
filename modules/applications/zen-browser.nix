{ inputs, ... }:
{
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  # rycee's Firefox-addon derivations, for extensions.packages below.
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.darwin.zen-browser =
    { pkgs, ... }:
    {
      # Home Manager's own app-linking is unreliable on macOS, so also
      # register at the system level for Spotlight/Launchpad. Doesn't dedupe
      # with the homeManager package below (mkFirefoxModule always re-wraps),
      # but the large shared bits (the actual binary) still content-dedupe.
      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.modules.homeManager.zen-browser =
    { pkgs, lib, ... }:
    {
      imports = [ inputs.zen-browser.homeModules.default ];

      programs.zen-browser = {
        enable = true;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        profiles.default = {
          # Existing profile dir, so HM doesn't orphan it into a fresh one.
          path = "0ubhpx7e.Default Profile";

          settings = {
            "widget.gtk.transparent-background" = true;
            "browser.tabs.allow_transparent_browser" = true;
            "zen.widget.linux.transparency" = true;
          };

          # Matches desktop/catppuccin.nix's system-wide flavor/accent.
          presets.catppuccin = {
            enable = true;
            flavor = "Macchiato";
            accent = "Sapphire";
          };

          userChrome = ''
            @import "catppuccin/userChrome.css";

            /* Layered on top of Catppuccin above. Requires gtk.transparent-background. */

            /* Tint the window frame for a uniform glass look. */
            :root, #main-window {
              background-color: rgba(36, 39, 58, 0.6) !important;
            }

            /* Let wrappers/sidebar inherit the tint instead of painting their own bg. */
            #browser, #zen-main-app-wrapper, #zen-appcontent-wrapper,
            #navigator-toolbox, .browser-toolbox-background {
              background: transparent !important;
              background-color: transparent !important;
            }

            /* Keep page content opaque. */
            #appcontent, #tabbrowser-tabpanels, browser {
              background-color: var(--zen-main-browser-background) !important;
            }

            /* Zen's own overlay divs paint over the sidebar — drop them. */
            #zen-browser-background, #zen-toolbar-background,
            .zen-browser-generic-background, .zen-tol-background {
              display: none !important;
            }

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

            /* Hide splitter visually; opacity keeps it grabbable for resizing. */
            #zen-sidebar-splitter {
              background: transparent !important;
              background-color: transparent !important;
              opacity: 0 !important;
            }
          '';

          extensions.packages =
            let
              rycee = inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons;
            in
            [
              rycee.ublock-origin
              rycee.sponsorblock
              rycee.proton-pass

              # Not on NUR — fetched from AMO. fixedExtid keeps the addon id
              # stable so it lands as the same install, not a duplicate.
              (pkgs.fetchFirefoxAddon {
                name = "xcancel-redirect";
                url = "https://addons.mozilla.org/firefox/downloads/file/4480430/xcancelredirect-1.2.xpi";
                sha256 = "sha256-sCMdx9SiZxynTPclc++fQ7jHNNbu4EV6vjbhDwHk7SA=";
                fixedExtid = "{99f59414-6b9c-4ba2-8706-4b018bc10bdc}";
              })
            ];
        };
      };
    };
}
