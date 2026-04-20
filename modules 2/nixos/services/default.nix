{
  imports = [ ./finit-services.nix ];
  services.udisks2.enable = false;
  networking.networkmanager.enable = false;
  services.btrfs.autoScrub.enable = false; # Managed by finit
  security.polkit.enable = true;
  services.gnome.tinysparql.enable = true;
  services.gnome.localsearch.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  programs.dconf.enable = true;
  programs.gamemode.enable = true; # Daemon managed by finit
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  networking.networkmanager.enable = true;
  services.libinput.enable = true;
  programs.coolercontrol.enable = true;
  programs.steam.enable = true;
  programs.seahorse.enable = true;
  programs.gpu-screen-recorder.enable = true;
}
