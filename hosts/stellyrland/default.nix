{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Every attribute corresponds to an enable option defined in the modules/ directory.
  aspects = {
    core = {
      enable = true;
      nix-settings = {
        enable = true;
        cores = 24; # Reserve 8 threads for responsiveness on the 9950X3D (32 logical cores).
      };
      users.enable = true;
      hardware.enable = true;
      boot = {
        enable = true;
        secureBoot = true;
      };
      kernel-params.enable = true;
      initrd.enable = true;
      secrets.enable = true;
      kernel.enable = true;
      fonts.enable = true;
      networking.enable = true;
      storage.enable = true;
      extra-disk.enable = true;
      impermanence.enable = true;
      services-base.enable = true;
      xdg.enable = true;
      headless = {
        enable = true;
        disabledPorts = [
          "DP-2"
          "DP-3"
        ];
      };
    };
    # Desktop Aspects
    desktop = {
      hyprland.enable = true;
      styling.enable = true;
    };
    # Program Aspects
    programs = {
      cli.enable = true;
      ai-tools.enable = true;
      aesthetic.enable = true;
      background-sounds.enable = true;
      maintenance.enable = true;
      media.enable = true;
      media-editing.enable = true;
      utils.enable = true;
      browser.enable = true;
      gaming.enable = true;
      git.enable = true;
      zsh.enable = true;
      nixvim.enable = true;
      discord-music-rpc.enable = true;
      bitwarden.enable = true;
      vesktop.enable = true;
      noctalia-shell.enable = true;
      btop.enable = true;
      cava.enable = true;
      fastfetch.enable = true;
      gsr.enable = true;
      kitty.enable = true;
      nix-index.enable = true;
      ns.enable = true;
      yazi.enable = true;
      nautilus.enable = true;
      zed.enable = true;
    };
    # Service Aspects
    services = {
      greetd.enable = true;
      flatpak.enable = true;
      seahorse.enable = true;
      coolercontrol.enable = true;
      lact.enable = true;
      openrgb.enable = true;
      ai = {
        enable = true;
        openWebUI.port = 8090;
      };
    };
  };

  # Hostname
  networking.hostName = "stellyrland";
}
