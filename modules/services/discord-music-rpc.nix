_: {
  den.aspects.discord-music-rpc.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.mprisence];

    systemd.user.services.mprisence = {
      description = "Discord Rich Presence for MPRIS media players";
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.mprisence}/bin/mprisence";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      wantedBy = ["graphical-session.target"];
    };
  };

  den.aspects.discord-music-rpc.darwin = _: {
    homebrew.brews = ["apple-music-discord-rpc"];
  };
}
