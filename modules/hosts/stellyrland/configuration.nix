{ self, ... }: {
  flake.hosts.stellyrland = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    hostName = "stellyrland";
    flakePath = "/home/stellanova/Projects/stellyrland";
    monitorPriority = [
      "DP-2"
      "DP-3"
    ];
    features.hdr = true;
  };

  flake.modules.nixos.stellyrland = {
    imports = with self.modules.nixos; [
      # Base Desktop System
      system-desktop

      # Boot & Hardware & Storage
      boot
      headless
      initrd
      kernel
      firmware
      gpu
      performance
      disko
      extra-disk
      hdd
      preservation
      storage

      # Gaming
      game-launchers
      gamescope
      steam
      vr

      # Media
      media-editing
      media
      music
      gsr

      # Dev Tools
      ai-tools

      # Desktop Applications
      zen-browser
      nautilus

      # Productivity
      email

      # Host Specific Config
      stellyrland-host
    ];
  };
}
