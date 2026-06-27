_: {
  wayland.windowManager.mango.settings = {
    animations = 1;
    layer_animations = 1;

    # --- Types ---
    animation_type_open = "zoom";
    animation_type_close = "zoom";
    layer_animation_type_open = "slide";
    layer_animation_type_close = "fade";

    # --- Fade ---
    animation_fade_in = 1;
    animation_fade_out = 1;
    fadein_begin_opacity = 0.0;
    fadeout_begin_opacity = 1.0;

    # --- Zoom (closest to Hyprland popin) ---
    zoom_initial_ratio = 0.6;
    zoom_end_ratio = 0.6;

    # --- Duration (ms) ---
    animation_duration_open = 200;
    animation_duration_close = 200;
    animation_duration_move = 200;
    animation_duration_tag = 200;
    animation_duration_focus = 0;

    # --- Curves (bezier x1,y1,x2,y2) ---
    animation_curve_open = "0.05,0.7,0.1,1.0";
    animation_curve_move = "0.05,0.7,0.1,1.0";
    animation_curve_close = "0.3,0.0,0.8,0.15";
    animation_curve_tag = "0.16,1.0,0.3,1.0";
    animation_curve_opafadein = "0.05,0.7,0.1,1.0";
    animation_curve_opafadeout = "0.3,0.0,0.8,0.15";

    # --- Tag Animation ---
    tag_animation_direction = 0;
  };
}
