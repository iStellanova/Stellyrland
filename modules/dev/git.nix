_: {
  flake.modules.homeManager.git =
    { host, ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "github.com" = {
            User = "git";
            IdentityFile = host.gitSshKey;
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
          user.signingKey = host.gitSshKey;
          rerere.enabled = true;
          include.path = "~/.gitconfig-identity";
        };
      };
    };
}
