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

      config = {
        sops.age.sshKeyPaths = [
          (
            if host.persistence or false then
              "/persist/etc/ssh/ssh_host_ed25519_key"
            else
              "/etc/ssh/ssh_host_ed25519_key"
          )
        ];

        # Hosts with separate encrypted files override this default.
        sops.defaultSopsFile = lib.mkDefault ../../secrets/secrets.yaml;
        sops.defaultSopsFormat = "yaml";

        # Needed before users are created so the hashed password is available.
        # This is a per-host secret name, not a username-derived value.
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

    # nix-tools.nix checks this user-owned path when exporting GITHUB_TOKEN.
    sops.secrets.github-token = {
      path = "${host.homeDir}/.config/github-token";
      owner = host.username;
      mode = "0400";
    };
  };
}
