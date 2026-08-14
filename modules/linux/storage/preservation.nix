{ inputs, ... }:
{
  flake-file.inputs.preservation = {
    url = "github:nix-community/preservation";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.preservation = { host, ... }: {
    imports = [ inputs.preservation.nixosModules.preservation ];

    systemd.tmpfiles.rules = [
      # @blank was taken before nixos-install, so home reverts to root:root after rollback;
      # fix ownership so HM can create ~/.cache etc. as the user.
      "d /home/${host.username} 0700 ${host.username} users -"
    ];

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/var/lib/nixos"
          "/var/log"
        ];
        files = [
          "/etc/adjtime"
          "/etc/machine-id"
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            how = "symlink";
            configureParent = true;
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            how = "symlink";
            configureParent = true;
          }
        ];
        users.${host.username} = {
          directories = [
            # User data
            "Projects"
            "Documents"
            "Pictures"
            "Music"
            "Videos"

            # Credentials
            ".ssh"
            ".gnupg"
            ".config/sops"

            # Nix user state — profile dir must survive rollback so
            # home-manager-stellanova.service's setupVars() doesn't exit 1 at boot
            {
              directory = ".local/state/nix/profiles";
              mode = "0755";
            }
            ".local/state/nix"

            # HM gcroots — protects current generation from nix-store GC and
            # gives HM its oldGenPath for correct diff-based activation
            {
              directory = ".local/state/home-manager/gcroots";
              mode = "0755";
            }
            ".local/state/home-manager"

          ];
        };
      };
    };
  };
}
