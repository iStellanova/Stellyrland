{ self, ... }: {
  flake.hosts.stellyrland = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    persistence = true;
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
      deployment-recipient
      cmdline

      # Desktop-Adjacent (session/GUI plumbing, not Hyprland-specific)
      services-base
      system-tools
      maintenance
      xdg

      # Hyprland Desktop
      easyeffects
      fonts
      hyprland
      noctalia-greeter
      noctalia
      pipewire
      pipewire-lowlatency
      catppuccin
      openrgb

      # Boot & Hardware & Storage
      boot
      headless
      initrd
      kernel
      firmware
      gpu
      performance
      binfmt
      extra-disk
      hdd-source
      preservation
      zfs-snapshots-sanoid
      zfs-snapshots-builtin

      # Gaming
      game-launchers
      gamescope
      steam
      vr

      # Media
      media-editing
      obs
      media
      music
      gsr

      # Desktop Applications
      nautilus
      zen-browser
      roblox

      # Productivity
      email
      protonvpn
      psswdmgr

      # Persistence companions for Home Manager applications
      opencode
      discord

      # Personal Secrets
      personal-secrets

      # Host Specific Config
      stellyrland-host
    ];
  };
}
