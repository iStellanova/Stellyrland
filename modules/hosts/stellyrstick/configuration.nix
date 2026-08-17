{ self, ... }:
{
  flake.hosts.stellyrstick = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
  };

  flake.modules.nixos.stellyrstick = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      core
      lix
      nix-settings
      openssh
      users
      secrets
      avahi
      cmdline
      services-base
      deployment-recipient
      stellyrstick-host
      stellanova
    ];

    home-manager.users.stellanova.imports = with self.modules.homeManager; [
      base
      cmdline
    ];
  };
}
