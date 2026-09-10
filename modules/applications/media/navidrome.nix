{
  flake.modules.nixos.navidrome = { config, host, ... }: {
    security.nix-secrets.secrets.navidrome-lastfm-env = {
      recipients = [
        "stellanova"
        host.name
      ];
      owner = "root";
      mode = "0400";
      path = "/run/secrets/navidrome-lastfm.env";
    };

    services.navidrome = {
      environmentFile = config.security.nix-secrets.secrets.navidrome-lastfm-env.path;
      enable = true;
      openFirewall = false;
      settings = {
        Address = "0.0.0.0";
        MusicFolder = "/srv/music";
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 4533 ];
  };
}
