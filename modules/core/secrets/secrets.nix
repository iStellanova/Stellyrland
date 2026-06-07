{inputs, ...}: {
  den.aspects.secrets.nixos = {
    host,
    config,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
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

    # Backup HDD keyfile — root-only, used by backup-hdd service.
    sops.secrets.hdd-keyfile = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    # Ensure .ssh exists with correct ownership before sops writes the key.
    # sops-nix creates parent dirs as root:root if missing, which SSH rejects.
    systemd.tmpfiles.rules = [
      "d ${host.homeDir}/.ssh 0700 ${host.username} users -"
    ];
  };
}
