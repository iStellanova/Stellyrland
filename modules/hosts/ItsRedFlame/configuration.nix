{ self, ... }: {
  flake.hosts.ItsRedFlame = {
    class = "nixos";
    username = "RedFlame";
    homeDir = "/home/RedFlame";
    flakePath = "/home/RedFlame/Projects/stellyrland";
    passwordSecret = "redflamepsswd";
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
      zfs-snapshots

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
      email
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
