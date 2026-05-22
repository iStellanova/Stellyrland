{nixosIdentity, ...}: {
  config = {
    # NixOS Discord Music RPC Settings
    flake.modules.nixos.discord-music-rpc = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.discord-music-rpc.enable = lib.mkEnableOption "Discord Rich Presence for music players";

      config = lib.mkIf config.aspects.programs.discord-music-rpc.enable {
        home-manager.users.${nixosIdentity.name} = {
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
      };
    };

    # Darwin Discord Music RPC Settings
    flake.modules.darwin.discord-music-rpc = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.discord-music-rpc.enable = lib.mkEnableOption "Discord Rich Presence for music players";

      config = lib.mkIf config.aspects.programs.discord-music-rpc.enable {
        homebrew.brews = ["apple-music-discord-rpc"];
      };
    };
  };
}
