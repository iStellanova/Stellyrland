_: {
  config = {
    # NixOS Media Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

      config = lib.mkIf config.aspects.programs.media.enable {
        home-manager.users.${identity.name} = {
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
    flake.modules.darwin.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

      config = lib.mkIf config.aspects.programs.media.enable {
        home-manager.users.${identity.name} = {
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
