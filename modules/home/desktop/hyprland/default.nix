{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      source = [
        "~/.config/hypr/colors.conf"
      ];

      ################
      ### MONITORS ###
      ################
      monitor = [
        "DP-2, 3440x1440@175, 1440x541, 1, bitdepth, 8, sdrbrightness, 1.2, sdrsaturation, 0.98"
        "DP-3, 2560x1440@100, 0x0, 1, transform, 1, bitdepth, 8, sdrbrightness, 1.2, sdrsaturation, 0.98"
        ", preferred, auto, 1"
      ];

      workspace = [
        "1, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true, default:true"
        "2, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
        "3, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
        "4, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
        "5, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
      ];

      #################
      ### AUTOSTART ###
      #################
      "exec-once" = [
        "systemctl --user start hyprpolkitagent"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY"
        "dbus-update-activation-environment --systemd --all"
        "gnome-keyring-daemon --start --components=secrets"
        "nm-applet"
        "mprisence"
        "quickshell"
        "udiskie -a -s --file-manager nautilus"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      ############################
      ### ENVIRONMENT VARIABLES ##
      ############################
      env = [
        "HYPRCURSOR_THEME, Bibata-Modern-Ice-Hypr"
        "HYPRCURSOR_SIZE, 16"
        "XCURSOR_THEME, Bibata-Modern-Ice"
        "XCURSOR_SIZE, 16"
        "QT_QPA_PLATFORM, wayland;xcb"
        "QT_QPA_PLATFORMTHEME, qt6ct"
        "QT_STYLE_OVERRIDE, kvantum"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1.25"
        "GDK_SCALE, 1.0"
        "GTK_THEME, catppuccin-macchiato-flamingo-standard"
        "GTK_CSD, 0"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "MOZ_ENABLE_WAYLAND, 1"
        "ELECTRON_OZONE_PLATFORM_HINT, auto"
        "OBS_USE_EGL, 1"
        "PROTON_ENABLE_WAYLAND, 1"
        "PROTON_ENABLE_HDR, 1"
      ];

      #############
      ### INPUT ###
      #############
      input = {
        kb_layout = "us";
        kb_options = "caps:escape";
        numlock_by_default = true;
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
      };

      #####################
      ### LOOK AND FEEL ###
      #####################
      general = {
        gaps_in = 8;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "$primary $primary_container 45deg";
        "col.inactive_border" = "rgba(c0c6dc33)";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        active_opacity = 0.8;
        inactive_opacity = 0.8;
        fullscreen_opacity = 1.0;

        shadow = {
          range = 10;
          render_power = 4;
          sharp = false;
          color = "$primary_container";
          color_inactive = "rgba(0,0,0,0)";
        };

        blur = {
          enabled = true;
          size = 12;
          passes = 3;
          noise = 0;
          brightness = 0.9;
          contrast = 1.25;
          vibrancy = 1;
          xray = false;
          new_optimizations = true;
          popups = true;
          popups_ignorealpha = 0.1;
          special = false;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "md3_decel,     0.05, 0.7,  0.1,  1"
          "md3_accel,     0.3,  0,    0.8,  0.15"
          "hyprnostretch, 0.05, 0.9,  0.1,  1.0"
          "menu_decel,    0.1,  1,    0,    1"
          "menu_accel,    0.38, 0.04, 1,    0.07"
          "easeOutExpo,   0.16, 1,    0.3,  1"
          "softAcDecel,   0.26, 0.26, 0.15, 1"
        ];

        animation = [
          "windows,    1, 3,   md3_decel,     popin 60%"
          "windowsIn,  1, 3,   hyprnostretch, popin 40%"
          "windowsOut, 1, 3,   md3_accel,     popin 60%"
          "fade,         1, 3,   md3_decel"
          "layersIn,     1, 3,   menu_decel, popin"
          "layersOut,    1, 1.6, menu_accel"
          "fadeLayersIn, 1, 2,   menu_decel"
          "workspaces,       1, 5, easeOutExpo, slidefade 50%"
          "specialWorkspace, 1, 3, md3_decel,   slidefadevert 15%"
          "border,      1, 10,  default"
          "borderangle, 1, 100, softAcDecel, once"
        ];
      };

      cursor = {
        sync_gsettings_theme = true;
        warp_on_change_workspace = false;
        no_hardware_cursors = false;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };
    };
  };
}
