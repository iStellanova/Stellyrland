_: {
  den.aspects.media.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      lollypop
      pavucontrol
    ];
  };

  den.aspects.media.darwin = _: {
    homebrew.casks = [
      "background-music"
      "vlc"
    ];
  };

  den.aspects.media.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [ani-cli ffmpeg mpv]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [nicotine-plus];
  };
}
