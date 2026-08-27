{ osConfig, ... }:
{
  programs.umbriel.settings = {
    general = {
      show_cheatsheet = false;
    };

    workspaces.back_and_forth = true;

    appearance = {
      border_width = 2;
      corner_radius = 12;
      border_focused = "#8aadf4cc";
      border_unfocused = "#c0c6dc33";
      animation_ms = 250;
      blur = {
        passes = 3;
        radius = 12;
        noise = 0.0;
        brightness = 0.9;
        contrast = 1.25;
        saturation = 1.0;
      };
      shadow = {
        enabled = true;
        softness = 10;
        offset_x = 0;
        offset_y = 0;
        color = "#363a4fff";
      };
    };

    layout = {
      mode = "scrolling";
      gap = 8;
      scrolling = {
        default_width_fraction = 0.5;
        center_underfull_strip = false;
      };
    };

    input = {
      keyboard = {
        layout = "us";
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
