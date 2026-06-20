_: {
  sn.git.homeManager = {
    host,
    ...
  }: {
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

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = host.gitName;
          email = host.userEmail;
        };
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.format = "ssh";
        user.signingKey = "/run/secrets/stellacode";
        rerere.enabled = true;
        include.path = "~/.gitconfig-identity";
      };
    };
  };
}
