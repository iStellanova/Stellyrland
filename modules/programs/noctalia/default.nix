{inputs, ...}: {
  flake.modules.nixos.noctalia-shell = {lib, ...}: {
    options.desktop.noctalia = {
      primaryMonitor = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Primary monitor output name for Noctalia bar and notifications.";
      };
      secondaryMonitor = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Secondary monitor output name for Noctalia wallpaper sync.";
      };
    };
  };

  # Home Manager Noctalia Settings
  flake.modules.homeManager.noctalia-shell = {
    osConfig,
    lib,
    ...
  }: let
    wallpaperDir = "${osConfig.identity.homeDir}/Pictures/wallpapers";
    defaultWallpaper = "${wallpaperDir}/wallpaper.png";
    primary = osConfig.desktop.noctalia.primaryMonitor;
    secondary = osConfig.desktop.noctalia.secondaryMonitor;
    monitorSections =
      lib.optionalString (primary != "") "[wallpaper.monitors.${primary}]\npath = \"${defaultWallpaper}\"\n\n"
      + lib.optionalString (secondary != "") "[wallpaper.monitors.${secondary}]\npath = \"${defaultWallpaper}\"\n\n";
  in {
    imports = [
      inputs.noctalia-shell.homeModules.default
    ];

    config = {
      home.file = lib.mkIf (osConfig.identity.dataPath != null) {
        "Pictures/wallpapers/wallpaper.png".source = "${osConfig.identity.dataPath}/wallpapers/wallpaper.png";
      };

      home.activation.noctaliaWallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
                  state="$HOME/.local/state/noctalia/settings.toml"
                  if [ ! -f "$state" ]; then
                    mkdir -p "$(dirname "$state")"
                    cat > "$state" <<EOF
        [wallpaper.default]
        path = "${defaultWallpaper}"

        [wallpaper.last]
        path = "${defaultWallpaper}"

        ${monitorSections}EOF
                  fi
      '';

      systemd.user.services.noctalia.Service.RestartSec = "3s";

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        # General
        settings = {
          shell = {
            scale = 1.0;
            font = "JetBrainsMono Nerd Font";
            avatar_path = lib.optionalString (osConfig.identity.dataPath != null) "${osConfig.identity.dataPath}/icons/avatar.png";
            password_style = "random";
            settings_show_advanced = true;
            setup_wizard_enabled = false;
            polkit_agent = true;
            launch_apps_as_systemd_services = true;
            screen_time_enabled = true;
            panel = {
              transparency_mode = "glass";
              session_placement = "centered";
            };
            screen_corners.enabled = true;
            screenshot = {
              save_to_file = true;
              directory = "${osConfig.identity.homeDir}/Pictures/Screenshots";
              copy_to_clipboard = true;
            };
          };

          # Theme
          theme = {
            mode = "dark";
            builtin = "Catppuccin";
            community_palette = "Catppuccin Lavender";
            source = "community";
            templates = {
              builtin_ids = ["btop" "cava" "hyprland" "kitty" "helix"];
              community_ids = ["yazi"];
            };
          };

          # Wallpaper
          wallpaper = {
            enabled = true;
            directory = wallpaperDir;
            default.path = defaultWallpaper;
            last.path = defaultWallpaper;
            monitors =
              lib.optionalAttrs (primary != "") {"${primary}".path = defaultWallpaper;}
              // lib.optionalAttrs (secondary != "") {"${secondary}".path = defaultWallpaper;};
          };

          # Notifications, only showing on primary monitor.
          notification = {
            background_opacity = 0.5;
            monitors = lib.optional (primary != "") primary;
          };

          # Main Bar settings.
          bar.main = {
            enabled = false;
            monitor = lib.optionalAttrs (primary != "") {"${primary}".enabled = true;};
            position = "top";
            background_opacity = 0.5;
            center = ["media"];
            end = ["tray" "volume" "weather" "network" "temp" "cpu" "ram" "clock" "notifications"];
            margin_ends = 5;
            margin_edge = 5;
            start = ["launcher" "workspaces" "audio_visualizer" "active_window"];
            widget_spacing = 13;
          };

          lockscreen = {
            blur_intensity = 0.0;
          };

          lockscreen_widgets = {
            enabled = true;
            schema_version = 1;
            widget_order = [
              "lockscreen-login-box@${secondary}"
              "lockscreen-login-box@${primary}"
              "lockscreen-widget-0000000000000001"
              "lockscreen-widget-0000000000000002"
            ];
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = true;
            };
            widget = {
              "lockscreen-login-box@${primary}" = {
                cx = 1720.0;
                cy = 1317.0;
                output = primary;
                rotation = 0.0;
                scale = 1.0;
                type = "login_box";
              };
              "lockscreen-login-box@${secondary}" = {
                cx = 720.0;
                cy = 2437.0;
                output = secondary;
                rotation = 0.0;
                scale = 1.0;
                type = "login_box";
              };
              "lockscreen-widget-0000000000000001" = {
                cx = 324.521728515625;
                cy = 318.60870361328125;
                output = primary;
                rotation = 0.0;
                scale = 1.7391304969787598;
                type = "weather";
                settings = {
                  background = false;
                  shadow = false;
                };
              };
              "lockscreen-widget-0000000000000002" = {
                cx = 653.5;
                cy = 194.0;
                output = primary;
                rotation = 0.0;
                scale = 8.0;
                type = "label";
                settings = {
                  background = false;
                  color = "primary";
                  shadow = false;
                  title = "Stellyrland";
                };
              };
            };
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

          # Simple Visualizer
          widget = {
            audio_visualizer = {
              bands = 35;
              show_when_idle = true;
              width = 150.0;
            };
            # Clock formatted WKDY, DD/MM 12HR AM/PM
            clock.format = "{:%a, %b %d %I:%M %p}";
            cpu.display = "graph";
            launcher = {
              anchor = false;
              capsule = true;
              custom_image =
                if osConfig.identity.dataPath != null
                then "${osConfig.identity.dataPath}/icons/nix-snowflake-white.svg"
                else "";
              glyph = "brand-snowflake";
            };

            # Center Media Widget
            media = {
              capsule = false;
              title_scroll = "on_hover";
            };

            # No names necessary, but I like my graphs.
            network.show_label = false;
            ram.display = "graph";
            sysmon = {
              anchor = false;
              display = "graph";
              show_label = true;
              stat = "cpu_usage";
            };
            temp.display = "graph";
            volume.show_label = false;
            workspaces.display = "none";
          };

          # General widget configuration
          desktop_widgets = {
            enabled = false;
            schema_version = 1;
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = false;
            };
            widget = [
            ];
          };
        };
      };
    };
  };
}
