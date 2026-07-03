{ sn, ... }: {
  sn.communication = {
    includes = [ sn.discord-music-rpc ];
  };

  sn.discord-music-rpc.homeManager =
    { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ pkgs.mprisence ];

      systemd.user.services.mprisence = {
        Unit = {
          Description = "Discord Rich Presence for MPRIS media players";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.mprisence}/bin/mprisence";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };

  sn.discord-music-rpc.darwin = _: {
    homebrew.extraConfig = ''
      tap "nextfire/tap", trusted: true
      brew "nextfire/tap/apple-music-discord-rpc"
    '';
  };
}
