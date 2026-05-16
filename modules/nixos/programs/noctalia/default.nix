{ config, lib, identity, ... }:

{
  options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell environment";

  config = lib.mkIf config.aspects.programs.noctalia-shell.enable {
    home-manager.users.${identity.name} = { inputs, pkgs, osConfig, ... }:
      {
        imports = [
          inputs.noctalia-shell.homeModules.default
        ];

        programs.noctalia = {
          enable = true;
          systemd.enable = true;

          # Main configuration (generates config.toml)
          config = {
            shell = {
              scale = 1.0;
              font = "Sans";
              avatar_path = "${identity.home}/Pictures/PFPs/G3eRBGwWkAAJ1_v.jpg";
              password_style = "random";
              settings_show_advanced = true;
              panel.transparency_mode = "glass";
              screen_corners.enabled = true;
            };

            theme = {
              mode = "dark";
              builtin = "Catppuccin";
              community_palette = "Catppuccin Lavender";
              source = "community";
              templates = {
                builtin_ids = [ "btop" "cava" "hyprland" "kitty" ];
                community_ids = [ "yazi" ];
              };
            };

            wallpaper = {
              enabled = true;
              directory = "${identity.home}/Pictures/wallpapers/static";
              default.path = "${identity.home}/Pictures/wallpapers/static/Untitled.png";
              last.path = "${identity.home}/Pictures/wallpapers/static/Untitled.png";
              monitors = {
                DP-2.path = "${identity.home}/Pictures/wallpapers/static/Untitled.png";
                DP-3.path = "${identity.home}/Pictures/wallpapers/static/Untitled.png";
              };
            };

            desktop_widgets = {
              enabled = false;
            };

            dock = {
              auto_hide = true;
            };

            notification = {
              background_opacity = 0.5;
              monitors = [ "DP-2" ];
            };

            bar.main = {
              position = "top";
              background_opacity = 0.5;
              center = [ "media" ];
              end = [ "tray" "volume" "weather" "network" "temp" "cpu" "ram" "clock" "notifications" ];
              margin_ends = 5;
              start = [ "launcher" "workspaces" "audio_visualizer" "active_window" ];
              widget_spacing = 13;
            };

            weather = {
              auto_locate = true;
              unit = "imperial";
            };

            widget = {
              audio_visualizer = {
                bands = 35;
                show_when_idle = true;
                width = 150.0;
              };
              clock.format = "{:%a %d %b %H:%M}";
              cpu.display = "graph";
              launcher = {
                anchor = false;
                capsule = true;
                glyph = "brand-snowflake";
              };
              media = {
                capsule = false;
                title_scroll = "on_hover";
              };
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
          };

          # Widget configuration (generates desktop_widgets.toml in state)
          # Note: v5 separates this from config.toml as it's interactive state.
          desktopWidgets = {
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

        # Link the nix-monitor plugin so it is available to Noctalia v5.
        xdg.configFile."noctalia/plugins/nixos-monitor" = {
          source = inputs.noctalia-nix-monitor;
          force = true;
        };
      };
  };
}
