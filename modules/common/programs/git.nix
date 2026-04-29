{ config, lib, identity, ... }:

{
  options.aspects.programs.git.enable = lib.mkEnableOption "Git and SSH identity configuration";

  config = lib.mkIf config.aspects.programs.git.enable (lib.mkMerge [
    {
      # Home Manager level
      home-manager.users.${identity.name} = {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          matchBlocks = {
            "github.com" = {
              hostname = "github.com";
              user = "git";
              identityFile = "~/.ssh/stellacode";
              extraOptions = {
                "AddKeysToAgent" = "yes";
              };
            };
            "*" = {
              extraOptions = {
                "HashKnownHosts" = "yes";
                "SendEnv" = "LANG LC_*";
              };
            };
          };
        };

        programs.git = {
          enable = true;
          settings = {
            user = {
              name = identity.gitName;
              email = identity.email;
            };
            include.path = "~/.gitconfig-identity";
          };
        };
      };
    }
  ]);
}
