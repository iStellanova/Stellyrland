{sn, ...}: {
  sn.productivity = {includes = [sn.virtual-machines];};

  sn.virtual-machines.nixos = {pkgs, ...}: {
    virtualisation.libvirtd.enable = true;
    environment.systemPackages = [pkgs.virt-manager];
  };

  sn.virtual-machines.darwin = _: {
    homebrew.casks = ["utm"];
  };
}
