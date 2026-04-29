{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # --- Floating Rules (System & Tooling) ---
      # Ensure dialogs and tool windows don't tile and disrupt the layout.
      "float on, match:class ^(xdg-desktop-portal-gtk)$"
      "float on, match:class ^(zenity)$"
      "float on, match:class ^(org.pulseaudio.pavucontrol)$"
      "float on, match:title ^(File Operation Progress)$"
      "float on, match:title ^(Open File)$"
      "float on, match:title ^(Open Folder)$"
      "float on, match:title ^(Picture in picture)$"
      "float on, match:title ^(Picture-in-Picture)$"

      # --- Positioning & Sizing ---
      "center on, match:class ^(xdg-desktop-portal-gtk)$"
      "center on, match:class ^(zenity)$"
      "center on, match:class ^(org.pulseaudio.pavucontrol)$"
      "center on, match:title ^(Open File)$"
      "center on, match:title ^(Open Folder)$"
      "size 70% 70%, match:title ^(Select a Wallpaper)$"
      "size 32% 18%, match:title ^(Picture-in-Picture)$"
      "size 70% 50%, match:class ^(xdg-desktop-portal-gtk)$"
      "move 45% 30%, match:title ^(Confirm File Replacing)$"
      "move 18% 35%, match:title ^(Copying files)$"
      "move 18% 35%, match:title ^(Moving files)$"

      # --- Nautilus & Sushi (Quick Look) ---
      "float on, match:class ^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$"
      "center on, match:class ^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$"
      "size 50% 50%, match:class ^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$"
      "pin on, match:title ^(Select a Wallpaper)$"

      # --- Opacity & Aesthetics (Noctalia Style) ---
      "opacity 1.0 override, match:class ^(org.gnome.Sushi|sushi|org.gnome.NautilusPreviewer)$"
      "opacity 1.0 override, match:class ^(xdg-desktop-portal-gtk)$"
      "opacity 1.0 override, match:class ^(Xdg-desktop-portal-gtk)$"
      "opacity 0.85 override 0.75 override, match:class ^(org.gnome.Nautilus)$"
      "opacity 0.8 override 0.8 override 1.0 override, match:class ^(kitty)$"
      "opacity 0.3 override, match:class ^(nvim)$" # High transparency for focused coding
      "opacity 1.0 override 0.85 override 1.0 override, match:class ^(zen)$"
      "opacity 1.0 override 1.0 override, match:class ^(discord)$"
      "opacity 1.0 override 1.0 override, match:class ^(vesktop)$"
      "opacity 1.0 override, match:title ^(Picture in picture)$"
      "opacity 0.6 override 0.6 override 1.0 override, match:title (.*)(YouTube Music)(.*)"

      # --- Clean Look (Disabling effects on utility windows) ---
      "no_shadow on, match:class ^(xdg-desktop-portal-gtk)$"
      "no_blur on, match:class ^(xdg-desktop-portal-gtk)$"
      "no_blur on, match:title ^(Picture in picture)$"
      "no_shadow on, match:title ^(Picture in picture)$"
    ];

    layerrule = [
      "blur on, match:namespace noctalia-.*"
      "ignore_alpha 0.5, match:namespace noctalia-.*"
      "animation slide, match:namespace notifications"
      "no_anim on, match:namespace wallpaper-transition"
    ];
  };
}
