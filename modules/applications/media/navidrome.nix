{
  flake.modules.nixos.navidrome = {
    services.navidrome = {
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
