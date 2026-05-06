{ config, lib, ... }:

{
  options.aspects.core.services-base.enable = lib.mkEnableOption "Base system services" // { default = true; };

  config = lib.mkIf config.aspects.core.services-base.enable {
    services.udisks2.enable = true; # Disk device manager.
    services.gvfs.enable = true; # Virtual file system manager. For virtual machines.
    services.libinput.enable = true; # Input device manager.
    services.gnome.gnome-keyring.enable = true; # Credential manager. Stores passwords and secrets.
    security.polkit.enable = true; # Access control manager. For those popups that require authentication.
    security.pam.services.greetd.enableGnomeKeyring = true; # Enable GNOME Keyring for greetd.
    networking.networkmanager.enable = true; # Network manager.
    programs.dconf.enable = true; # Configuration management. Stores GNOME settings.

    # Use dbus-broker for high-performance IPC.
    services.dbus.implementation = "broker";

    # Enable SSH server for remote access
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 41641 ]; # Tailscale
      allowedUDPPortRanges = [
        { from = 50000; to = 65535; } # Discord/WebRTC
      ];
    };
  };
}
