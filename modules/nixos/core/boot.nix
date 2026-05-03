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

    # Permission to modify EFI variables.
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Kernel parameters for extreme performance and 3D V-Cache optimization.
    boot.kernelParams = [
      "amdgpu.sg_display=0"             # Fix for white screen/flicker on 7900XTX
      "amdgpu.dc_disable_psr=1"         # Disable Panel Self Refresh to prevent freezes
      "amdgpu.gpu_recovery=1"           # Enable GPU recovery
      "amd_pstate=active"               # Zen 5 Preferred Core ranking (EPP)
      "preempt=full"                    # Full preemption for low latency
      "split_lock_detect=off"           # Prevents performance penalties in gaming
      "transparent_hugepage=always"     # Significant speedup for large-cache CPUs
      "amdgpu.ppfeaturemask=0xffffffff" # Full access to GPU power/clock tuning
    ];

    # Cache mode for AMD X3D V-Cache.
    systemd.tmpfiles.rules = [
      "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
    ];

    # AMDGPU initrd allows the kernel to load AMDGPU drivers early in the boot process.
    hardware.amdgpu.initrd.enable = true;
  };
}
