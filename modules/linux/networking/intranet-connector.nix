let
  osShared =
    { pkgs, ... }:
    {
      services.tailscale.enable = true;
      environment.systemPackages = [ pkgs.tailscale ];
    };

  nixosConnector =
    {
      host,
      lib,
      ...
    }:
    let
      commonFlags = [
        "--accept-dns=true"
        "--accept-routes=false"
        "--ssh=false"
      ];
      upFlags = [ "--login-server=https://stellyrlab.tailb15b96.ts.net:8443" ] ++ commonFlags;
    in
    {
      imports = [ osShared ] ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".directories = [ "/var/lib/tailscale" ];
      };

      services.tailscale = {
        interfaceName = "tailscale0";
        useRoutingFeatures = "client";
        extraUpFlags = upFlags;
        extraSetFlags = commonFlags;
      };

      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };

      networking.firewall = {
        enable = true;
        checkReversePath = "loose";
        allowedUDPPorts = [ 41641 ];
      };
    };
in
{
  modules.nixos.intranet-connector = nixosConnector;
  modules.darwin.intranet-connector = osShared;
}
