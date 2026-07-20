{ self, ... }: {
  flake.hosts.plasmapulsefinale = {
    class = "nixos";
    username = "tan13";
    homeDir = "/home/tan13";
    flakePath = "/home/tan13/Projects/stellyrland";
    passwordSecret = "tan13psswd";
    graphics = "intel";
    # Opt out of the shared sshKeys default — tan13's account shouldn't carry
    # stellanova's key (see stellanova-admin for her own account instead).
    sshKeys = [ ];
  };

  flake.modules.nixos.plasmapulsefinale = {
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
      plasmapulsefinale-host
    ];
  };
}
