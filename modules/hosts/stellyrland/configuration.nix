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
    sshKeys = self.constants.sshKeys ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRgqL5g6rGjR1yoD4XKOx/iHXJgYR9L6U4SU9sfOd7z stellyrlab deployment controller"
    ];
    graphics = "amd";
    monitorPriority = [
      "DP-2"
      "DP-3"
    ];
    features.hdr = true;
  };

  flake.modules.nixos.stellyrland = { host, ... }: {
    # Lets stellyrlab transfer locally coordinated closures to this target.
    nix.settings.trusted-users = [ host.username ];

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
      hdd
      preservation
      zfs-snapshots-sanoid

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
