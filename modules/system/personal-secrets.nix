_: {
  flake.modules.nixos.personal-secrets =
    { host, ... }:
    {
      # Personal SSH private key — written dynamically on boot.
      sops.secrets.stellacode = {
        owner = host.username;
        mode = "0600";
      };

      sops.secrets.lastfm-password = { };

      # No explicit path: defaults to /run/secrets/github-token. The darwin
      # equivalent (base/secrets.nix) uses an explicit ~/.config path instead —
      # nix-tools.nix's shell init checks both.
      sops.secrets.github-token = {
        owner = host.username;
        mode = "0400";
      };

      # Backup HDD keyfile — root-only, used by backup-hdd service.
      sops.secrets.hdd-keyfile = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
}
