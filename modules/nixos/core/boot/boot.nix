{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aspects.core.boot.enable = lib.mkEnableOption "Core boot settings";

  config = lib.mkIf config.aspects.core.boot.enable {
    environment.systemPackages = [pkgs.efibootmgr];

    # Use GRUB EFI boot loader.
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };

    # Permission to modify EFI variables.
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel package selection is handled by aspects.core.kernel (kernel.nix).
    # When aspects.core.kernel.enable = false, the system falls back to the
    # default NixOS kernel. Set it to true in the host config to use the
    # stripped cachyos-bore-lto build.

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
    ];

    # Cache mode for AMD X3D V-Cache.
    systemd.tmpfiles.rules = [
      "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
    ];

    # AMDGPU initrd allows the kernel to load AMDGPU drivers early in the boot process.
    hardware.amdgpu.initrd.enable = true;

    # Tighter udev timeout for the initrd stage (fewer devices, 5s is safe).
    # Mirrors the system-level timeout in system.nix — both prevent Kraken Z USB
    # stalls from hanging the sequence for the default 90s.
    boot.initrd.systemd.services."systemd-udevd".serviceConfig = {
      TimeoutStartSec = "5s";
      TimeoutStopSec = "5s";
    };

    # Ensure btrfs tools are available in the initrd for the rollback service.
    boot.initrd.supportedFilesystems = ["btrfs"];

    # Wipe / on every boot by restoring @ from the @blank read-only snapshot.
    # Runs in the systemd initrd before sysroot.mount, so the root subvolume is
    # replaced before the kernel ever pivots into it. /nix (@nix), /persist
    # (@persist), and /home (@home) are separate subvolumes and are never touched.
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root to blank snapshot";
      wantedBy = ["initrd.target"];
      after = ["dev-disk-by\\x2duuid-8e1f7f22\\x2d7c3b\\x2d4950\\x2d86a1\\x2d90c4a04037c4.device"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir /mnt
        mount -t btrfs -o subvol=/ /dev/disk/by-uuid/8e1f7f22-7c3b-4950-86a1-90c4a04037c4 /mnt
        btrfs subvolume list -o /mnt/@ |
          awk '{print $NF}' |
          while read subvol; do
            btrfs subvolume delete "/mnt/$subvol"
          done
        btrfs subvolume delete /mnt/@
        btrfs subvolume snapshot /mnt/@blank /mnt/@
        umount /mnt
      '';
    };

    # High-performance network stack optimizations.
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };
}
