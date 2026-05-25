_: {
  # NixOS Maintenance Settings
  flake.modules.nixos.maintenance = {pkgs, ...}: {
    environment.systemPackages = [pkgs.bleachbit];
  };

  # Darwin Maintenance Settings
  flake.modules.darwin.maintenance = _: {
    homebrew.casks = ["cleanmymac"];
  };
}
