{ config, lib, ... }:

{
  options.aspects.programs.ssh.enable = lib.mkEnableOption "SSH client and git identity configuration";

  config = lib.mkIf config.aspects.programs.ssh.enable {
    # NixOS level
    programs.ssh.startAgent = true;

    # Conflict with gnome gcr-ssh-agent
    services.gnome.gcr-ssh-agent.enable = false;

    # Home Manager level
    home-manager.users.stellanova = {
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
            name = "istellanova";
            email = "istellanova@users.noreply.github.com";
          };
          include.path = "~/.gitconfig-identity";
        };
      };
    };
  };
}
