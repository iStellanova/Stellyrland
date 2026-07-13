_:
let
  networkingPkgs =
    pkgs: with pkgs; [
      tailscale
      wget
    ];
  osShared = { pkgs, ... }: {
    services.tailscale.enable = true;
    environment.systemPackages = networkingPkgs pkgs;
  };
in
{
  flake.modules.darwin.tailscale = osShared;

  flake.modules.nixos.tailscale = {
    imports = [
      osShared
      (_: {
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
      })
    ];
  };
}
