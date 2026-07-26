_: {
  flake.modules.nixos.blender = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.blender ];
  };

  flake.modules.darwin.blender = _: {
    homebrew.casks = [ "blender" ];
  };
}
