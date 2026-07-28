{ self, ... }: {
  flake.hosts.ItsRedFlame = {
    class = "nixos";
    username = "RedFlame";
    homeDir = "/home/RedFlame";
    flakePath = "/home/RedFlame/Projects/stellyrland";
    passwordSecret = "redflamepsswd";
    # Currently unused — this host runs Plasma with manual GPU driver setup
    # below, not hyprland's host.graphics-based selection. Kept for if this
    # host ever switches window managers.
    graphics = "nvidia";
    # Opt out of the shared default — see stellanova-admin for remote access instead.
    sshKeys = [ ];
  };

  flake.modules.nixos.ItsRedFlame = {
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline

      # Desktop-Adjacent
      services-base
      system-tools
      maintenance
      mime
      xdg

      # Remote admin
      stellanova-admin
      zfs-snapshots-builtin

      # Boot
      boot

      # Desktop
      plasma
      fonts
      pipewire
      librewolf
      media
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
    ];
  };
}
