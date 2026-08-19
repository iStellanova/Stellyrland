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

          security.nix-secrets.secrets.tailscale_auth_key = {
            name = "tailscale_auth_key";
            recipients = [
              "stellanova"
              "ItsRedFlame"
              "plasmapulsefinale"
              "stellyrlab"
              "stellyrland"
            ];
          };

          services.tailscale = {
            authKeyFile = config.security.nix-secrets.secrets.tailscale_auth_key.path;
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
