{
  config,
  lib,
  identity,
  ...
}: {
  options.aspects.programs.git.enable = lib.mkEnableOption "Git and SSH identity configuration";

  config = lib.mkIf config.aspects.programs.git.enable (lib.mkMerge [
    {
      # Home Manager level
      home-manager.users.${identity.name} = _: {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          settings = {
            "stellyrland" = {
              HostName = "stellyrland.tailb15b96.ts.net";
              User = identity.nixosName;
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
              name = identity.gitName;
              inherit (identity) email;
            };
            # Bootstrap: on a fresh machine this file configures the SSH key
            # so the private identity flake can be pulled before Nix manages git.
            include.path = "~/.gitconfig-identity";
          };
        };
      };
    }
  ]);
}
