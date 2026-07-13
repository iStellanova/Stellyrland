_: {
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      pavucontrol
      nicotine-plus
    ];
  };

  flake.modules.darwin.media =
    { pkgs, ... }:
    {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];
      environment.systemPackages = [ pkgs.mpv ];
    };

  flake.modules.homeManager.media =
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
