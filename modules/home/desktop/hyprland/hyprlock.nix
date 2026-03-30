{ config, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      # Source colors from matugen
      source = [
        "~/.config/hypr/hyprlock-colors.conf"
      ];

      background = [{
        monitor = "";
        path = "$current_wallpaper";
        blur_passes = 4;
        contrast = 1.5;
        brightness = 0.75;
        vibrancy = 0.2;
        vibrancy_darkness = 0.8;
      }];

      general = {
        fade_in = true;
        fade_out = true;
        hide_cursor = false;
        grace = 1;
        disable_loading_bar = false;
      };

      "input-field" = [{
        monitor = "";
        size = "250, 60";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.45;
        dots_center = true;
        outer_color = "$primary_container";
        inner_color = "$primary_container";
        font_color = "$on_primary_container";
        fade_on_empty = false;
        rounding = -1;
        check_color = "rgb(204, 136, 34)";
        placeholder_text = "<i>Input Password...</i>";
        hide_input = false;
        position = "0, -200";
        halign = "center";
        valign = "center";
      }];

      label = [
        # DATE
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%A, %B %d\")\"";
          color = "rgba(255, 255, 255, 0.75)";
          font_size = 22;
          font_family = "Hurmit Nerd Font";
          position = "0, 300";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 6;
          shadow_color = "rgba(0, 0, 0, 0.3)";
          shadow_boost = 1.2;
        }
        # TIME
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +\"%-I:%M\")\"";
          color = "rgba(255, 255, 255, 0.95)";
          font_size = 95;
          font_family = "JetBrains Mono Extrabold";
          position = "0, 200";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 10;
          shadow_color = "rgba(0, 0, 0, 0.4)";
          shadow_boost = 1.5;
        }
        # CURRENT SONG
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(~/.config/hypr/Scripts/whatsong.sh)\"";
          color = "$on_primary_container";
          font_size = 18;
          font_family = "Metropolis Light, Font Awesome 6 Free Solid";
          position = "0, 50";
          halign = "center";
          valign = "bottom";
        }
        # CURRENT USER
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(~/.config/hypr/Scripts/whoami.sh)\"";
          color = "$on_primary_container";
          background = "$backgroundAA";
          rounding = 24;
          font_size = 12;
          font_family = "JetBrains Mono Nerd Font Propo";
          position = "+10, -10";
          halign = "left";
          valign = "top";
        }
      ];

      shape = [{
        monitor = "";
        size = "720, 480";
        color = "rgba(0, 0, 0, 0.1)";
        rounding = 72;
        border_size = 2;
        border_color = "rgba(0, 0, 0, 0.30)";
        rotate = 0;
        xray = false;
        position = "0, 130";
        halign = "center";
        valign = "center";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 1800;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
