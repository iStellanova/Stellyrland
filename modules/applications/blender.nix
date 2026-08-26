{
  flake.modules.finix.blender = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.blender ];
  };

  flake.modules.nixos.blender = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.blender ];
  };

  flake.modules.darwin.blender = {
    homebrew.casks = [ "blender" ];
  };
}
