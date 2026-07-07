{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.virtual-machines ];
  };

  sn.virtual-machines.nixos = { pkgs, host, ... }: {
    virtualisation.libvirtd.enable = true;
    environment.systemPackages = [ pkgs.virt-manager ];
    users.users.${host.username}.extraGroups = [ "libvirtd" ];
  };

  sn.virtual-machines.darwin = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.utm ];
  };
}
