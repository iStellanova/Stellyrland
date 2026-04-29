{ config, lib, identity, ... }:
{
  options.aspects.programs.kitty.enable = lib.mkEnableOption "Kitty terminal emulator";
  config = lib.mkIf config.aspects.programs.kitty.enable {
    home-manager.users.${identity.name} = {
      programs.kitty = {
        enable = true;
        font = {
          name = "JetBrains Mono Nerd Font Propo";
          size = 14;
        };
        settings = {
          confirm_os_window_close = 0;
          enable_audio_bell = false;
          window_padding_width = 28; # High padding for a cleaner, centered aesthetic
          window_padding_height = 28;
          background_opacity = "0.65";
          cursor_trail = 4;
          cursor_trail_decay = "0.1 0.5";
          cursor_trail_start_threshold = 0;
          allow_remote_control = "yes"; # Necessary for dynamic theme switching
          listen_on = "unix:/tmp/kitty"; # Socket for external script control
          bold_font = "auto";
          italic_font = "auto";
          bold_italic_font = "auto";
        };
        extraConfig = ''
          include ${identity.home}/.config/kitty/themes/noctalia.conf
        '';
      };
    };
  };
}
