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
      lib,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      # Single owner of this fact (only sshKeyPaths below needs it): hosts using
      # the preservation/impermanence layout keep the real ssh host key under
      # /persist (see linux-storage/preservation.nix); hosts without it use the
      # normal path. No honest universal default, so each host sets this.
      options.core.impermanence = lib.mkEnableOption "impermanence-style /persist layout for the ssh host key path";

      config = {
        sops.age.sshKeyPaths = [
          (
            if config.core.impermanence then
              "/persist/etc/ssh/ssh_host_ed25519_key"
            else
              "/etc/ssh/ssh_host_ed25519_key"
          )
        ];

        # mkDefault: hosts that must not share stellyrland's recipient list
        # (e.g. onitop) override this to point at their own encrypted file.
        sops.defaultSopsFile = lib.mkDefault ../../secrets/secrets.yaml;
        sops.defaultSopsFormat = "yaml";

        # Decrypt before users are created so the hashed password is available.
        # host.passwordSecret is an arbitrary per-host label (like stellacode
        # below isn't derived from username either) — each host's flake.hosts
        # entry sets its own, not a single shared "user-password".
        sops.secrets.${host.passwordSecret} = {
          neededForUsers = true;
        };

        users.users.${host.username}.hashedPasswordFile = config.sops.secrets.${host.passwordSecret}.path;
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
