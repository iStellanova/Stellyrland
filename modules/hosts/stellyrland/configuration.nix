{ self, ... }: {
  flake.hosts.stellyrland = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "/run/secrets/stellacode";
    graphics = "amd";
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
      pipewire-lowlatency

      # Boot & Hardware & Storage
      boot
      headless
      initrd
      kernel
      firmware
      gpu
      performance
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
      roblox

      # Productivity
      email
      protonvpn
      psswdmgr

      # Personal Secrets
      personal-secrets

      # Host Specific Config
      stellyrland-host
    ];
  };
}
