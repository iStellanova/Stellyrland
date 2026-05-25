_: {
  # NixOS Maintenance Settings
  flake.modules.nixos.maintenance = {pkgs, ...}: {
    config = {
      environment.systemPackages = [pkgs.bleachbit];
    };
  };

  # Darwin Maintenance Settings
  flake.modules.darwin.maintenance = _: {
    config = {
      homebrew.casks = ["cleanmymac"];
    };
  };
}
