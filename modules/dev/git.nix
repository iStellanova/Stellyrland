_: {
  flake.modules.homeManager.git =
    {
      config,
      host,
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.git-crypt
        pkgs.lazygit
      ];

      home.file.".config/git/allowed_signers".text = ''
        iStellanova@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr topcoat.graver.7c@icloud.com
        313256644+Stellxie@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmO/zUfyJQnYGKkgVb1jx3Ju+P4opxEh310ImH9l/ts Stellxie Git commit signing
      '';

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
          gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
          user.signingKey = host.gitSshKey;
          rerere.enabled = true;
          include.path = "~/.gitconfig-identity";
        };
      };
    };
}
