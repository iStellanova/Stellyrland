{lib, ...}: {
  config = {
    # User-level Home Manager window/layer rules for Hyprland (Native declarative)
    flake.modules.homeManager.hyprlandRules = {osConfig, ...}:
      lib.mkIf (osConfig ? aspects.desktop.hyprland && osConfig.aspects.desktop.hyprland.enable) {
        wayland.windowManager.hyprland.settings = {
          # Mapped natively by Home Manager to hl.window_rule({...}) calls in Lua
          window_rule = [
            # --- Floating Rules (System & Tooling) ---
            {
              match = {class = "^(xdg-desktop-portal-gtk)$";};
              float = true;
            }
            {
              match = {class = "^(zenity)$";};
              float = true;
            }
            {
              match = {class = "^(org.pulseaudio.pavucontrol)$";};
              float = true;
            }
            {
              match = {title = "^(File Operation Progress)$";};
              float = true;
            }
            {
              match = {title = "^(Open File)$";};
              float = true;
            }
            {
              match = {title = "^(Open Folder)$";};
              float = true;
            }
            {
              match = {title = "^(Picture in picture)$";};
              float = true;
            }
            {
              match = {title = "^(Picture-in-Picture)$";};
              float = true;
            }

            # --- Positioning & Sizing ---
            {
              match = {class = "^(xdg-desktop-portal-gtk)$";};
              center = true;
            }
            {
              match = {class = "^(zenity)$";};
              center = true;
            }
            {
              match = {class = "^(org.pulseaudio.pavucontrol)$";};
              center = true;
            }
            {
              match = {title = "^(Open File)$";};
              center = true;
            }
            {
              match = {title = "^(Open Folder)$";};
              center = true;
            }
            {
              match = {title = "^(Select a Wallpaper)$";};
              size = "70% 70%";
            }
            {
              match = {title = "^(Picture-in-Picture)$";};
              size = "32% 18%";
            }
            {
              match = {class = "^(xdg-desktop-portal-gtk)$";};
              size = "70% 50%";
            }
            {
              match = {title = "^(Confirm File Replacing)$";};
              move = "18% 35%";
            }
            {
              match = {title = "^(Copying files)$";};
              move = "18% 35%";
            }
            {
              match = {title = "^(Moving files)$";};
              move = "18% 35%";
            }

            # --- Nautilus & Sushi (Quick Look) ---
            {
              match = {class = "^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$";};
              float = true;
              center = true;
              size = "50% 50%";
            }
            {
              match = {title = "^(Select a Wallpaper)$";};
              pin = true;
            }

            # --- Opacity & Aesthetics (Noctalia Style) ---
            {
              match = {class = "^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$";};
              opacity = "1.0 override";
            }
            {
              match = {class = "^(xdg-desktop-portal-gtk)$";};
              opacity = "1.0 override";
            }
            {
              match = {class = "^(Xdg-desktop-portal-gtk)$";};
              opacity = "1.0 override";
            }
            {
              match = {class = "^(org.gnome.Nautilus)$";};
              opacity = "0.85 override 0.75 override";
            }
            {
              match = {class = "^(kitty)$";};
              opacity = "0.8 override 0.8 override 1.0 override";
            }
            {
              match = {class = "^(nvim)$";};
              opacity = "0.3 override";
            }
            {
              match = {class = "^(zen)$";};
              opacity = "1.0 override 0.85 override 1.0 override";
            }
            {
              match = {class = "^(vesktop)$";};
              opacity = "1.0 override 1.0 override";
            }
            {
              match = {title = "^(Picture in picture)$";};
              opacity = "1.0 override";
            }
            {
              match = {title = "(.*)(YouTube Music)(.*)";};
              opacity = "0.6 override 0.6 override 1.0 override";
            }

            # --- Clean Look (Disabling shadow & blur on utility windows) ---
            {
              match = {class = "^(xdg-desktop-portal-gtk)$";};
              no_shadow = true;
              no_blur = true;
            }
            {
              match = {title = "^(Picture in picture)$";};
              no_shadow = true;
              no_blur = true;
            }
          ];

          # Mapped natively by Home Manager to hl.layer_rule({...}) calls in Lua
          layer_rule = [
            {
              match = {namespace = "noctalia-.*";};
              blur = true;
              ignore_alpha = 0.5;
            }
            {
              match = {namespace = "notifications";};
              animation = "slide";
            }
            {
              match = {namespace = "wallpaper-transition";};
              no_anim = true;
            }
          ];
        };
      };
  };
}
