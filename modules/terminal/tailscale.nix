{ sn, ... }:
let
  networkingPkgs =
    pkgs: with pkgs; [
      tailscale
      wget
    ];
in
{
  sn.terminal = {
    includes = [ sn.tailscale ];
  };

  sn.tailscale.os = { pkgs, ... }: {
    services.tailscale.enable = true;
    environment.systemPackages = networkingPkgs pkgs;
  };

  sn.tailscale.nixos = _: {
    services.tailscale = {
      interfaceName = "userspace-networking";
      useRoutingFeatures = "none";
      extraUpFlags = [
        "--accept-dns=false"
        "--accept-routes=false"
        "--ssh"
      ];
    };

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedUDPPorts = [ 41641 ];
      allowedUDPPortRanges = [
        {
          from = 50000;
          to = 65535;
        }
      ];
    };
  };
}
