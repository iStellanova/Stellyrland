{ self, ... }: {
  flake.hosts.plasmapulsefinale = {
    class = "nixos";
    username = "tan13";
    homeDir = "/home/tan13";
    flakePath = "/home/tan13/Projects/stellyrland";
    passwordSecret = "tan13psswd";

  };

  flake.modules.nixos.plasmapulsefinale = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline

      # Desktop-Adjacent
      services-base
      system-tools
      maintenance
      xdg
      zfs-snapshots-builtin

      # Desktop
      plasma
      fonts
      pipewire
      librewolf
      media
      soulseek
      obs

      # Gaming
      steam
      roblox
      freesm

      # Host Specific Config
      plasmapulsefinale-host
    ];
  };
}
