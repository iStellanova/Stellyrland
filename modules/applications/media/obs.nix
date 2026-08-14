_: {
  flake.modules.nixos.obs = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.obs-studio ];
  };

  flake.modules.darwin.obs = _: {
    homebrew.casks = [ "obs" ];
  };
}
