{ sn, ... }: {
  sn.system = {
    includes = [ sn.services-base ];
  };

  sn.services-base.nixos = _: {
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    services.libinput.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;
    networking.networkmanager.enable = true;
    programs.dconf.enable = true;
    services.dbus.implementation = "broker";
  };
}
