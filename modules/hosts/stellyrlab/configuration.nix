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

    backup = {
      datasets = {
        home = "zroot/safe/home";
      };
      enrolled = {
        stellyrlab = {
          host = null;
          user = "stellanova";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr";
          datasets = {
            home = {
              source = "zroot/safe/home";
              target = "home";
            };
          };
        };
        stellyrland = {
          host = "172.31.255.2";
          user = "stellanova";
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr";
          datasets = {
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
      };
    };
  };

  flake.modules.nixos.stellyrlab = {
    imports = with self.modules.nixos; [
      base
      cmdline
      maintenance
      lanzaboote

      backup-service
      stellyrlab-host
      binary-cache-server
      deployment-distributor
      hermes
    ];
  };
}
