_: {
  den.aspects.utils.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      mission-center
      planify
      proton-vpn
    ];
  };

  den.aspects.utils.darwin = _: {
    homebrew.casks = ["protonvpn"];
  };
}
