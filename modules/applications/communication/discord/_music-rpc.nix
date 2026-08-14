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
}
