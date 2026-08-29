{
  flake.modules.nixos.noctalia =
    {
      lib,
      host,
      ...
    }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist" = {
          directories = [ "/var/lib/noctalia-greeter" ];
          users.${host.username}.files = [
            {
              file = ".local/state/noctalia/screen_time.json";
              how = "symlink";
            }
            {
              file = ".local/state/noctalia/usage_counts.json";
              how = "symlink";
            }
            {
              file = ".local/state/noctalia/recently_used.json";
              how = "symlink";
            }
            {
              file = ".local/state/noctalia/notification_history.json";
              how = "symlink";
            }
          ];
        };
      };
    };

  flake.modules.homeManager.noctalia =
    {
      host,
      lib,
      ...
    }:
    let
      wallpaperDir = "${host.homeDir}/Pictures/wallpapers";
      defaultWallpaper = "${wallpaperDir}/wallpaper.png";
      monitorPriority = host.monitorPriority or [ ];
      primary = if monitorPriority == [ ] then "" else lib.elemAt monitorPriority 0;
      secondary = if lib.length monitorPriority < 2 then "" else lib.elemAt monitorPriority 1;
    in
    {
      imports = [
        ./_lockscreen.nix
      ];

      _module.args = { inherit primary secondary; };

      home.file = lib.mkIf (host.dataPath != null) {
        "Pictures/wallpapers/wallpaper.png".source = "${host.dataPath}/wallpapers/wallpaper.png";
      };

      systemd.user.services.noctalia.Service.RestartSec = "3s";

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings = {
          shell = {
            font_family = "JetBrainsMono Nerd Font";
            avatar_path = lib.optionalString (host.dataPath != null) "${host.dataPath}/icons/avatar.png";
            password_style = "random";
            setup_wizard_enabled = false;
            polkit_agent = true;
            launch_apps_as_systemd_services = true;
            screen_time_enabled = true;
            launcher.providers.session.global = true;
            panel = {
              transparency_mode = "glass";
              session_placement = "floating";
              session_position = "center";
            };
            screen_corners.enabled = true;
            screenshot = {
              directory = "${host.homeDir}/Pictures/Screenshots";
            };
          };

          theme = {
            builtin = "Catppuccin";
            community_palette = "Catppuccin Macchiato Lavender";
            source = "community";
            templates = {
              builtin_ids = [
                "btop"
                "cava"
                "hyprland"
                "kitty"
                "umbriel"
              ];
              community_ids = [
                "yazi"
                "hyprtoolkit"
              ];
            };
          };

          wallpaper = {
            enabled = true;
            directory = wallpaperDir;
            default.path = defaultWallpaper;
            last.path = defaultWallpaper;
            monitors =
              lib.optionalAttrs (primary != "") { "${primary}".path = defaultWallpaper; }
              // lib.optionalAttrs (secondary != "") { "${secondary}".path = defaultWallpaper; };
          };

          notification = {
            background_opacity = 0.5;
            monitors = lib.optional (primary != "") primary;
          };

          plugins.enabled = [
            "lucasoe/proton-pass"
            "avivbintangaringga/nix-monitor"
          ];

          plugin_settings."avivbintangaringga/nix-monitor" = {
            branch = "nixos-unstable";
            clean_command = "zsh -ic 'clean'";
            update_command = "zsh -ic 'upgrade'";
          };

          bar.main = {
            enabled = false;
            monitor = lib.optionalAttrs (primary != "") { "${primary}".enabled = true; };
            position = "top";
            background_opacity = 0.5;
            shadow = false;
            center = [ "media" ];
            end = [
              "tray"
              "nix-monitor"
              "weather"
              "network"
              "temp"
              "cpu"
              "ram"
              "clock"
              "clipboard"
              "notifications"
            ];
            margin_ends = 5;
            margin_edge = 5;
            start = [
              "launcher"
              "workspaces"
              "audio_visualizer"
              "active_window"
            ];
            widget_spacing = 13;
          };

          idle = {
            behavior."lock" = {
              timeout = 900;
              command = "noctalia:session lock";
              enabled = true;
            };
            behavior."screen-off" = {
              timeout = 3600;
              command = "noctalia:dpms-off";
              resume_command = "noctalia:dpms-on";
              enabled = true;
            };
          };

          location.auto_locate = true;

          # AMERICAN UNITS RAAAGH
          weather.unit = "imperial";

          widget = {
            audio_visualizer = {
              bands = 35;
              show_when_idle = true;
              width = 150.0;
            };
            # Clock format: Wkdy, Mon DD 12hr am/pm
            clock.format = "{:%a, %b %d %I:%M %p}";
            cpu = {
              visualization = "graph";
              show_value = true;
            };
            launcher = {
              anchor = false;
              capsule = true;
              custom_image =
                if host.dataPath != null then "${host.dataPath}/icons/nix-snowflake-white.svg" else "";
              glyph = "brand-snowflake";
            };

            media = {
              title_scroll = "on_hover";
            };

            network.show_label = false;
            nix-monitor.type = "avivbintangaringga/nix-monitor:nix-monitor";
            ram = {
              visualization = "graph";
              show_value = true;
            };
            temp = {
              visualization = "graph";
              show_value = true;
            };
            volume.show_label = false;
            workspaces = {
              show_labels = false;
              focused_color = "primary";
              occupied_color = "secondary";
              empty_color = "tertiary";
              urgent_color = "error";
            };
          };

        };
      };
    };
}
