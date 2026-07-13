{ inputs, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.secrets =
    {
      host,
      config,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

      sops.defaultSopsFile = ../../secrets/secrets.yaml;
      sops.defaultSopsFormat = "yaml";

      # Decrypt before users are created so the hashed password is available.
      sops.secrets.user-password = {
        neededForUsers = true;
      };

      users.users.${host.username}.hashedPasswordFile = config.sops.secrets.user-password.path;

      # Personal SSH private key — written dynamically on boot.
      sops.secrets.stellacode = {
        owner = host.username;
        mode = "0600";
      };

      sops.secrets.lastfm-password = { };

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

  flake.modules.darwin.secrets = { host, ... }: {
    imports = [ inputs.sops-nix.darwinModules.sops ];

    sops.age.sshKeyPaths = [ "${host.homeDir}/.ssh/stellacode" ];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets.github-token = {
      path = "${host.homeDir}/.config/github-token";
      owner = host.username;
      mode = "0400";
    };
  };
}
