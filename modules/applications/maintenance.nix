_: {
  flake.modules.nixos.maintenance = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bleachbit ];
  };

  flake.modules.darwin.maintenance = _: {
    homebrew.casks = [ "cleanmymac" ];
  };
}
