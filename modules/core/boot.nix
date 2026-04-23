{ config, lib, pkgs, ... }:

{
  options.aspects.core.boot.enable = lib.mkEnableOption "Core boot settings" // { default = true; };

  config = lib.mkIf config.aspects.core.boot.enable {
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
      "amdgpu.dc_disable_psr=1"
      "pcie_aspm=off"          # WiFi stability
      "amd_pstate=active"      # Zen 5 Preferred Core ranking
      "preempt=full"           # Low latency
      "split_lock_detect=off"  # Smooth gaming
      "transparent_hugepage=madvise" # Smart memory usage
      "amdgpu.dcdebugmask=0x10"
      "amdgpu.ppfeaturemask=0xffffffff" # GPU tuning
      "amdgpu.ignore_min_pcap=1"        # Uncap power limits
    ];

    boot.kernelModules = [ "mt7921e" ];
    boot.initrd.kernelModules = [ ];
    hardware.amdgpu.initrd.enable = true;
  };
}
