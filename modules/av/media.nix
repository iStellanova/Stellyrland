{
  sn,
  ...
}: {
  sn.av = {includes = [sn.media];};

  sn.media.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      lollypop
      pavucontrol
    ];
  };

  sn.media.darwin = _: {
    homebrew.casks = [
      "background-music"
      "vlc"
    ];
  };

  sn.media.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [ani-cli ffmpeg mpv]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [nicotine-plus];
  };
}
