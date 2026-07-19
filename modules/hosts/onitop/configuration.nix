{ self, ... }: {
  flake.hosts.onitop = {
    class = "nixos";
    username = "oni";
    homeDir = "/home/oni";
    hostName = "onitop";
    flakePath = "/home/oni/Projects/stellyrland";
    passwordSecret = "onipsswd";
    # Opt out of the shared sshKeys default — oni's account shouldn't carry
    # stellanova's key (see stellanova-admin for her own account instead).
    sshKeys = [ ];
  };

  flake.modules.nixos.onitop = {
    imports = with self.modules.nixos; [
      # Base System
      system-cli
      stellanova-admin
      zfs-snapshots

      # Desktop
      plasma
      fonts
      pipewire
      librewolf
      media

      # Gaming
      steam
      roblox

      # Host Specific Config
      onitop-host
    ];
  };
}
