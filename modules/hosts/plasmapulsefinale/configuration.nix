{ self, ... }: {
  hosts.plasmapulsefinale = {
    class = "nixos";
    username = "tan13";
    homeDir = "/home/tan13";
    flakePath = "/home/tan13/Projects/stellyrland";
    passwordSecret = "tan13psswd";

  };

  modules.nixos.plasmapulsefinale.host = {
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
      self.modules.nixos.plasmapulsefinale.tan13
      self.modules.nixos.plasmapulsefinale.stellanova
    ];
  };
}
