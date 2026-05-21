{
  config,
  lib,
  pkgs,
  identity,
  ...
}: let
  cfg = config.aspects.services.greetd;
in {
  options.aspects.services.greetd.enable = lib.mkEnableOption "greetd login manager with regreet";

  config = lib.mkIf cfg.enable {
    # Accounts service is required for regreet to list users.
    services.accounts-daemon.enable = true;

    # greetd (login manager) for Hyprland.
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = let
            wallpaper = "${identity.outPath}/wallpapers/login-wallpaper.png";
            hyprlandPkg =
              if config.aspects.desktop.hyprland.enable
              then config.programs.hyprland.package
              else pkgs.hyprland;
            greetdHyprConfig = pkgs.writeText "greetd-hyprland.conf" ''
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: conf: "monitor=${name}, ${conf}") config.aspects.core.monitors)}
              monitor=, preferred, auto, 1

              misc {
                disable_hyprland_logo = true
                disable_splash_rendering = true
                force_default_wallpaper = 0
              }

              decoration {
                blur {
                  enabled = true
                  size = 10
                  passes = 3
                  new_optimizations = true
                  ignore_opacity = true
                  vibrancy = 0.1696
                }
              }

              layerrule = blur on, match:namespace regreet
              layerrule = ignore_alpha 0.5, match:namespace regreet

              env = XDG_CURRENT_DESKTOP,Hyprland
              env = XDG_SESSION_TYPE,wayland
              env = XDG_SESSION_DESKTOP,Hyprland
              env = GDK_BACKEND,wayland
              env = XCURSOR_THEME,Bibata-Modern-Ice
              env = XCURSOR_SIZE,16
              env = HYPRCURSOR_THEME,Bibata-Modern-Ice
              env = HYPRCURSOR_SIZE,16
              env = XCURSOR_PATH,${pkgs.bibata-cursors}/share/icons

              exec-once = ${hyprlandPkg}/bin/hyprctl setcursor Bibata-Modern-Ice 16
              exec-once = ${pkgs.swaybg}/bin/swaybg -o \* -i ${wallpaper} -m fill
              exec-once = sh -c "sleep 0.5; ${pkgs.regreet}/bin/regreet; ${hyprlandPkg}/bin/hyprctl dispatch exit"
            '';
            # A launcher that tricks the official start-hyprland into using this config
            # by placing it at the default search path in a temporary HOME.
            greetdHyprLauncher = pkgs.writeShellScript "greetd-hyprland-launcher" ''
              export HOME=/tmp/greetd-home
              rm -rf "$HOME"
              mkdir -p $HOME/.config/hypr
              mkdir -p $HOME/.cache/regreet
              printf "%s\n%s\n" \
                "last_username = \"${identity.name}\"" \
                "last_session = \"${hyprlandPkg}/share/wayland-sessions/hyprland.desktop\"" \
                > "$HOME/.cache/regreet/cache.toml"
              ln -sf ${greetdHyprConfig} $HOME/.config/hypr/hyprland.conf
              export XDG_DATA_DIRS="${hyprlandPkg}/share''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
              exec ${hyprlandPkg}/bin/start-hyprland
            '';
          in "${pkgs.dbus}/bin/dbus-run-session ${greetdHyprLauncher}";
          user = "greeter";
        };
      };
    };

    systemd.services.greetd.environment.HYPRLAND_STARTED_WITH_HYPRLAND_START = "1";

    # regreet (login manager) for Hyprland.
    programs.regreet = {
      enable = true;
      theme = {
        name = "catppuccin-macchiato-flamingo-standard";
        package = pkgs.catppuccin-gtk.override {
          accents = ["flamingo"];
          variant = "macchiato";
        };
      };
      # Bibata cursor theme for regreet.
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
      # JetBrains Mono font for regreet.
      font = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      # GTK theme settings for regreet.
      settings = {
        appearance = {
          greeting_msg = "Welcome back, Stellanova";
          custom_css = "/etc/greetd/regreet.css";
        };
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
      # Custom CSS for regreet window.
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
}
