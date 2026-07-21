_: {
  flake.modules.nixos.email = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.protonmail-desktop ];
  };

  flake.modules.darwin.email = _: {
    homebrew.casks = [ "proton-mail" ];
  };
}
