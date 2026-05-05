{ identity, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Aspects - The "toggle" system for modular features.
  # Every attribute corresponds to an enable option defined in the modules/ directory.
  aspects = {
    core = {
      enable = true;
      nix-settings.enable = true;
      users.enable = true;
      hardware.enable = true;
      boot.enable = true;
      fonts.enable = true;
      networking.enable = true;
      storage.enable = true;
      services-base.enable = true;
      xdg.enable = true;
    };
    # Desktop Aspects - Graphical environment and styling.
    desktop = {
      hyprland.enable = true;
      styling.enable = true;
    };
    # Program Aspects - CLI and GUI applications.
    programs = {
      cli.enable = true;
      gemini.enable = true;
      aesthetic.enable = true;
      media.enable = true;
      utils.enable = true;
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
    # Service Aspects - Background daemons and hardware controllers.
    services = {
      desktop-services.enable = true;
      coolercontrol.enable = true;
      lact.enable = true;
      openrgb.enable = true;
    };
  };
  # Hostname
  networking.hostName = "stellyrland";

  # Extra Storage:
  # nofail ensures the system still boots if the drive is missing.
  # x-gvfs options make the drive easily accessible and identifiable in the file manager.
  fileSystems."/home/${identity.name}/ExtraDisk" = {
    device = "/dev/disk/by-uuid/5082e55b-50fd-4f53-a753-157fa30415cc";
    fsType = "ext4";
    options = [ "nofail" "x-gvfs-show" "x-gvfs-name=Extra Disk" "noatime" "lazytime" ];
  };
}
