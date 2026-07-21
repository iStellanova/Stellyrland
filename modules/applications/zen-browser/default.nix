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
      # Home Manager's own app-linking is unreliable on macOS, so also
      # register at the system level for Spotlight/Launchpad.
      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.modules.homeManager.zen-browser =
    {
      config,
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

      # Unconditional: each imported file gates its own `config` with
      # `mkIf config.zenBrowser.personalize`. Using `config` here instead, to
      # pick which files to import, would be circular — config doesn't exist
      # yet while imports is still being assembled.
      imports = [
        inputs.zen-browser.homeModules.default
        (import ./_extensions.nix {
          inherit
            inputs
            pkgs
            config
            lib
            ;
        })
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
          # Reuses each OS's existing profile dir so HM doesn't orphan it
          # into a fresh one. Only valid for stellanova's own profiles.
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

          # Sine store slug is "Nebula" (capital, no "-zen" suffix) — a
          # wrong slug here fails silently at activation, not at build time.
          sine = {
            enable = true;
            mods = [ "Nebula" ];
          };

          search = {
            force = true; # re-assert on every rebuild
            default = "ddg";
          };
        };
      };
    };
}
