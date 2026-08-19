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

    backup = {
      receiver = {
        address = "172.31.255.1";
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCz+XUleiNbgSwcZHvxOXXTbihnTIRoDKoXr+2zCSgA";
      };
      datasets = {
        home = "zroot/safe/home";
        persist = "zroot/safe/persist";
      };
    };
    graphics = "amd";
    monitorPriority = [
      "DP-2"
      "DP-3"
    ];
    features.hdr = true;
  };

  flake.modules.nixos.stellyrland = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      # Base
      base
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
      lanzaboote
      binfmt
      backup-service
      preservation

      # Gaming
      game-launchers
      gamescope
      steam
      vr

      # Media
      media-editing
      obs
      media
      lollypop
      soulseek
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
      zed

      # Personal Secrets

      # Host Specific Config
      stellyrland-host
    ];
  };
}
