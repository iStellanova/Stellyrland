# Hardware configuration for ItsRedFlame (x86_64-linux, HP desktop, Ryzen 7 1700 + GTX 1660).
# Kernel modules confirmed via `nixos-generate-config --show-hardware-config` on the live
# installer (booted from USB, disk not yet formatted — fileSystems/swapDevices below are
# hand-written to match the disko layout instead, since that flag can't see the not-yet-created
# ZFS pool). ums_realtek showed up too but that's this USB stick's own storage bridge chip,
# not needed for booting off the internal SATA disk.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  # Required by ZFS to prevent pool import conflicts between machines.
  # Generated once: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' \n'
  networking.hostId = "aa774b2b";

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "zroot/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "zroot/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/REDFLAMEBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/disk-main-swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
