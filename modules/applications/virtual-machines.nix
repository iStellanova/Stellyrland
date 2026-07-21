_: {
  flake.modules.nixos.virtual-machines = { pkgs, host, ... }: {
    virtualisation.libvirtd.enable = true;
    environment.systemPackages = [ pkgs.virt-manager ];
    users.users.${host.username}.extraGroups = [ "libvirtd" ];
  };

  flake.modules.darwin.virtual-machines = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.utm ];
  };
}
