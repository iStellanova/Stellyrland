_: {
  flake.modules.nixos.maintenance = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nix-tree ];
  };

  flake.modules.darwin.maintenance = { pkgs, ... }: {
    homebrew.casks = [ "cleanmymac" ];
    environment.systemPackages = [ pkgs.nix-tree ];
  };
}
