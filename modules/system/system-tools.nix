{sn, ...}: {
  sn.system = {includes = [sn.system-tools];};

  sn.system-tools.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      mission-center
    ];
  };
}
