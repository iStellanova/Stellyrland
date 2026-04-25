{ config, lib, pkgs, ... }:

{
  options.aspects.core.boot.enable = lib.mkEnableOption "Core boot settings" // { default = true; };

  config = lib.mkIf config.aspects.core.boot.enable {
    environment.systemPackages = [ pkgs.efibootmgr ];

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
      "amdgpu.sg_display=0"    # Fix for white screen/flicker on 7900XTX
      "amdgpu.dc_disable_psr=1"
      "amdgpu.gpu_recovery=1"           # Enable GPU recovery
      "pcie_aspm=off"          # WiFi stability
      "amd_pstate=active"      # Zen 5 Preferred Core ranking
      "preempt=full"           # Low latency
      "split_lock_detect=off"  # Smooth gaming
      "transparent_hugepage=madvise" # Smart memory usage
      "amdgpu.ppfeaturemask=0xffffffff" # GPU tuning
      "amdgpu.ignore_min_pcap=1"        # Uncap power limits
    ];

    boot.kernelModules = [ "mt7921e" ];
    boot.initrd.kernelModules = [ ];
    hardware.amdgpu.initrd.enable = true;
  };
}
