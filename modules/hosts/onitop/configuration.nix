{ self, ... }: {
  flake.hosts.onitop = {
    class = "nixos";
    username = "oni";
    homeDir = "/home/oni";
    hostName = "onitop";
    flakePath = "/home/oni/Projects/stellyrland";
    passwordSecret = "onipsswd";
    # Opt out of the shared sshKeys default — oni's own account should not
    # carry stellanova's key. Remote admin access is handled separately via
    # the stellanova-admin aspect (its own dedicated account).
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
