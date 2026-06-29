{sn, ...}: {
  sn.dev = {includes = [sn.git];};

  sn.git.homeManager = {
    host,
    pkgs,
    ...
  }: let
    sshKey =
      if pkgs.stdenv.isDarwin
      then "~/.ssh/stellacode"
      else "/run/secrets/stellacode";
  in {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "stellyrland" = {
          HostName = "stellyrland.tailb15b96.ts.net";
          User = host.username;
          IdentityFile = sshKey;
        };
        "github.com" = {
          User = "git";
          IdentityFile = sshKey;
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
        user.signingKey = sshKey;
        rerere.enabled = true;
        include.path = "~/.gitconfig-identity";
      };
    };
  };
}
