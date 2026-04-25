{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Enable Aspects ---
  aspects = {
    core = {
      enable = true;
      nix-settings.enable = true;
      users.enable = true;
      hardware.enable = true;
      boot.enable = true;
      fonts.enable = true;
      storage.enable = true;
      services-base.enable = true;
      xdg.enable = true;
    };

    desktop = {
      hyprland.enable = true;
      styling.enable = true;
    };

    programs = {
      cli.enable = true;
      aesthetic.enable = true;
      media.enable = true;
      utils.enable = true;
      network.enable = true;
      browser.enable = true;
      gaming.enable = true;
      git.enable = true;
      zsh.enable = true;
      neovim.enable = true;
      vesktop.enable = true;
      noctalia-shell.enable = true;
      antigravity.enable = true;
      btop.enable = true;
      cava.enable = true;
      fastfetch.enable = true;
      gsr.enable = true;
      kitty.enable = true;
      ns.enable = true;
      yazi.enable = true;
      zed.enable = true;
    };

    services = {
      desktop-services.enable = true;
      coolercontrol.enable = true;
      lact.enable = true;
      openrgb.enable = true;
    };
  };

  networking.hostName = "stellyrland";

  fileSystems."/home/stellanova/ExtraDisk" = {
    device = "/dev/disk/by-uuid/5082e55b-50fd-4f53-a753-157fa30415cc";
    fsType = "ext4";
    options = [ "nofail" "x-gvfs-show" "x-gvfs-name=Extra Disk" ];
  };
}
