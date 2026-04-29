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

    # Kernel - Using optimized BORE + LTO CachyOS kernel (x86-64-v4) for 9950X3D
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    # Kernel parameters.
    boot.kernelParams = [
      "amdgpu.gpu_recovery=1"           # Enable GPU recovery
      "amd_pstate=active"               # Zen 5 Preferred Core ranking
      "preempt=full"                    # Low latency
      "split_lock_detect=off"           # Smooth gaming
      "transparent_hugepage=always"     # Optimized for 3D V-Cache
      "amdgpu.ppfeaturemask=0xffffffff" # GPU tuning
    ];

    # Cache mode for AMD X3D V-Cache.
    systemd.tmpfiles.rules = [
      "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
    ];

    # Kernel modules.
    boot.kernelModules = [ "mt7921e" ];

    # AMDGPU initrd allows the kernel to load AMDGPU drivers early in the boot process.
    hardware.amdgpu.initrd.enable = true;
  };
}
