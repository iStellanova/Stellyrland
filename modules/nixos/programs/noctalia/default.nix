{
  config,
  lib,
  identity,
  ...
}: let
  defaultWallpaper = "${identity.home}/Pictures/wallpapers/static/Untitled.png";
in {
  options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell";

  config = lib.mkIf config.aspects.programs.noctalia-shell.enable {
    home-manager.users.${identity.name} = {
      inputs,
      ...
    }: {
      imports = [
        inputs.noctalia-shell.homeModules.default
      ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;

        # General
        settings = {
          shell = {
            scale = 1.0;
            font = "JetBrainsMono Nerd Font";
            avatar_path = "${identity.home}/Pictures/PFPs/G3eRBGwWkAAJ1_v.jpg";
            password_style = "random";
            settings_show_advanced = true;
            panel.transparency_mode = "glass";
            screen_corners.enabled = true;
          };

          # Theme
          theme = {
            mode = "dark";
            builtin = "Catppuccin";
            community_palette = "Catppuccin Lavender";
            source = "community";
            templates = {
              builtin_ids = ["btop" "cava" "hyprland" "kitty"];
              community_ids = ["yazi"];
            };
          };

          # Wallpaper
          wallpaper = {
            enabled = true;
            directory = "${identity.home}/Pictures/wallpapers/static";
            default.path = defaultWallpaper;
            last.path = defaultWallpaper;
            monitors = {
              DP-2.path = defaultWallpaper;
              DP-3.path = defaultWallpaper;
            };
          };

          # Notifications, only showing on main monitor.
          notification = {
            background_opacity = 0.5;
            monitors = ["DP-2"];
          };

          # Main Bar settings.
          bar.main = {
            enabled = false;
            monitor.DP-2.enabled = true;
            position = "top";
            background_opacity = 0.5;
            center = ["media"];
            end = ["tray" "volume" "weather" "network" "temp" "cpu" "ram" "clock" "notifications"];
            margin_ends = 5;
            start = ["launcher" "workspaces" "audio_visualizer" "active_window"];
            widget_spacing = 13;
          };

          # AMERICAN UINITS RAAAGH
          weather = {
            auto_locate = true;
            unit = "imperial";
          };

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
              custom_image = "${identity.home}/Pictures/nix-snowflake-white.svg";
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
