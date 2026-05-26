_: {
  # NixOS Greetd Settings
  flake.modules.nixos.greetd = {
    config,
    pkgs,
    enabledAspects,
    ...
  }: {
    config = {
      # Accounts service is required for regreet to list users.
      services.accounts-daemon.enable = true;

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = let
              wallpaperCmd =
                if config.identity.dataPath != null
                then "${pkgs.swaybg}/bin/swaybg -o \\* -i ${config.identity.dataPath}/wallpapers/login-wallpaper.png -m fill"
                else "${pkgs.swaybg}/bin/swaybg -o \\* -c '#1e2030'";
              hyprlandPkg =
                if builtins.elem "hyprland" enabledAspects
                then config.programs.hyprland.package
                else pkgs.hyprland;
              greetdHyprConfig = pkgs.writeText "greetd-hyprland.lua" ''
                -- Minimal Hyprland Lua config for the greetd/regreet login screen.
                -- Mirrors the main session's decoration and visual settings for consistency.

                -- Monitor configuration
                ${config.desktop.hyprland.monitorConfig}

                -- Environment variables
                hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
                hl.env("XDG_SESSION_TYPE",    "wayland")
                hl.env("XDG_SESSION_DESKTOP",  "Hyprland")
                hl.env("GDK_BACKEND",          "wayland")
                hl.env("XCURSOR_THEME",        "Bibata-Modern-Ice")
                hl.env("XCURSOR_SIZE",         "16")
                hl.env("HYPRCURSOR_THEME",     "Bibata-Modern-Ice-Hypr")
                hl.env("HYPRCURSOR_SIZE",      "16")
                hl.env("XCURSOR_PATH",         "${pkgs.bibata-cursors}/share/icons")

                -- Bezier curves (same as main session)
                hl.curve("md3_decel",     { type = "bezier", points = { { 0.05, 0.7  }, { 0.1,  1    } } })
                hl.curve("md3_accel",     { type = "bezier", points = { { 0.3,  0    }, { 0.8,  0.15 } } })
                hl.curve("menu_decel",    { type = "bezier", points = { { 0.1,  1    }, { 0,    1    } } })
                hl.curve("menu_accel",    { type = "bezier", points = { { 0.38, 0.04 }, { 1,    0.07 } } })

                -- Animations — fade & layer transitions only (no windows/workspaces at login)
                hl.animation({ leaf = "fade",         enabled = true, speed = 3,   bezier = "md3_decel" })
                hl.animation({ leaf = "layersIn",     enabled = true, speed = 3,   bezier = "menu_decel", style = "popin" })
                hl.animation({ leaf = "layersOut",    enabled = true, speed = 1.6, bezier = "menu_accel" })
                hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2,   bezier = "menu_decel" })

                hl.config({
                  general = {
                    border_size = 2,
                    col = {
                      active_border   = { colors = { "rgb(8aadf4)", "rgb(363a4f)" }, angle = 45 },
                      inactive_border = "rgba(c0c6dc33)",
                    },
                    allow_tearing = false,
                  },
                  decoration = {
                    rounding         = 12,
                    active_opacity   = 1.0,
                    inactive_opacity = 1.0,
                    shadow = {
                      range        = 10,
                      render_power = 4,
                      sharp        = false,
                      color        = "rgb(363a4f)",
                      color_inactive = "rgba(0,0,0,0)",
                    },
                    blur = {
                      enabled          = true,
                      size             = 12,
                      passes           = 3,
                      noise            = 0,
                      brightness       = 0.9,
                      contrast         = 1.25,
                      vibrancy         = 1,
                      xray             = true,  -- lets regreet layer see blurred background
                      new_optimizations = true,
                      popups           = true,
                      popups_ignorealpha = 0.1,
                    },
                  },
                  cursor = {
                    sync_gsettings_theme  = true,
                    no_hardware_cursors   = false,
                  },
                  render = {
                    direct_scanout = false,
                    cm_enabled     = true,
                    cm_auto_hdr    = 2,
                  },
                  misc = {
                    disable_hyprland_logo    = true,
                    disable_splash_rendering = true,
                    force_default_wallpaper  = 0,
                  },
                })

                -- Layer rules — glassmorphism blur on the regreet login window
                hl.layer_rule({ match = { namespace = "regreet" }, blur = true })
                hl.layer_rule({ match = { namespace = "regreet" }, ignore_alpha = 0.5 })

                -- Startup: cursor, wallpaper, regreet, then exit
                hl.on("hyprland.start", function()
                  hl.exec_cmd("${hyprlandPkg}/bin/hyprctl setcursor Bibata-Modern-Ice 16")
                  hl.exec_cmd([[${wallpaperCmd}]])
                  hl.exec_cmd([[sh -c '${pkgs.regreet}/bin/regreet; ${hyprlandPkg}/bin/hyprctl dispatch "hl.dsp.exit()"']])
                end)
              '';
              greetdHyprLauncher = pkgs.writeShellScript "greetd-hyprland-launcher" ''
                export HOME=/tmp/greetd-home
                rm -rf "$HOME"
                mkdir -p $HOME/.config/hypr
                mkdir -p $HOME/.cache/regreet
                printf "%s\n%s\n" \
                  "last_username = \"${config.identity.username}\"" \
                  "last_session = \"${hyprlandPkg}/share/wayland-sessions/hyprland.desktop\"" \
                  > "$HOME/.cache/regreet/cache.toml"
                ln -sf ${greetdHyprConfig} $HOME/.config/hypr/hyprland.lua
                export XDG_DATA_DIRS="${hyprlandPkg}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
                export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
                exec ${hyprlandPkg}/bin/start-hyprland
              '';
            in "${pkgs.dbus}/bin/dbus-run-session ${greetdHyprLauncher}";
            user = "greeter";
          };
        };
      };

      systemd.services.greetd.environment = {
        HYPRLAND_STARTED_WITH_HYPRLAND_START = "1";
      };

      programs.regreet = {
        enable = true;
        theme = {
          name = "catppuccin-macchiato-flamingo-standard";
          package = pkgs.catppuccin-gtk.override {
            accents = ["flamingo"];
            variant = "macchiato";
          };
        };
        cursorTheme = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
        };
        font = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
          size = 12;
        };
        settings = {
          appearance = {
            greeting_msg = "Welcome back, Stellanova";
            custom_css = "/etc/greetd/regreet.css";
          };
          GTK = {
            application_prefer_dark_theme = true;
          };
        };
        extraCss = ''
          window, .main-window {
            background-color: transparent;
          }

          #container, .container {
            background-color: rgba(36, 39, 58, 0.55);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(242, 205, 205, 0.4);
            margin: auto;
            -gtk-halign: center;
            -gtk-valign: center;
            min-width: 400px;
          }

          label {
            color: #cad3f5;
          }

          #clock {
            font-size: 32px;
            margin-bottom: 20px;
            padding: 12px 24px;
            color: #cad3f5;
          }

          popover contents {
            background-color: rgba(36, 39, 58, 0.95);
            padding: 8px;
            border-radius: 12px;
            color: #cad3f5;
            border: 1px solid rgba(242, 205, 205, 0.2);
          }

          popover contents label {
            color: #cad3f5;
          }

          button {
            background-color: rgba(54, 58, 79, 0.6);
            color: #cad3f5;
            border-radius: 8px;
            padding: 8px 16px;
          }

          button label {
            color: #cad3f5;
          }

          button.suggested-action {
            background-color: #f2cdcd;
            font-weight: bold;
          }

          button.suggested-action label {
            color: #181926;
          }

          button:hover {
            background-color: rgba(69, 71, 90, 0.8);
          }

          button.suggested-action:hover {
            background-color: #f5e0dc;
          }

          button.suggested-action:hover label {
            color: #181926;
          }

          entry, dropdown, .dropdown, combo {
            background-color: rgba(54, 58, 79, 0.6);
            color: #cad3f5;
            border: 1px solid #494d64;
            border-radius: 8px;
          }

          dropdown label, .dropdown label {
            color: #cad3f5;
          }

          dropdown arrow, .dropdown arrow {
            color: #f2cdcd;
          }
        '';
      };

      security.pam.services.greetd.enableGnomeKeyring = true;
    };
  };
}
