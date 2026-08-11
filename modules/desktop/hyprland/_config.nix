{
  wayland.windowManager.hyprland.settings.config = {
    input = {
      kb_layout = "us";
      numlock_by_default = true;
      follow_mouse = 1;
      sensitivity = 0;
      accel_profile = "flat";
    };
    general = {
      gaps_in = 4;
      gaps_out = 8;
      border_size = 2;
      col = {
        active_border = {
          colors = [
            "rgb(8aadf4)"
            "rgb(363a4f)"
          ];
          angle = 45;
        };
        inactive_border = "rgba(c0c6dc33)";
      };
      resize_on_border = true;
      allow_tearing = false;
      layout = "scrolling";
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
        color = "rgb(363a4f)";
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
    cursor = {
      sync_gsettings_theme = true;
      warp_on_change_workspace = false;
      no_hardware_cursors = false;
      no_warps = false;
    };
    render = {
      direct_scanout = false;
      cm_enabled = true;
      cm_auto_hdr = 0;
    };
    scrolling = {
      column_width = 0.5;
      fullscreen_on_one_column = true;
      follow_focus = true;
      focus_fit_method = 1;
    };
    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
    };
    xwayland = {
      force_zero_scaling = true;
    };
  };
}
