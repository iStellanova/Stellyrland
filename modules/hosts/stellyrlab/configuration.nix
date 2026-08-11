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
    backupHdd = {
      sources = {
        stellyrland = {
          host = "stellyrland.tailb15b96.ts.net";
          dirs = {
            home = {
              source = "zroot/safe/home";
              target = "home";
            };
            persist = {
              source = "zroot/safe/persist";
              target = "persist";
            };
          };
        };
        stellyrlab = {
          host = null;
          dirs = {
            home = {
              source = "zroot/safe/home";
              target = "homelab-home";
            };
          };
        };
      };
    };
  };

  flake.modules.nixos.stellyrlab = {
    imports = with self.modules.nixos; [
      base
      boot
      cmdline
      maintenance
      personal-secrets
      hdd
      stellyrlab-host
      deployment-controller
    ];
  };
}
