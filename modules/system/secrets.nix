{
  sn,
  inputs,
  ...
}: {
  sn.system = {includes = [sn.secrets];};

  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.secrets.nixos = {
    host,
    config,
    ...
  }: {
    imports =
      if inputs ? sops-nix
      then [inputs.sops-nix.nixosModules.sops]
      else [];

    sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

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

    sops.secrets.lastfm-password = {};

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

    # Ensure .ssh exists with correct ownership before sops writes the key.
    # sops-nix creates parent dirs as root:root if missing, which SSH rejects.
    systemd.tmpfiles.rules = [
      "d ${host.homeDir}/.ssh 0700 ${host.username} users -"
    ];
  };

  sn.secrets.darwin = {host, ...}: {
    imports =
      if inputs ? sops-nix
      then [inputs.sops-nix.darwinModules.sops]
      else [];

    sops.age.sshKeyPaths = ["${host.homeDir}/.ssh/id_ed25519"];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets.stellacode = {
      path = "${host.homeDir}/.ssh/stellacode";
    };

    sops.secrets.github-token = {
      path = "${host.homeDir}/.config/github-token";
    };
  };
}
