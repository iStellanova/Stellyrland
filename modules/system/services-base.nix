_: {
  flake.modules.nixos.services-base =
    { lib, host, ... }:
    {
      services.udisks2.enable = true;
      services.gvfs.enable = true;
      services.libinput.enable = true;
      security.polkit.enable = true;
      networking.networkmanager.enable = true;
      programs.dconf.enable = true;
      services.dbus.implementation = "broker";

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".directories = [
          "/var/lib/NetworkManager"
          "/etc/NetworkManager"
        ];
      };
    };
}
