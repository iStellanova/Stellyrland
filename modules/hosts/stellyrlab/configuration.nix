{ self, ... }: {
  hosts.stellyrlab = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "/run/secrets/stellacode";

  };

  modules.nixos.stellyrlab.host = {
    imports = with self.modules.nixos; [
      base
      cmdline
      maintenance
      cachyos-kernel
      lanzaboote
      stellyrlab-host
      backup-host
      backup-sender
      binary-cache-server
      hermes
      navidrome
      self.modules.nixos.stellyrlab.stellanova
    ];
  };
}
