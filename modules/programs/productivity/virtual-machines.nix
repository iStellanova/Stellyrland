_: {
  # NixOS Virtual Machines Settings
  flake.modules.nixos.virtual-machines = {pkgs, ...}: {
    config = {
      virtualisation.libvirtd.enable = true;
      environment.systemPackages = [pkgs.virt-manager];
    };
  };

  # Darwin Virtual Machines Settings
  flake.modules.darwin.virtual-machines = _: {
    config = {
      homebrew.casks = ["utm"];
    };
  };
}
