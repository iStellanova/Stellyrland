{sn, ...}: {
  sn.linux-hardware = {includes = [sn.firmware];};

  sn.firmware.nixos = {config, ...}: {
    # Use the ZFS package built against the CachyOS kernel to ensure the
    # userspace tools and kernel module come from the same OpenZFS build.
    boot.zfs.package = config.boot.kernelPackages.zfs_cachyos;

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;
  };
}
