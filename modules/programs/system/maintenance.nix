_: {
  den.aspects.maintenance.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.bleachbit];
  };

  den.aspects.maintenance.darwin = _: {
    homebrew.casks = ["cleanmymac"];
  };
}
