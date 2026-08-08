_: {
  flake.modules.nixos.maintenance = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      bleachbit
      nix-tree
    ];
  };

  flake.modules.darwin.maintenance = _: {
    homebrew.casks = [ "cleanmymac" ];
  };
}
