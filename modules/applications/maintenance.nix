{
  modules.nixos.maintenance = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nix-tree ];
  };

  modules.darwin.maintenance = { pkgs, ... }: {
    homebrew.casks = [ "cleanmymac" ];
    environment.systemPackages = [ pkgs.nix-tree ];
  };
}
