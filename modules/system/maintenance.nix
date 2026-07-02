{ sn, ... }: {
  sn.system = {
    includes = [ sn.maintenance ];
  };

  sn.maintenance.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bleachbit ];
  };

  sn.maintenance.darwin = _: {
    homebrew.casks = [ "cleanmymac" ];
  };
}
