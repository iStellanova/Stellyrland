{
  inputs,
  lib,
  ...
}: {
  flake.modules.nixos.niri = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.niri-flake.nixosModules.niri];

    options.desktop.niri = {
      outputs = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Output configuration passed directly to programs.niri.settings.outputs.";
      };
      wallpaperEngine = {
        steamLibrary = lib.mkOption {
          type = lib.types.str;
          default = "${config.identity.homeDir}/ExtraDisk/SteamLibrary";
          description = "Path to the Steam library containing wallpaper_engine and workshop content.";
        };
        workshopId = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Workshop item ID to pass to linux-wallpaperengine. Empty disables it.";
        };
      };
    };

    config = {
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri-unstable;

      nixpkgs.overlays = [inputs.niri-flake.overlays.niri];

      environment.systemPackages = with pkgs; [
        wl-clipboard
        file-roller
        libnotify
        udiskie
        linux-wallpaperengine
        xhost
        xauth
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [rocmPackages.clr];
      };

      services.xserver.videoDrivers = ["amdgpu"];
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        extraConfig = {
          pipewire."99-lowlatency" = {
            "context.properties"."default.clock.min-quantum" = 512;
            "context.modules" = [
              {
                name = "libpipewire-module-rt";
                flags = ["ifexists" "nofail"];
                args = {
                  "nice.level" = -15;
                  "rt.prio" = 88;
                  "rt.time.soft" = 200000;
                  "rt.time.hard" = 200000;
                };
              }
            ];
          };
          pipewire-pulse."99-lowlatency"."pulse.properties" = {
            "server.address" = ["unix:native"];
            "pulse.min.req" = "512/48000";
            "pulse.min.quantum" = "512/48000";
            "pulse.min.frag" = "512/48000";
          };
          client."99-lowlatency"."stream.properties" = {
            "node.latency" = "512/48000";
            "resample.quality" = 4;
          };
        };
        wireplumber = {
          enable = true;
          extraConfig = {
            "10-ignore-vols" = {
              "monitor.alsa.rules" = [
                {
                  matches = [{"node.name" = "~alsa_input.*";}];
                  actions.update-props."node.ignore-session-volume" = true;
                }
              ];
            };
          };
        };
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config.common.default = "*";
      };
    };
  };

  flake.modules.homeManager.niri = {
    lib,
    osConfig,
    options,
    ...
  }: let
    we = osConfig.desktop.niri.wallpaperEngine;
  in {
    config = {
      programs.niri.config = let
        baseConfigStr = inputs.niri-flake.lib.kdl.serialize.nodes options.programs.niri.config.default;
      in
        baseConfigStr
        + ''

          // Custom background effects and blur (bypassing strictly typed home-manager schema validation)
          window-rule {
              background-effect {
                  blur true
                  xray true
              }
          }

          layer-rule {
              match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel)$"
              background-effect {
                  xray false
              }
          }

          layer-rule {
              match namespace="^noctalia-backdrop$"
              place-within-backdrop true
          }

          debug {
              honor-xdg-activation-with-invalid-serial
          }

          blur {
              passes 3
              offset 3.0
              noise 0.0117
              saturation 1.2
          }
        '';

      programs.zsh.shellAliases = {
        screenoff = "niri msg action power-off-monitors";
      };

      programs.zsh.initContent = lib.mkAfter ''
        cp2c() { if [[ -z "$1" ]]; then echo "Usage: cp2c <file>" >&2; return 1; fi; wl-copy < "$1"; }
        c2f() { if [[ -z "$1" ]]; then echo "Usage: create-from-clip <filename>" >&2; return 1; fi; wl-paste > "$1"; }
      '';

      programs.niri.settings = {
        outputs = osConfig.desktop.niri.outputs;

        animations = {
          "workspace-switch".kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 1.0e-4;
          };
          "window-open".kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 1.0e-4;
          };
          "window-close".kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 1.0e-4;
          };
          "horizontal-view-movement".kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 1.0e-4;
          };
          "window-movement".kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 1.0e-4;
          };
          "window-resize".kind.spring = {
            damping-ratio = 0.8;
            stiffness = 1000;
            epsilon = 1.0e-4;
          };
        };

        input = {
          keyboard = {
            numlock = true;
            xkb = {
              layout = "us";
              options = "caps:escape";
            };
          };
          mouse = {
            accel-profile = "flat";
            accel-speed = 0.0;
          };
          focus-follows-mouse.enable = true;
          focus-follows-mouse.max-scroll-amount = "1%";
          warp-mouse-to-focus.enable = false;
        };

        cursor = {
          theme = "Bibata-Modern-Ice";
          size = 16;
        };

        layout = {
          gaps = 8;
          default-column-width = {proportion = 0.5;};
          center-focused-column = "never";

          focus-ring.enable = false;

          border = {
            enable = true;
            width = 2;
            active.gradient = {
              from = "#8aadf4";
              to = "#363a4f";
              angle = 45;
              relative-to = "workspace-view";
            };
            inactive.color = "#c0c6dc33";
          };

          shadow = {
            enable = true;
            color = "#363a4f70";
            softness = 10.0;
            spread = 5.0;
          };
        };

        prefer-no-csd = true;

        screenshot-path = "~/Pictures/Screenshots/screenshot-%Y-%m-%dT%H:%M:%S.png";

        environment = {
          XCURSOR_THEME = "Bibata-Modern-Ice";
          XCURSOR_SIZE = "16";
          GTK_THEME = "catppuccin-macchiato-flamingo-standard";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_STYLE_OVERRIDE = "kvantum";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          GDK_SCALE = "1.0";
          GTK_CSD = "0";
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "niri";
          MOZ_ENABLE_WAYLAND = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          OBS_USE_EGL = "1";
          PROTON_ENABLE_WAYLAND = "1";
          AMD_VULKAN_ICD = "RADV";
          RADV_PERFTEST = "nggc";
          VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json";
        };

        spawn-at-startup =
          [
            {argv = ["dbus-update-activation-environment" "--systemd" "--all"];}
            {argv = ["systemctl" "--user" "import-environment" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"];}
            {argv = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SOURCE@" "1.0"];}
            {argv = ["udiskie" "-a" "-s" "--file-manager" "nautilus"];}
            {argv = ["systemctl" "--user" "restart" "xdg-desktop-portal"];}
          ]
          ++ lib.optional (we.workshopId != "") {
            sh = "sleep 3 && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets --screen-root DP-2 --screen-root DP-3 --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/";
          };

        window-rules = [
          # Apply corner radius globally, default opacity of 0.8, and enable background blur
          {
            matches = [{}];
            geometry-corner-radius = {
              top-left = 12.0;
              top-right = 12.0;
              bottom-left = 12.0;
              bottom-right = 12.0;
            };
            clip-to-geometry = true;
            opacity = 0.8;
          }

          # System dialogs
          {
            matches = [{app-id = "^xdg-desktop-portal-gtk$";}];
            open-floating = true;
            opacity = 1.0;
          }
          {
            matches = [{app-id = "^zenity$";}];
            open-floating = true;
            opacity = 1.0;
          }
          {
            matches = [{app-id = "^org\\.pulseaudio\\.pavucontrol$";}];
            open-floating = true;
            opacity = 1.0;
          }

          # File operation dialogs
          {
            matches = [{title = "^File Operation Progress$";}];
            open-floating = true;
            opacity = 1.0;
          }
          {
            matches = [{title = "^Open File$";} {title = "^Open Folder$";}];
            open-floating = true;
            opacity = 1.0;
          }

          # Picture-in-picture
          {
            matches = [{title = "^Picture in picture$";} {title = "^Picture-in-Picture$";}];
            open-floating = true;
            opacity = 1.0;
          }

          # Nautilus previewer / sushi
          {
            matches = [{app-id = "^(org\\.gnome\\.Sushi|sushi|org\\.gnome\\.NautilusPreviewer)$";}];
            open-floating = true;
            opacity = 1.0;
          }

          # Opacity overrides — matching Hyprland's active/inactive configurations
          {
            matches = [
              {
                app-id = "^org\\.gnome\\.Nautilus$";
                is-active = true;
              }
            ];
            opacity = 0.85;
          }
          {
            matches = [
              {
                app-id = "^org\\.gnome\\.Nautilus$";
                is-active = false;
              }
            ];
            opacity = 0.75;
          }
          {
            matches = [{app-id = "^kitty$";}];
            opacity = 0.8;
          }
          {
            matches = [{app-id = "^nvim$";}];
            opacity = 0.3;
          }
          {
            matches = [
              {
                app-id = "^zen$";
                is-active = true;
              }
            ];
            opacity = 1.0;
          }
          {
            matches = [
              {
                app-id = "^zen$";
                is-active = false;
              }
            ];
            opacity = 0.85;
          }
          {
            matches = [{app-id = "^vesktop$";}];
            opacity = 1.0;
          }
          {
            matches = [{title = ".*YouTube Music.*";}];
            opacity = 0.6;
          }
          # Floating Noctalia settings window
          {
            matches = [{app-id = "^dev\\.noctalia\\.Noctalia\\.Settings$";}];
            open-floating = true;
            default-column-width = {fixed = 1080;};
            default-window-height = {fixed = 920;};
          }
        ];

        layer-rules = [];

        binds =
          {
            # Applications
            "Mod+Q".action.spawn = "kitty";
            "Mod+E".action.spawn = ["nautilus" "--new-window"];
            "Mod+B".action.spawn = "zen";
            "Mod+V".action.spawn = "zeditor";

            # Session
            "Mod+Shift+L".action.spawn = ["noctalia" "msg" "lock"];

            # Window management
            "Mod+C".action.close-window = {};
            "Alt+F4".action.close-window = {};
            "Mod+A".action.toggle-window-floating = {};
            "Alt+Return".action.fullscreen-window = {};

            # Focus — horizontal (columns) and vertical (within column)
            "Mod+H".action.focus-column-left = {};
            "Mod+S".action.focus-column-left = {};
            "Mod+L".action.focus-column-right = {};
            "Mod+D".action.focus-column-right = {};
            "Mod+K".action.focus-window-up = {};
            "Mod+J".action.focus-window-down = {};
            "Mod+Ctrl+Left".action.focus-column-left = {};
            "Mod+Ctrl+Right".action.focus-column-right = {};
            "Mod+Ctrl+Up".action.focus-window-up = {};
            "Mod+Ctrl+Down".action.focus-window-down = {};

            # Workspace navigation (up = prev, down = next)
            "Mod+Left".action.focus-workspace-up = {};
            "Mod+Right".action.focus-workspace-down = {};
            "Mod+Z".action.focus-workspace-up = {};
            "Mod+X".action.focus-workspace-down = {};
            "Mod+BracketLeft".action.focus-workspace-up = {};
            "Mod+BracketRight".action.focus-workspace-down = {};
            "Mod+Up".action.focus-workspace-up = {};
            "Mod+Down".action.focus-workspace-down = {};
            "Mod+Grave".action.focus-workspace-previous = {};
            "Mod+WheelScrollDown".action.focus-workspace-down = {};
            "Mod+WheelScrollUp".action.focus-workspace-up = {};

            # Numbered workspaces 1–10
            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;
            "Mod+0".action.focus-workspace = 10;

            # Move window to workspace
            "Mod+Shift+1".action.move-window-to-workspace = 1;
            "Mod+Shift+2".action.move-window-to-workspace = 2;
            "Mod+Shift+3".action.move-window-to-workspace = 3;
            "Mod+Shift+4".action.move-window-to-workspace = 4;
            "Mod+Shift+5".action.move-window-to-workspace = 5;
            "Mod+Shift+6".action.move-window-to-workspace = 6;
            "Mod+Shift+7".action.move-window-to-workspace = 7;
            "Mod+Shift+8".action.move-window-to-workspace = 8;
            "Mod+Shift+9".action.move-window-to-workspace = 9;
            "Mod+Shift+0".action.move-window-to-workspace = 10;

            # Resize (repeating)
            "Mod+Alt+Right" = {
              action.set-column-width = "+50";
              repeat = true;
            };
            "Mod+Alt+Left" = {
              action.set-column-width = "-50";
              repeat = true;
            };
            "Mod+Alt+Up" = {
              action.set-window-height = "-50";
              repeat = true;
            };
            "Mod+Alt+Down" = {
              action.set-window-height = "+50";
              repeat = true;
            };

            # Noctalia shell integration
            "Mod+Alt+R".action.spawn = ["sh" "-c" "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user restart noctalia"];
            "Mod+Shift+Tab".action.spawn = ["noctalia" "msg" "panel-toggle" "wallpaper"];
            "Mod+Shift+X".action.spawn = ["noctalia" "msg" "panel-toggle" "session"];
            "Mod+Tab".action.spawn = ["noctalia" "msg" "panel-toggle" "launcher"];
            "Mod+Shift+S".action.spawn = ["noctalia" "msg" "panel-toggle" "control-center"];
            "Mod+Comma".action.spawn = ["noctalia" "msg" "settings-toggle"];

            # Screenshots (built-in niri actions; path set via screenshot-path above)
            "Print".action.screenshot = {};
            "Shift+Print".action.screenshot-screen = {};

            # Overview (Mission Control-style workspace view)
            "Mod+Space".action.toggle-overview = {};
          }
          // lib.optionalAttrs (we.workshopId != "") {
            "Mod+Alt+E".action.spawn = ["sh" "-c" "pkill -f -9 linux-wallpaperengine && sleep 1 && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets --screen-root DP-2 --screen-root DP-3 --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/"];
          };
      };
    };
  };
}
