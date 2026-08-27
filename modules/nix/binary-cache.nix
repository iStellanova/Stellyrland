{
  flake.modules.nixos.binary-cache-server =
    { config, host, ... }:
    {
      security.nix-secrets.secrets.harmonia-signing-key = {
        recipients = [
          "stellanova"
          host.name
        ];
        owner = "root";
        mode = "0400";
      };

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [ config.security.nix-secrets.secrets.harmonia-signing-key.path ];
        settings.bind = "[::]:5000";
      };

      networking.firewall.interfaces = {
        tailscale0.allowedTCPPorts = [ 5000 ];
        eno2.allowedTCPPorts = [ 5000 ];
      };
    };
}
