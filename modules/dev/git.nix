_: {
  flake.modules.homeManager.git =
    { host, pkgs, ... }:
    {
      home.packages = [
        pkgs.git-crypt
        pkgs.lazygit
      ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "github.com" = {
            User = "git";
            IdentityFile = host.gitSshKey;
            AddKeysToAgent = "yes";
          };
          "github-stellxie" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = "/run/secrets/stellxie-github-auth";
            IdentitiesOnly = "yes";
          };
          "* !github-stellxie !deploy-*" = {
            HashKnownHosts = "yes";
            SendEnv = "LANG LC_*";
            IdentityFile = host.gitSshKey;
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
