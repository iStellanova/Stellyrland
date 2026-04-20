{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono Nerd Font Propo";
      size = 14;
    };
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      window_padding_width = 28;
      window_padding_height = 28;
      background_opacity = "0.65";
      cursor_trail = 4;
      cursor_trail_decay = "0.1 0.5";
      cursor_trail_start_threshold = 0;
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
    };
    extraConfig = ''
      include /home/stellanova/.config/kitty/themes/noctalia.conf
    '';
  };
}
