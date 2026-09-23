{
  modules.nixos.headscale =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    let
      headscalePort = 8080;
      funnelPort = 8443;
      policy = pkgs.writeText "headscale-policy.hujson" ''
        {
          "acls": [
            { "action": "accept", "src": ["stellanova@"], "dst": ["*:*" ] }
          ]
        }
      '';
    in
    {
      environment.systemPackages = [ pkgs.tailscale ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".directories = [ "/var/lib/tailscale" ];
      };

      security.nix-secrets.secrets.tailscale_auth_key = {
        name = "tailscale_auth_key";
        recipients = [
          "stellyrlab"
        ];
      };

      services.tailscale = {
        enable = true;
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

      services.headscale = {
        enable = true;
        address = "127.0.0.1";
        port = headscalePort;
        settings = {
          server_url = "https://stellyrlab.tailb15b96.ts.net:${toString funnelPort}";
          policy.path = policy;
          dns = {
            magic_dns = true;
            base_domain = "tailnet.stellyrland";
            override_local_dns = false;
          };
          logtail.enabled = false;
          taildrop.enabled = false;
        };
      };

      systemd.services.headscale-funnel = {
        description = "Publish Headscale through Tailscale Funnel";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [
          "network-online.target"
          "tailscaled.service"
          "headscale.service"
        ];
        requires = [
          "tailscaled.service"
          "headscale.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --https=${toString funnelPort} --bg http://127.0.0.1:${toString headscalePort}";
          ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --https=${toString funnelPort} off";
        };
      };
    };
}
