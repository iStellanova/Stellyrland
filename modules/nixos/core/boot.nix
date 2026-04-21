{ pkgs, ... }:

{
  # Use GRUB EFI boot loader.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use Linux Zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    "pcie_aspm=off"          # WiFi stability
    "amd_pstate=active"      # Zen 5 Preferred Core ranking
    "preempt=full"           # Low latency
    "split_lock_detect=off"  # Smooth gaming
    "transparent_hugepage=madvise" # Smart memory usage
    "amdgpu.dcdebugmask=0x10"
    "amdgpu.ppfeaturemask=0xffffffff" # GPU tuning
    "amdgpu.ignore_min_pcap=1"        # Uncap power limits
    "udev.log_level=debug"            # Debug boot hangs
  ];

  boot.kernelModules = [ "mt7921e" ];
  boot.initrd.kernelModules = [ ];
  hardware.amdgpu.initrd.enable = false;
}
