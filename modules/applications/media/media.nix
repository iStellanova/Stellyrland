{
  flake.modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      pavucontrol
    ];
  };

  flake.modules.darwin.media =
    _:
    {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];
    };

  flake.modules.homeManager.media =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        ani-cli
        mpv
      ];
    };
}
