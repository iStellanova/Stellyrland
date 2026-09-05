{ inputs, ... }:
{
  flake-file.inputs = {
    nix-secrets = {
      # TODO: switch off dev branch once nix-secrets fixes Darwin FsType imports on main branch.
      url = "github:unnamed-systems/nix-secrets/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  flake.modules.nixos.secrets =
    {
      host,
      config,
      ...
    }:
    {
      imports = [
        inputs.nix-secrets.nixosModules.default
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
          recipientAliases = {
            stellanova = "age1muxquz7vyrsva0me3q68mf9xak578hzejqm39vr3llfsftc0dcpqaxlaf7";
            ItsRedFlame = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJgWFxH/qllaNX5axfrDfplGpn/URESTGNX/t4TGgJ6q";
            plasmapulsefinale = "age1ltjn45ay4nwrtx8k9f86ylk5zth98xz9t2gxwe6c2ws3wm44sses9hgc9t";
            stellyrlab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCz+XUleiNbgSwcZHvxOXXTbihnTIRoDKoXr+2zCSgA stellyrstick-host";
            stellyrland = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA";
            stellyrtop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr topcoat.graver.7c@icloud.com";
          };
          secrets.github-token = {
            path = "/run/secrets/github-token";
            owner = host.username;
            mode = "0400";
            recipients = [
              "stellanova"
              "stellyrlab"
              "stellyrland"
              "stellyrtop"
            ];
          };
          secrets.${host.passwordSecret} = {
            neededForUsers = true;
            recipients = [
              "stellanova"
              host.name
            ];
          };
        };

        users.users.${host.username}.hashedPasswordFile =
          config.security.nix-secrets.secrets.${host.passwordSecret}.path;
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
