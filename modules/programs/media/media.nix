_: {
  config = {
    # NixOS Media Settings
    flake.modules.nixos.media = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

      config = lib.mkIf config.aspects.programs.media.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = with pkgs; [
            ani-cli
            ffmpeg
            mpv
            nicotine-plus
          ];
        };

        environment.systemPackages = with pkgs; [
          ffmpegthumbnailer
          imv
          lollypop
          pavucontrol
        ];
      };
    };

    # Darwin Media Settings
    flake.modules.darwin.media = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

      config = lib.mkIf config.aspects.programs.media.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = with pkgs; [
            ani-cli
            ffmpeg
            mpv
          ];
        };

        homebrew.casks = [
          "background-music"
          "vlc"
        ];
      };
    };
  };
}
