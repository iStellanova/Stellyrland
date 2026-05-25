_: {
  # NixOS Media Settings
  flake.modules.nixos.media = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        ffmpegthumbnailer
        imv
        lollypop
        pavucontrol
      ];
    };
  };

  # Darwin Media Settings
  flake.modules.darwin.media = _: {
    config = {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];
    };
  };

  # Home Manager Media Settings
  flake.modules.homeManager.media = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [ani-cli ffmpeg mpv]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [nicotine-plus];
  };
}
