{ self, ... }: {
  flake.hosts.stellyrlab = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
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
    ];
  };
}
