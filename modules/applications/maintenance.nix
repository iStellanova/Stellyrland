_: {
  flake.modules.nixos.maintenance = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nix-tree
    ];
  };

  flake.modules.darwin.maintenance = _: {
    homebrew.casks = [ "cleanmymac" ];
  };
}
