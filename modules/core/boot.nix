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

    # Kernel - Using optimized BORE + LTO CachyOS kernel (x86-64-v4) for 9950X3D
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    boot.kernelParams = [
      "amdgpu.gpu_recovery=1"           # Enable GPU recovery
      "amd_pstate=active"               # Zen 5 Preferred Core ranking
      "preempt=full"                    # Low latency
      "split_lock_detect=off"           # Smooth gaming
      "transparent_hugepage=always"    # Optimized for 3D V-Cache
      "amdgpu.ppfeaturemask=0xffffffff" # GPU tuning
    ];

    boot.kernelModules = [ "mt7921e" ];
    boot.initrd.kernelModules = [ ];
    hardware.amdgpu.initrd.enable = true;
  };
}
