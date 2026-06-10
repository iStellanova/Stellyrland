_: {
  den.aspects.discord-music-rpc.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.mprisence];
  };

  den.aspects.discord-music-rpc.homeManager = {pkgs, ...}: {
    systemd.user.services.mprisence = {
      Unit = {
        Description = "Discord Rich Presence for MPRIS media players";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.mprisence}/bin/mprisence";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };

  den.aspects.discord-music-rpc.darwin = _: {
    homebrew.brews = ["apple-music-discord-rpc"];
  };
}
