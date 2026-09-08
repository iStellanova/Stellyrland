{
  flake.modules.homeManager.git =
    {
      host,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.lazygit ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "github.com" = {
            User = "git";
            IdentityFile = host.gitSshKey;
            AddKeysToAgent = "yes";
          };
          "* !github-stellxie" = {
            HashKnownHosts = "yes";
            SendEnv = "LANG LC_*";
            IdentityFile = host.gitSshKey;
          };
        };
      };

      programs.git = {
        enable = true;
        signing = {
          allowedSigners = ''
            iStellanova@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr topcoat.graver.7c@icloud.com
            313256644+Stellxie@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmO/zUfyJQnYGKkgVb1jx3Ju+P4opxEh310ImH9l/ts Stellxie Git commit signing
          '';
          format = "ssh";
          key = host.gitSshKey;
          signByDefault = true;
        };
        settings = {
          user = {
            name = host.gitName;
            email = host.userEmail;
          };
          rerere.enabled = true;
        };
      };
    };
}
