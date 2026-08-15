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
      users.users.${host.username}.extraGroups = [
        "video"
        "render"
      ];

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".directories = [
          "/var/lib/NetworkManager"
          "/etc/NetworkManager"
        ];
      };
    };
}
