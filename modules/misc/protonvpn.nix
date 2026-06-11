_: {
  sn.protonvpn.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.proton-vpn];
  };

  sn.protonvpn.darwin = _: {
    homebrew.casks = ["protonvpn"];
  };
}
