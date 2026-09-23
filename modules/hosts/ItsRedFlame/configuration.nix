{ self, ... }: {
  hosts.ItsRedFlame = {
    class = "nixos";
    username = "RedFlame";
    homeDir = "/home/RedFlame";
    flakePath = "/home/RedFlame/Projects/stellyrland";
    passwordSecret = "redflamepsswd";
    graphics = "nvidia";

  };

  modules.nixos.ItsRedFlame.host = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline
      intranet-connector

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
      media-editing
      audacity
      obs
      kdenlive
      blender
      psswdmgr
      protonvpn

      # Gaming
      steam
      roblox
      flatpak
      freesm
      xclicker

      # Host Specific Config
      ItsRedFlame-host
      self.modules.nixos.ItsRedFlame.RedFlame
      self.modules.nixos.ItsRedFlame.stellanova
    ];
  };
}
