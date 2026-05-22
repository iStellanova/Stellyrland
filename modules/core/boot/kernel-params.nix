_: {
  config = {
    # NixOS kernel parameters
    flake.modules.nixos.kernel-params = {
      config,
      lib,
      ...
    }: {
      options.aspects.core.kernel-params.enable = lib.mkEnableOption "Hardware-specific kernel parameters";

      config = lib.mkIf config.aspects.core.kernel-params.enable {
        # Kernel parameters for extreme performance and 3D V-Cache optimization.
        boot.kernelParams = [
          "acpi_enforce_resources=lax" # Allow i2c-piix4 to access SMBus for RAM RGB
          "amdgpu.sg_display=0" # Fix for white screen/flicker on 7900XTX
          "amdgpu.dc_disable_psr=1" # Disable Panel Self Refresh to prevent freezes
          "amdgpu.gpu_recovery=1" # Enable GPU recovery
          "amd_pstate=active" # Zen 5 Preferred Core ranking (EPP)
          "preempt=full" # Full preemption for low latency
          "udev.event-timeout=5" # Prevent hardware stalls from hanging boot
          "split_lock_detect=off" # Prevents performance penalties in gaming
          "transparent_hugepage=always" # Significant speedup for large-cache CPUs
          "amdgpu.ppfeaturemask=0xffffffff" # Full access to GPU power/clock tuning
          "usbcore.autosuspend=-1" # Disable early USB power saving
          "rootdelay=10" # Give AM5 USB controllers extra time to fully initialize
        ];

        # Cache mode for AMD X3D V-Cache.
        systemd.tmpfiles.rules = [
          "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
        ];

        # AMDGPU initrd allows the kernel to load AMDGPU drivers early in the boot
        # process — disabled here as it increases initrd size without benefit on
        # this configuration.
        hardware.amdgpu.initrd.enable = false;
      };
    };
  };
}
