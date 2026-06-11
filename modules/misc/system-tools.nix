_: {
  sn.system-tools.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      mission-center
    ];
  };
}
