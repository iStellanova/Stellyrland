{
  modules.nixos.headscale =
    { pkgs, ... }:
    let
      headscalePort = 8080;
      funnelPort = 8443;
      policy = pkgs.writeText "headscale-policy.hujson" ''
        {
          "tagOwners": {
            "tag:server": ["stellanova@"]
          },
          "acls": [
            { "action": "accept", "src": ["stellanova@"], "dst": ["*:*" ] }
          ]
        }
      '';
    in
    {
      services.headscale = {
        enable = true;
        address = "127.0.0.1";
        port = headscalePort;
        settings = {
          server_url = "https://stellyrlab.tailb15b96.ts.net:${toString funnelPort}";
          policy.path = policy;
          dns = {
            magic_dns = false;
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
