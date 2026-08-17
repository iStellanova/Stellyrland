# Generic removable-disk hardware configuration for stellyrstick.
{
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "usbhid"
    "hid_generic"
  ];

  fileSystems."/" = {
    device = "/dev/mapper/stellyrstick-root";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8C43-FE21";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  boot.initrd.luks.devices.stellyrstick-root.device = "/dev/disk/by-partlabel/disk-main-root";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
