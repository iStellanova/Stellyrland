{lib, ...}: {
  config = {
    # Home Manager Kitty Settings
    flake.modules.homeManager.kitty = {osConfig, ...}: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.kitty && osConfig.aspects.programs.kitty.enable) {
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
            background_blur = 32; # Enable background blur (macOS only)
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
            include ${osConfig.identity.homeDir}/.config/kitty/themes/noctalia.conf
          '';
        };

        xdg.terminal-exec = lib.mkIf (!isDarwin) {
          enable = true;
          settings.default = ["kitty.desktop"];
        };
      };

    # NixOS Options Declaration
    flake.modules.nixos.kitty = {lib, ...}: {
      options.aspects.programs.kitty.enable = lib.mkEnableOption "Kitty terminal emulator";
    };

    # Darwin Options Declaration
    flake.modules.darwin.kitty = {lib, ...}: {
      options.aspects.programs.kitty.enable = lib.mkEnableOption "Kitty terminal emulator";
    };
  };
}
