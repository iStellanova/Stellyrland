{inputs, ...}: {
  # NixOS Noctalia Shell Settings
  flake.modules.nixos.noctalia = {lib, ...}: {
    options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell";
  };

  # Home Manager Noctalia Settings
  flake.modules.homeManager.noctalia = {
    osConfig,
    lib,
    ...
  }: let
    wallpaperDir = "${osConfig.identity.homeDir}/Pictures/wallpapers";
    defaultWallpaper = "${wallpaperDir}/wallpaper.png";
  in {
    imports = [
      inputs.noctalia-shell.homeModules.default
    ];

    config = lib.mkIf (osConfig ? aspects.programs.noctalia-shell && osConfig.aspects.programs.noctalia-shell.enable) {
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

        [wallpaper.monitors.DP-2]
        path = "${defaultWallpaper}"

        [wallpaper.monitors.DP-3]
        path = "${defaultWallpaper}"
        EOF
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
            directory = wallpaperDir;
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
            margin_edge = 5;
            start = ["launcher" "workspaces" "audio_visualizer" "active_window"];
            widget_spacing = 13;
          };

          # AMERICAN UNITS RAAAGH
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
