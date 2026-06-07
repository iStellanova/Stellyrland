_: let
  networkingPkgs = pkgs: with pkgs; [tailscale wget];
in {
  den.aspects.networking.nixos = {pkgs, ...}: {
    services.tailscale = {
      enable = true;
      interfaceName = "userspace-networking";
      useRoutingFeatures = "none";
      extraUpFlags = [
        "--accept-dns=false"
        "--accept-routes=false"
        "--ssh"
      ];
    };

    environment.systemPackages = networkingPkgs pkgs;

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    # Firewall configuration for Tailscale & Discord voice routing
    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedUDPPorts = [41641]; # Tailscale
      allowedUDPPortRanges = [
        {
          from = 50000;
          to = 65535;
        }
      ];
    };
  };

  den.aspects.networking.darwin = {pkgs, ...}: {
    services.tailscale = {
      enable = true;
    };

    environment.systemPackages = networkingPkgs pkgs;
  };
}
