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

  };

  flake.modules.nixos.ItsRedFlame = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline
      deployment-recipient

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
