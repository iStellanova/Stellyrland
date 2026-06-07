_: {
  den.aspects.git.homeManager = {host, ...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "stellyrland" = {
          HostName = "stellyrland.tailb15b96.ts.net";
          User = host.username;
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
          name = host.gitName;
          email = host.userEmail;
        };
        include.path = "~/.gitconfig-identity";
      };
    };
  };
}
