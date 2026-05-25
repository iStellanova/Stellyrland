_: {
  # NixOS Discord Music RPC Settings
  flake.modules.nixos.discord-music-rpc = {pkgs, ...}: {
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

  # Darwin Discord Music RPC Settings
  flake.modules.darwin.discord-music-rpc = _: {
    homebrew.brews = ["apple-music-discord-rpc"];
  };
}
