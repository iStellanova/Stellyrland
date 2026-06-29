{sn, ...}: {
  sn.system = {includes = [sn.protonvpn];};

  sn.protonvpn.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.proton-vpn];
  };

  sn.protonvpn.darwin = _: {
    homebrew.casks = ["protonvpn"];
  };
}
