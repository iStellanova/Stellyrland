{ sn, ... }: {
  sn.av = {
    includes = [ sn.media ];
  };

  sn.media.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ffmpegthumbnailer
      imv
      pavucontrol
    ];
  };

  sn.media.darwin =
    { pkgs, ... }:
    {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];

      # Registers mpv at the system level so nix-darwin's native app-linking
      # picks it up (it's still installed via home.packages below too, same
      # store path deduped by Nix).
      environment.systemPackages = [ pkgs.mpv ];
    };

  sn.media.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages =
        with pkgs;
        [
          ani-cli
          ffmpeg
          mpv
        ]
        ++ lib.optionals (!pkgs.stdenv.isDarwin) [ nicotine-plus ];
    };
}
