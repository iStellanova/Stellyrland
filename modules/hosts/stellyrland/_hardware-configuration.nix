# Manually maintained hardware configuration for stellyrland (x86_64-linux).
_: {
  boot.kernelModules = [ "kvm-amd" ];

  # Required by ZFS to prevent pool import conflicts between machines.
  # Generated once: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' \n'
  networking.hostId = "63d11f1d";

  fileSystems."/" = {
    device = "zroot/local/root";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "zroot/local/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "zroot/safe/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "zroot/safe/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/STELLYRBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/disk-main-swap";
      randomEncryption.enable = true;
    }
  ];
}
