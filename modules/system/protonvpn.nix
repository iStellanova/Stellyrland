_: {
  flake.modules.nixos.protonvpn = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.proton-vpn ];
  };

  flake.modules.darwin.protonvpn = _: {
    homebrew.casks = [ "protonvpn" ];
  };
}
