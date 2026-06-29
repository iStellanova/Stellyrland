{
  sn,
  inputs,
  ...
}: {
  sn.desktop = {host, ...}: {
    includes =
      if host.class == "nixos"
      then [sn.noctalia-shell]
      else [];
  };

  flake-file.inputs.noctalia-shell = {
    url = "github:noctalia-dev/noctalia/cachix";
  };

  sn.noctalia-shell.nixos = {lib, ...}: {
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

    config = {
      nix.settings.substituters = ["https://noctalia.cachix.org"];
      nix.settings.trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };
  };

  sn.noctalia-shell.homeManager = {
    host,
    osConfig,
    lib,
    ...
  }: let
    wallpaperDir = "${host.homeDir}/Pictures/wallpapers";
    defaultWallpaper = "${wallpaperDir}/wallpaper.png";
    primary = osConfig.desktop.noctalia.primaryMonitor;
    secondary = osConfig.desktop.noctalia.secondaryMonitor;
    monitorSections =
      lib.optionalString (primary != "") "[wallpaper.monitors.${primary}]\npath = \"${defaultWallpaper}\"\n\n"
      + lib.optionalString (secondary != "") "[wallpaper.monitors.${secondary}]\npath = \"${defaultWallpaper}\"\n\n";
  in {
    imports =
      [inputs.noctalia-shell.homeModules.default]
      ++ [./_lockscreen.nix];

    home.file = lib.mkIf (host.dataPath != null) {
      "Pictures/wallpapers/wallpaper.png".source = "${host.dataPath}/wallpapers/wallpaper.png";
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

      settings = {
        shell = {
          ui_scale = 1.0;
          font_family = "JetBrainsMono Nerd Font";
          avatar_path = lib.optionalString (host.dataPath != null) "${host.dataPath}/icons/avatar.png";
          password_style = "random";
          settings_show_advanced = true;
          setup_wizard_enabled = false;
          polkit_agent = true;
          launch_apps_as_systemd_services = true;
          screen_time_enabled = true;
          launcher.session_search = true;
          panel = {
            transparency_mode = "glass";
            session_placement = "floating";
            session_position = "center";
          };
          screen_corners.enabled = true;
          screenshot = {
            save_to_file = true;
            directory = "${host.homeDir}/Pictures/Screenshots";
            copy_to_clipboard = true;
          };
        };

        theme = {
          mode = "dark";
          builtin = "Catppuccin";
          community_palette = "Catppuccin Lavender";
          source = "community";
          templates = {
            builtin_ids = ["btop" "cava" "hyprland" "kitty" "helix"];
            community_ids = ["yazi" "hyprtoolkit"];
          };
        };

        wallpaper = {
          enabled = true;
          directory = wallpaperDir;
          default.path = defaultWallpaper;
          last.path = defaultWallpaper;
          monitors =
            lib.optionalAttrs (primary != "") {"${primary}".path = defaultWallpaper;}
            // lib.optionalAttrs (secondary != "") {"${secondary}".path = defaultWallpaper;};
        };

        notification = {
          background_opacity = 0.5;
          monitors = lib.optional (primary != "") primary;
        };

        bar.main = {
          enabled = false;
          monitor = lib.optionalAttrs (primary != "") {"${primary}".enabled = true;};
          position = "top";
          background_opacity = 0.5;
          shadow = false;
          center = ["media"];
          end = ["tray" "volume" "weather" "network" "temp" "cpu" "ram" "clock" "clipboard" "notifications"];
          margin_ends = 5;
          margin_edge = 5;
          start = ["launcher" "workspaces" "audio_visualizer" "active_window"];
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
          # Clock formatted WKDY, DD/MM 12HR AM/PM
          clock.format = "{:%a, %b %d %I:%M %p}";
          cpu.display = "graph";
          launcher = {
            anchor = false;
            capsule = true;
            custom_image =
              if host.dataPath != null
              then "${host.dataPath}/icons/nix-snowflake-white.svg"
              else "";
            glyph = "brand-snowflake";
          };

          # Center Media Widget
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
}
