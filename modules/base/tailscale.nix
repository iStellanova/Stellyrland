_:
let
  tailscalePkgs =
    pkgs: with pkgs; [
      tailscale
      wget
    ];
  osShared = { pkgs, ... }: {
    services.tailscale.enable = true;
    environment.systemPackages = tailscalePkgs pkgs;
  };
in
{
  flake.modules.darwin.tailscale = osShared;

  flake.modules.nixos.tailscale = {
    imports = [
      osShared
      (
        {
          config,
          lib,
          host,
          pkgs,
          ...
        }:
        {
          imports = lib.optional (host.persistence or false) {
            preservation.preserveAt."/persist".directories = [ "/var/lib/tailscale" ];
          };

          sops.secrets.tailscale_auth_key = { };

          services.tailscale = {
            authKeyFile = config.sops.secrets.tailscale_auth_key.path;
            interfaceName = "userspace-networking";
            useRoutingFeatures = "none";
            extraUpFlags = [
              "--accept-dns=false"
              "--accept-routes=false"
              "--ssh=false"
            ];
          };

          systemd.services.tailscale-settings = {
            after = [ "tailscaled-autoconnect.service" ];
            requires = [ "tailscaled-autoconnect.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = "${pkgs.tailscale}/bin/tailscale set --accept-dns=false --accept-routes=false --ssh=false";
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
