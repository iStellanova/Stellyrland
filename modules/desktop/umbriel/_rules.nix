{
  lib,
  host,
  osConfig,
  ...
}:
let
  outputs = osConfig.desktop.umbriel.outputs;
  xwayland = pattern: "^(\\[Xwayland\\] )?${pattern}$";
  appRule = pattern: { match.app_id = xwayland pattern; };
  floatRule = pattern: (appRule pattern) // { default_floating = true; };
  sizedFloatRule =
    pattern: size:
    (floatRule pattern)
    // {
      default_floating_size_px = {
        width = lib.elemAt size 0;
        height = lib.elemAt size 1;
      };
    };
in
{
  programs.umbriel.settings = {
    window_rule =
      lib.optional (outputs != { } && (host.monitorPriority or [ ]) != [ ]) {
        default_output = lib.elemAt (host.monitorPriority or [ ]) 0;
      }
      ++ [
        {
          blur = true;
          opacity = 0.8;
        }
        (floatRule "(zenity|xdg-desktop-portal|qalculate-gtk|org\\.pulseaudio\\.pavucontrol)")
        (floatRule "(org\\.gnome\\.Sushi|sushi|org\\.gnome\\.NautilusPreviewer)")
        (floatRule "(Emulator)")
        (sizedFloatRule "(dev\\.noctalia\\.Noctalia)" [
          1020
          900
        ])
        (sizedFloatRule "(dev\\.noctalia\\.UmbrielSharePicker)" [
          800
          600
        ])
        (sizedFloatRule "(dev\\.lemmy\\.swash)" [
          1000
          900
        ])
        ((appRule "(steam_app_.*|gamescope)") // { default_fullscreen = true; })
        {
          match.title = "^(File Operation Progress|Open File|Open Folder|Confirm File Replacing|Copying files|Moving files)$";
          default_floating = true;
        }
        {
          match.title = "^(Picture in picture|Picture-in-Picture)$";
          default_floating = true;
          opacity = 1.0;
        }
        ((appRule "(org\\.gnome\\.Sushi|sushi|org\\.gnome\\.NautilusPreviewer)") // { opacity = 1.0; })
        ((appRule "(xdg-desktop-portal-gtk)") // { opacity = 1.0; })
        ((appRule "(kitty)") // { opacity = 1.0; })
        ((appRule "(org\\.gnome\\.Nautilus)") // { opacity = 0.85; })
        ((appRule "(nvim)") // { opacity = 0.3; })
        ((appRule "(zen-.*)") // { opacity = 1.0; })
        ((appRule "(vesktop)") // { opacity = 1.0; })
        ((appRule "(steam|steam_app_.*)") // { opacity = 1.0; })
        {
          match.title = "^notificationtoasts_.+_desktop$";
          default_focused = false;
          default_pinned = true;
          default_position = {
            x = 0;
            y = 0;
            anchor = "bottom_right";
          };
        }
        {
          match.is_alone = true;
          default_scrolling_extent = 1.0;
        }
      ];

    layer_rule = [
      {
        match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
        blur = true;
        blur_ignore_alpha = 0.5;
        blur_popups = true;
      }
    ];
  };
}
