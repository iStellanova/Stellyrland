{inputs, ...}: {
  # NixOS Secrets Settings
  flake.modules.nixos.secrets = {config, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    config = {
      # Specify the decrypt key file location (directly in persistent storage to bypass impermanence race condition)
      sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

      # Locate the encrypted secrets file (top-level secrets/ directory)
      sops.defaultSopsFile = ../../../secrets/secrets.yaml;
      sops.defaultSopsFormat = "yaml";

      # Declare the user-password secret
      sops.secrets.user-password = {
        neededForUsers = true; # Critical: Decrypt before users are created!
      };

      # Decrypt and write the personal SSH private key dynamically on boot
      sops.secrets.stellacode = {
        path = "${config.identity.homeDir}/.ssh/stellacode";
        owner = config.identity.username;
        mode = "0600";
      };

      # Decrypt the personal backup HDD keyfile dynamically on boot
      sops.secrets.hdd-keyfile = {
        path = "/persist/secrets/hdd-keyfile";
        owner = "root";
        group = "root";
        mode = "0400";
      };

      # Ensure .ssh exists with correct ownership before sops writes the key.
      # sops-nix creates parent dirs as root:root if missing, which SSH rejects.
      systemd.tmpfiles.rules = [
        "d ${config.identity.homeDir}/.ssh 0700 ${config.identity.username} users -"
      ];
    };
  };
}
