{
  host,
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.mprisence ];
  wayland.windowManager.hyprland.settings.exec-once = lib.mkIf (host.class == "finix") [
    "${pkgs.mprisence}/bin/mprisence"
  ];

  systemd.user.services.mprisence = lib.mkIf (host.class == "nixos") {
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
