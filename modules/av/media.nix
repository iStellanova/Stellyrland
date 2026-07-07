{ sn, ... }: {
  sn.av = {
    includes = [ sn.media ];
  };

  sn.media.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      pavucontrol
      nicotine-plus
    ];
  };

  sn.media.darwin =
    { pkgs, ... }:
    {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];
      environment.systemPackages = [ pkgs.mpv ];
    };

  sn.media.homeManager =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ani-cli
        ffmpeg
        mpv
      ];
    };
}
