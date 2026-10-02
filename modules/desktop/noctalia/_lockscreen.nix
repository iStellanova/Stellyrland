{ primary, secondary, ... }:
{
  programs.noctalia.settings = {
    lockscreen = { blur_intensity = 0.0; };

    lockscreen_widgets = {
      enabled = true;
      schema_version = 1;
      widget_order = [
        "lockscreen-login-box@${secondary}"
        "lockscreen-login-box@${primary}"
        "lockscreen-widget-0000000000000001"
        "lockscreen-widget-0000000000000002"
      ];
      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };
      widget = {
        "lockscreen-login-box@${primary}" = {
          box_height = 196.0;
          box_width = 810.0;
          cx = 1720.0;
          cy = 1317.0;
          output = primary;
          rotation = 0.0;
          type = "login_box";
          settings = {
            center_password_text = false;
            layout = "regular";
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_media = true;
            show_session_buttons = true;
            show_unlock_hint = true;
            show_weather = true;
          };
        };
        "lockscreen-login-box@${secondary}" = {
          box_height = 196.0;
          box_width = 810.0;
          cx = 720.0;
          cy = 2437.0;
          output = secondary;
          rotation = 0.0;
          type = "login_box";
          settings = {
            center_password_text = false;
            layout = "regular";
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_media = true;
            show_session_buttons = true;
            show_unlock_hint = true;
            show_weather = true;
          };
        };
        "lockscreen-widget-0000000000000001" = {
          box_height = 0.0;
          box_width = 0.0;
          cx = 324.521728515625;
          cy = 318.60870361328125;
          output = primary;
          rotation = 0.0;
          type = "weather";
          settings = {
            background = false;
            shadow = false;
          };
        };
        "lockscreen-widget-0000000000000002" = {
          cx = 653.5;
          cy = 194.0;
          box_width = 1000.0;
          box_height = 200.0;
          output = primary;
          rotation = 0.0;
          type = "label";
          settings = {
            background = false;
            color = "primary";
            shadow = false;
            title = "Stellyrland";
          };
        };
      };
    };
  };
}
