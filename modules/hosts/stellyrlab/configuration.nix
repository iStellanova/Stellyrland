{ self, ... }: {
  flake.hosts.stellyrlab = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "/run/secrets/stellacode";
    sshKeys = self.constants.sshKeys;
  };

  flake.modules.nixos.stellyrlab = {
    imports = with self.modules.nixos; [
      base
      boot
      cmdline
      maintenance
      personal-secrets
      stellyrlab-host
      deployment-controller
    ];
  };
}
