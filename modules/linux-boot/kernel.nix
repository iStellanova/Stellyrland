{ inputs, ... }:
{
  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.modules.nixos.kernel = { pkgs, ... }: {
    nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];

    nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
    nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;

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
      "nowatchdog" # Disable software watchdog — server feature, saves interrupt overhead
      "nmi_watchdog=0" # Disable NMI watchdog
      "threadirqs" # Threaded IRQ handlers — lets scx_lavd schedule them for lower latency
      "audit=0" # Disable kernel audit framework — no SELinux/audit rules to serve
    ];

    # Cache mode for AMD X3D V-Cache.
    systemd.tmpfiles.rules = [
      "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
    ];

    # AMDGPU initrd loads GPU drivers early in boot — disabled here as the
    # larger initrd size has no benefit on this configuration.
    hardware.amdgpu.initrd.enable = false;
  };
}
