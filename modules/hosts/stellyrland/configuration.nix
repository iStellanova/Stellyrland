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
      # Base
      base
      cmdline

      # Desktop-Adjacent (session/GUI plumbing, not Hyprland-specific)
      services-base
      system-tools
      maintenance
      mime
      xdg

      # Hyprland Desktop
      easyeffects
      fonts
      hyprland
      noctalia-greeter
      noctalia-shell
      pipewire
      pipewire-lowlatency
      catppuccin
      openrgb
      aesthetic

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
