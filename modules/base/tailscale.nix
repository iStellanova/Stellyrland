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

  flake-file.inputs.finix-community-modules.url = "git+https://github.com/finix-community/community-modules.git?ref=main";

  flake.modules.finix.tailnet =
    { config, inputs, ... }:
    {
      imports = [
        inputs.finix-community-modules.nixosModules.tailscale
        inputs.self.modules.finix.preservation
      ];

      preservation.preserveAt."/persist".directories = [ "/var/lib/tailscale" ];

      security.nix-secrets.secrets.tailscale_auth_key = {
        name = "tailscale_auth_key";
        recipients = [ "stellanova" "ItsRedFlame" "plasmapulsefinale" "stellyrlab" "stellyrland" ];
      };

      services.tailscale = {
        enable = true;
        authKeyFile = config.security.nix-secrets.secrets.tailscale_auth_key.path;
        interfaceName = "tailscale0";
        routingSysctls = "client";
        extraUpFlags = [ "--accept-dns=true" "--accept-routes=false" "--ssh=false" ];
      };

      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
}
