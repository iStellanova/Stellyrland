{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

  config = lib.mkIf config.aspects.programs.media.enable (lib.mkMerge [
    {
      home-manager.users.${identity.name} = {
        home.packages = with pkgs; [
          ani-cli
          ffmpeg
          mpv
          nicotine-plus
        ];
      };
    }

    (lib.optionalAttrs isDarwin {
      homebrew.casks = ["vlc"];
    })

    (lib.optionalAttrs (!isDarwin) {
      environment.systemPackages = with pkgs; [
        ffmpegthumbnailer
        imv
        lollypop
        pavucontrol
      ];
    })
  ]);
}
