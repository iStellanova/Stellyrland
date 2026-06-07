_: {
  den.aspects.virtual-machines.nixos = {pkgs, ...}: {
    virtualisation.libvirtd.enable = true;
    environment.systemPackages = [pkgs.virt-manager];
  };

  den.aspects.virtual-machines.darwin = _: {
    homebrew.casks = ["utm"];
  };
}
