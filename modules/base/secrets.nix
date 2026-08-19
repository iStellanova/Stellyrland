{ inputs, ... }:
{
  flake-file.inputs = {
    nix-secrets = {
      url = "github:unnamed-systems/nix-secrets/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  flake.modules.darwin.secrets =
    {
      host,
      ...
    }:
    {
      imports = [ inputs.nix-secrets.darwinModules.default ];

      security.nix-secrets = {
        enable = true;
        storage = ../../secrets;
        identityPaths = [ "${host.homeDir}/.ssh/stellacode" ];
        recipientAliases = {
          stellanova = "age1muxquz7vyrsva0me3q68mf9xak578hzejqm39vr3llfsftc0dcpqaxlaf7";
          stellyrtop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr topcoat.graver.7c@icloud.com";
        };
        secrets.github-token = {
          path = "${host.homeDir}/.config/github-token";
          owner = host.username;
          mode = "0400";
          recipients = [
            "stellanova"
            "stellyrtop"
          ];
        };
      };
    };
}
