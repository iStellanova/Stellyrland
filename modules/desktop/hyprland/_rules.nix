_: {
  # User-level Home Manager window/layer rules for Hyprland (Native declarative)
  wayland.windowManager.hyprland.settings = {
    # Mapped natively by Home Manager to hl.window_rule({...}) calls in Lua
    window_rule = [
      # --- System Dialogs ---
      {
        match = {class = "^(xdg-desktop-portal-gtk)$";};
        float = true;
        center = true;
        size = "70% 50%";
        opacity = "1.0 override";
        no_shadow = true;
        no_blur = true;
      }
      {
        match = {class = "^(Xdg-desktop-portal-gtk)$";};
        opacity = "1.0 override";
      }
      {
        match = {class = "^(zenity)$";};
        float = true;
        center = true;
      }
      {
        match = {class = "^(org.pulseaudio.pavucontrol)$";};
        float = true;
        center = true;
      }

      # --- File Operation Dialogs ---
      {
        match = {title = "^(File Operation Progress)$";};
        float = true;
      }
      {
        match = {title = "^(Open File)$";};
        float = true;
        center = true;
      }
      {
        match = {title = "^(Open Folder)$";};
        float = true;
        center = true;
      }
      {
        match = {title = "^(Confirm File Replacing|Copying files|Moving files)$";};
        move = "18% 35%";
      }

      # --- Picture-in-Picture ---
      {
        match = {title = "^(Picture in picture)$";};
        float = true;
        opacity = "1.0 override";
        no_shadow = true;
        no_blur = true;
      }
      {
        match = {title = "^(Picture-in-Picture)$";};
        float = true;
        size = "32% 18%";
      }

      # --- Nautilus & Sushi ---
      {
        match = {class = "^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$";};
        float = true;
        center = true;
        size = "50% 50%";
        opacity = "1.0 override";
      }
      {
        match = {title = "^(Select a Wallpaper)$";};
        size = "70% 70%";
        pin = true;
      }

      # --- Opacity ---
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
        match = {title = "(.*)(YouTube Music)(.*)";};
        opacity = "0.6 override 0.6 override 1.0 override";
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
}
