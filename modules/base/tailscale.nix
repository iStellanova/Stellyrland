_:
let
  osShared = { pkgs, ... }: {
    services.tailscale.enable = true;
    environment.systemPackages = [ pkgs.tailscale ];
  };
in
{
  flake.modules.darwin.tailnet = osShared;

  flake.modules.nixos.tailnet = {
    imports = [
      osShared
      (
        {
          config,
          lib,
          host,
          ...
        }:
        {
          imports = lib.optional (host.persistence or false) {
            preservation.preserveAt."/persist".directories = [ "/var/lib/tailscale" ];
          };

          sops.secrets.tailscale_auth_key = { };

          services.tailscale = {
            authKeyFile = config.sops.secrets.tailscale_auth_key.path;
            interfaceName = "tailscale0";
            useRoutingFeatures = "client";
            extraUpFlags = [
              "--accept-dns=true"
              "--accept-routes=false"
              "--ssh=false"
            ];
            extraSetFlags = [
              "--accept-dns=true"
              "--accept-routes=false"
              "--ssh=false"
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
          };
        }
      )
    ];
  };
}
