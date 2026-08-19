# Hardware and runtime mounts for stellyrlab (Dell OptiPlex 7060).
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
    "xhci_pci"
    "nvme"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  networking.hostId = "978a4bd9";

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
  fileSystems."/home" = {
    device = "zroot/safe/home";
    fsType = "zfs";
  };
  fileSystems."/srv" = {
    device = "zroot/safe/srv";
    fsType = "zfs";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/STELLYRBOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/disk-main-swap";
      randomEncryption.enable = true;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
