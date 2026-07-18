# Hardware configuration for onitop (x86_64-linux, Dell Latitude E5520).
# Based on nixos-generate-config output; maintained manually from this point.
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
    "ehci_pci"
    "ahci"
    "firewire_ohci"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # Required by ZFS to prevent pool import conflicts between machines.
  # Generated once: head -c4 /dev/urandom | od -A none -t x4 | tr -d ' \n'
  networking.hostId = "2086210e";

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

  swapDevices = [
    { device = "/dev/disk/by-partlabel/disk-main-swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
