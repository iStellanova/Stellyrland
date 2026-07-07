{ sn, ... }: {
  sn.terminal = {
    includes = [ sn.kitty ];
  };

  # Registers kitty at the system level so nix-darwin's native app-linking picks it up
  # (config is still managed via homeManager below; Nix deduplicates the store path).
  sn.kitty.darwin = { pkgs, ... }: { environment.systemPackages = [ pkgs.kitty ]; };

  sn.kitty.homeManager =
    {
      lib,
      host,
      ...
    }:
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
          background_opacity = "0.60";
          background_blur = 40;
          cursor_trail = 4;
          cursor_trail_decay = "0.1 0.5";
          cursor_trail_start_threshold = 0;
          allow_remote_control = "yes";
          listen_on = "unix:/tmp/kitty";
          bold_font = "auto";
          italic_font = "auto";
          bold_italic_font = "auto";
          hide_window_decorations = lib.mkIf (host.class == "darwin") "titlebar-only";
        };
        extraConfig = lib.mkIf (host.class != "darwin") ''
          include themes/noctalia.conf
        '';
      };

      xdg.terminal-exec = lib.mkIf (host.class != "darwin") {
        enable = true;
        settings.default = [ "kitty.desktop" ];
      };
    };
}
