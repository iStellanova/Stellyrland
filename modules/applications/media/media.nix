{
  modules.nixos.media = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      pavucontrol
    ];
  };

  modules.darwin.media = {
    homebrew.casks = [
      "background-music"
      "vlc"
    ];
  };

  modules.homeManager.media =
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
