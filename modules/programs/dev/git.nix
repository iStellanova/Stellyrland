_: {
  # Home Manager Git/SSH Settings
  flake.modules.homeManager.git = {osConfig, ...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "stellyrland" = {
          HostName = "stellyrland.tailb15b96.ts.net";
          User = osConfig.identity.username;
          IdentityFile = "/run/secrets/stellacode";
        };
        "github.com" = {
          User = "git";
          IdentityFile = "/run/secrets/stellacode";
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
          name = osConfig.identity.gitName;
          email = osConfig.identity.userEmail;
        };
        include.path = "~/.gitconfig-identity";
      };
    };
  };
}
