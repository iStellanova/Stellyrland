{
  nixosIdentity,
  lib,
  ...
}: {
  config = {
    # Home Manager Git/SSH Settings
    flake.modules.homeManager.git = {osConfig, ...}:
      lib.mkIf (osConfig ? aspects.programs.git && osConfig.aspects.programs.git.enable) {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          settings = {
            "stellyrland" = {
              HostName = "stellyrland.tailb15b96.ts.net";
              User = nixosIdentity.nixosName;
              IdentityFile = "~/.ssh/stellacode";
            };
            "github.com" = {
              HostName = "github.com";
              User = "git";
              IdentityFile = "~/.ssh/stellacode";
              AddKeysToAgent = "yes";
            };
            "*" = {
              HashKnownHosts = "yes";
              SendEnv = "LANG LC_*";
            };
          };
        };

        programs.git = {
          enable = true;
          settings = {
            user = {
              name = nixosIdentity.gitName;
              inherit (nixosIdentity) email;
            };
            # Bootstrap: on a fresh machine this file configures the SSH key
            # so the private identity flake can be pulled before Nix manages git.
            include.path = "~/.gitconfig-identity";
          };
        };
      };

    # NixOS Options Declaration
    flake.modules.nixos.git = {lib, ...}: {
      options.aspects.programs.git.enable = lib.mkEnableOption "Git and SSH identity configuration";
    };

    # Darwin Options Declaration
    flake.modules.darwin.git = {lib, ...}: {
      options.aspects.programs.git.enable = lib.mkEnableOption "Git and SSH identity configuration";
    };
  };
}
