{ self, ... }: {
  flake.hosts.plasmapulsefinale = {
    class = "nixos";
    username = "tan13";
    homeDir = "/home/tan13";
    flakePath = "/home/tan13/Projects/stellyrland";
    passwordSecret = "tan13psswd";
    # Currently unused — this host runs Plasma with manual GPU driver setup
    # below, not hyprland's host.graphics-based selection. Kept for if this
    # host ever switches window managers.
    graphics = "intel";

  };

  flake.modules.nixos.plasmapulsefinale = {
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline

      # Desktop-Adjacent
      services-base
      system-tools
      maintenance
      xdg

      deployment-recipient
      zfs-snapshots-builtin

      # Desktop
      plasma
      fonts
      pipewire
      librewolf
      media
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
