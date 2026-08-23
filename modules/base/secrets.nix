{ inputs, ... }:
{
  flake-file.inputs = {
    nix-secrets = {
      url = "github:unnamed-systems/nix-secrets";
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
      imports = [
        inputs.nix-secrets.nixosModules.default
        inputs.sops-nix.nixosModules.sops
      ];

      config = {
        security.nix-secrets = {
          enable = true;
          storage = ../../secrets;
          identityPaths = [
            (
              if host.persistence or false then
                "/persist/etc/ssh/ssh_host_ed25519_key"
              else
                "/etc/ssh/ssh_host_ed25519_key"
            )
          ];
          recipientAliases.stellanova = "age1muxquz7vyrsva0me3q68mf9xak578hzejqm39vr3llfsftc0dcpqaxlaf7";
          secrets.github-token = {
            path = "/run/secrets/github-token";
            recipients = [ "stellanova" ];
          };
        };

        sops.age.sshKeyPaths = [
          (
            if host.persistence or false then
              "/persist/etc/ssh/ssh_host_ed25519_key"
            else
              "/etc/ssh/ssh_host_ed25519_key"
          )
        ];

        sops.defaultSopsFile = lib.mkDefault ../../secrets/secrets.yaml;
        sops.defaultSopsFormat = "yaml";
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
