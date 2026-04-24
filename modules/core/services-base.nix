{ config, lib, pkgs, ... }:

{
  options.aspects.core.services-base.enable = lib.mkEnableOption "Base system services" // { default = true; };

  config = lib.mkIf config.aspects.core.services-base.enable {
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    services.libinput.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    networking.networkmanager.enable = true;
    programs.dconf.enable = true;
  };
}
