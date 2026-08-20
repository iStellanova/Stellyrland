_: {
  flake.modules.nixos.binary-cache-server =
    { config, ... }:
    {
      sops.secrets.harmonia-signing-key = {
        sopsFile = ../../secrets/harmonia.yaml;
        owner = "root";
        mode = "0400";
      };

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [ config.sops.secrets.harmonia-signing-key.path ];
        settings.bind = "[::]:5000";
      };

      networking.firewall.interfaces = {
        tailscale0.allowedTCPPorts = [ 5000 ];
        eno2.allowedTCPPorts = [ 5000 ];
      };
    };
}
