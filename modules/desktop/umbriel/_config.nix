{ osConfig, ... }:
{
  programs.umbriel.settings = {
    general = {
      show_cheatsheet = false;
    };
    workspaces.back_and_forth = true;
    appearance = {
      corner_radius = 12;
      blur = {
        optimized = false;
        radius = 12;
        noise = 0.0;
        contrast = 1.25;
        saturation = 1.0;
      };
      shadow = {
        offset_x = 0;
        offset_y = 0;
      };
    };

    layout = {
      scrolling = {
        default_width_fraction = 0.5;
        center_underfull_strip = false;
        expand_single_column = true;
      };
    };

    input = {
      keyboard = {
        layout = "us";
        numlock_toggle = true;
      };
      mouse = {
        accel_profile = "flat";
      };
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 16;
      };
      focus.follows_mouse = true;
    };

    output = osConfig.desktop.umbriel.outputs;
  };
}
