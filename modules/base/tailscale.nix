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
    { config, inputs, pkgs, ... }:
    {
      imports = [
        inputs.finix-community-modules.nixosModules.tailscale
        inputs.self.modules.finix.preservation
        inputs.finix.nixosModules.nftables
      ];

      preservation.preserveAt."/persist".directories = [ "/var/lib/tailscale" ];

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
        enable = true;
        authKeyFile = config.security.nix-secrets.secrets.tailscale_auth_key.path;
        interfaceName = "tailscale0";
        routingSysctls = "client";
        extraUpFlags = [
          "--accept-dns=true"
          "--accept-routes=false"
          "--ssh=false"
        ];
      };

      services.nftables = {
        enable = true;
        configFile = pkgs.writeText "tailscale-firewall.nft" ''
          flush ruleset

          table inet filter {
            chain input {
              type filter hook input priority filter; policy drop;
              iifname "lo" accept
              ct state established,related accept
              ip protocol icmp accept
              ip6 nexthdr icmpv6 accept
              iifname "tailscale0" accept
              udp dport 41641 accept
              tcp dport 22 accept
            }
            chain forward {
              type filter hook forward priority filter; policy drop;
              ct state established,related accept
              iifname "tailscale0" accept
              oifname "tailscale0" accept
            }
            chain output {
              type filter hook output priority filter; policy accept;
            }
          }
        '';
      };

      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.conf.all.rp_filter" = 2;
        "net.ipv4.conf.default.rp_filter" = 2;
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
}
