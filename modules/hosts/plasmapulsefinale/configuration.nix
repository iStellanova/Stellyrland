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
    sshKeys = [ ];
  };

  flake.modules.nixos.plasmapulsefinale = {
    # Explicit controller opt-in; stellanova-admin intentionally covers
    # personal access only because it is reused by non-deployment hosts.
    users.users.stellanova.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRgqL5g6rGjR1yoD4XKOx/iHXJgYR9L6U4SU9sfOd7z stellyrlab deployment controller"
    ];

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

      stellanova-admin
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
