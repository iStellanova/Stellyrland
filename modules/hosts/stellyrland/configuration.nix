{ inputs, self, ... }: {
  hosts.stellyrland = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    persistence = true;
    flakePath = "/home/stellanova/Projects/stellyrland";
    dataPath = inputs.my-assets;
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

  modules.nixos.stellyrland.host = {
    system.stateVersion = "25.11";
    imports = with self.modules.nixos; [
      # Base
      base
      cmdline

      # Desktop-Adjacent
      services-base
      system-tools
      maintenance
      xdg

      # Desktop
      easyeffects
      fonts
      umbriel
      noctalia-greeter
      noctalia
      pipewire
      pipewire-lowlatency
      catppuccin
      openrgb

      # Boot & Hardware & Storage
      cachyos-kernel
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
      feishin
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
      hermes-desktop
      discord
      zed

      # Host Specific Config
      stellyrland-host
      self.modules.nixos.stellyrland.stellanova
    ];
  };
}
