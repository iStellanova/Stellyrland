{ inputs, ... }:
{
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  # rycee's Firefox-addon derivations, for _extensions.nix.
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.darwin.zen-browser =
    { pkgs, ... }:
    {
      # Register system-wide; Home Manager app-linking is unreliable on macOS.
      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.modules.nixos.zen-browser =
    { lib, host, ... }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [ ".config/zen" ];
      };
    };

  flake.modules.finix.zen-browser =
    { host, ... }:
    {
      preservation.preserveAt."/persist".users.${host.username}.directories = [
        ".config/zen"
      ];
    };

  flake.modules.homeManager.zen-browser =
    {
      config,
      osConfig,
      pkgs,
      lib,
      ...
    }:
    {
      options.zenBrowser.personalize = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Use stellanova's personalized Zen setup (Universal/School spaces,
          their pins, extensions, Sine mods, DuckDuckGo default) instead of a
          bare profile. Defaults to false for other users/hosts.
        '';
      };

      # Imports stay unconditional; child files gate themselves to avoid an import/config cycle.
      imports = [
        osConfig._module.args.inputs.zen-browser.homeModules.default
        ./_extensions.nix
        ./_spaces.nix
        ./universal/_essentials.nix
        ./universal/_pinned-tabs.nix
        ./school/_essentials.nix
        ./school/_pinned-tabs.nix
      ];

      config.programs.zen-browser = {
        enable = true;
      }
      // lib.optionalAttrs config.zenBrowser.personalize {
        profiles.default = {
          # Reuse each OS's profile directory; valid only for stellanova's profiles.
          path =
            if pkgs.stdenv.hostPlatform.isLinux then "0ubhpx7e.Default Profile" else "h7j9ua1w.Default Profile";

          settings = {
            "zen.workspaces.separate-essentials" = true;
            "extensions.autoDisableScopes" = 0;
            "extensions.enabledScopes" = 15;
            "extensions.startupScanScopes" = 15;
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            "widget.gtk.transparent-background" = true;
            "browser.tabs.allow_transparent_browser" = true;
            "zen.widget.linux.transparency" = true;
          };

          # Undeclared pins get removed on activation rather than left
          # dangling alongside their nix-declared replacement.
          pinsForce = true;
          pinsForceAction = "remove";

          search = {
            force = true; # re-assert on every rebuild
            default = "ddg";
          };
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          # Sine modifies the app bundle and breaks macOS code signing, so Linux-only.
          # "Nebula" is case-sensitive; a wrong slug fails silently at activation.
          sine = {
            enable = true;
            mods = [ "Nebula" ];
          };
        };
      };
    };
}
