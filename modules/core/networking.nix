_: {
  # NixOS system-level networking configurations
  flake.modules.nixos.networking = {pkgs, ...}: {
    config = {
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

      environment.systemPackages = with pkgs; [
        tailscale
        wget
      ];

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
  };

  # Darwin system-level networking configurations
  flake.modules.darwin.networking = {pkgs, ...}: {
    config = {
      services.tailscale = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        tailscale
        wget
      ];
    };
  };
}
