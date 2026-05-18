{ config, lib, ... }:

{
  options.aspects.core.services-base.enable = lib.mkEnableOption "Base system services";

  config = lib.mkIf config.aspects.core.services-base.enable {
    services.udisks2.enable = true; # Disk device manager.
    services.gvfs.enable = true; # GNOME virtual filesystem — enables trash, network mounts, MTP, and URI schemes in Nautilus.
    services.libinput.enable = true; # Input device manager.
    services.gnome.gnome-keyring.enable = true; # Credential manager. Stores passwords and secrets.
    security.polkit.enable = true; # Access control manager. For those popups that require authentication.
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
      # loose: required so Tailscale traffic (which arrives on a different interface
      # than the routing table expects) isn't dropped by the reverse path filter.
      checkReversePath = "loose";
      allowedUDPPorts = [ 41641 ]; # Tailscale
      # Discord voice uses this full range for its gateway servers. Without it,
      # Tailscale's routing changes break inbound UDP return packets for VoIP.
      allowedUDPPortRanges = [
        { from = 50000; to = 65535; }
      ];
    };
  };
}
