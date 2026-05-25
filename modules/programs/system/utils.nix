_: {
  # NixOS GUI utilities Settings
  flake.modules.nixos.utils = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        gnome-disk-utility
        mission-center
        planify
        proton-vpn
      ];
    };
  };

  # Darwin GUI utilities Settings
  flake.modules.darwin.utils = _: {
    config = {
      homebrew.casks = ["protonvpn"];
    };
  };
}
