{ self, ... }: {
  flake.hosts.ItsRedFlame = {
    class = "nixos";
    username = "RedFlame";
    homeDir = "/home/RedFlame";
    flakePath = "/home/RedFlame/Projects/stellyrland";
    passwordSecret = "redflamepsswd";
    graphics = "nvidia";

  };

  flake.modules.nixos.ItsRedFlame = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline

      # Desktop-Adjacent
      services-base
      timecontrol
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
      umbriel

      # Gaming
      steam
      roblox
      flatpak
      freesm
      xclicker

      # Host Specific Config
      ItsRedFlame-host
    ];
  };
}
