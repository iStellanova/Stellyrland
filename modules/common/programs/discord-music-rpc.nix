{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.discord-music-rpc.enable = lib.mkEnableOption "Discord Rich Presence for music players";

  config = lib.mkIf config.aspects.programs.discord-music-rpc.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.brews = ["apple-music-discord-rpc"];
    })

    (lib.optionalAttrs (!isDarwin) {
      home-manager.users.${identity.name} = {
        home.packages = [pkgs.mprisence];

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
    })
  ]);
}
