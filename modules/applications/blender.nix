{
  modules.nixos.blender = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.blender ];
  };

  modules.darwin.blender = {
    homebrew.casks = [ "blender" ];
  };
}
