{
  config,
  lib,
  identity,
  ...
}: {
  options.aspects.core.secrets.enable = lib.mkEnableOption "Secure secrets management using sops-nix";

  config = lib.mkIf config.aspects.core.secrets.enable {
    # Specify the decrypt key file location (directly in persistent storage to bypass impermanence race condition)
    sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

    # Locate the encrypted secrets file (in our public config repository)
    sops.defaultSopsFile = ./secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    # Declare the user-password secret
    sops.secrets.user-password = {
      neededForUsers = true; # Critical: Decrypt before users are created!
    };

    # Decrypt and write the personal SSH private key dynamically on boot
    sops.secrets.stellacode = {
      path = "/home/${identity.name}/.ssh/stellacode";
      owner = identity.name;
      mode = "0600";
    };

    # Ensure .ssh exists with correct ownership before sops writes the key.
    # sops-nix creates parent dirs as root:root if missing, which SSH rejects.
    systemd.tmpfiles.rules = [
      "d /home/${identity.name}/.ssh 0700 ${identity.name} users -"
    ];
  };
}
