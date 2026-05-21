{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aspects.core.boot = {
    enable = lib.mkEnableOption "Core boot settings";
    secureBoot = lib.mkEnableOption "Lanzaboote Secure Boot (disable for initial install)";
  };

  config = lib.mkIf config.aspects.core.boot.enable {
    environment.systemPackages = [pkgs.efibootmgr pkgs.sbctl];

    # systemd-boot is managed by lanzaboote, which wraps it to produce
    # signed Unified Kernel Images on every nixos-rebuild. The stock
    # systemd-boot module must be force-disabled to avoid conflicts.
    # lanzaboote is disabled for initial install — its Rust stub must be built
    # from source when not cached, which fails in the live USB environment.
    # After first boot, run nixos-rebuild with secureBoot = true to switch.
    boot.loader.systemd-boot = {
      enable = lib.mkForce (!config.aspects.core.boot.secureBoot);
      configurationLimit = 15;
      consoleMode = "max";
    };
    boot.loader.efi.canTouchEfiVariables = true;

    boot.lanzaboote = {
      enable = config.aspects.core.boot.secureBoot;
      pkiBundle = "/var/lib/sbctl";
    };

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
      "usbcore.autosuspend=-1" # Disable early USB power saving
      "rootdelay=10" # Give AM5 USB controllers extra time to fully initialize
    ];

    # Cache mode for AMD X3D V-Cache.
    systemd.tmpfiles.rules = [
      "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
    ];

    # AMDGPU initrd allows the kernel to load AMDGPU drivers early in the boot process.
    hardware.amdgpu.initrd.enable = false;

    # Tighter udev timeout for the initrd stage (fewer devices, 5s is safe).
    # Mirrors the system-level timeout in system.nix — both prevent Kraken Z USB
    # stalls from hanging the sequence for the default 90s.
    boot.initrd.systemd.services."systemd-udevd".serviceConfig = {
      TimeoutStartSec = "30s";
      TimeoutStopSec = "30s";
    };

    boot.tmp.useTmpfs = true;
    boot.tmp.tmpfsSize = "50%";

    # Ensure btrfs tools are available in the initrd for the rollback service.
    boot.initrd.supportedFilesystems = ["btrfs"];

    # Systemd initrd is required for TPM2 auto-unlock and the rollback service.
    boot.initrd.systemd.enable = true;

    # Allow root login in the initrd emergency shell (passwordless).
    # Required because root is locked in the main system — without this,
    # any initrd failure drops to an inaccessible shell.
    boot.initrd.systemd.emergencyAccess = true;

    # Force early loading of USB and keyboard modules in stage 1 initrd
    boot.initrd.kernelModules = [
      "xhci_pci" # USB 3.x controller driver
      "usbhid" # USB Human Interface Device driver
      "hid_generic" # Generic HID input driver
      "hid_apple" # Required for Keychron keyboards in Mac mode
      "evdev" # Generic input event interface for systemd-initrd
      # Crypto must be force-loaded before dm_crypt so the "crypt" target
      # can resolve xts(aes) at registration time. Order here is intentional.
      "aesni_intel" # hardware AES (AMD Zen 5 + Intel AES-NI)
      "xts" # XTS block cipher mode for the LUKS container
      "cryptd" # async crypto daemon required by aesni_intel
      "dm_crypt" # LUKS device-mapper target
    ];

    # Open the LUKS container early in initrd before any filesystem mounts.
    # allowDiscards passes TRIM commands through to the NVMe for longevity.
    # TPM2 auto-unlock is enrolled post-install via systemd-cryptenroll.
    boot.initrd.luks.devices."cryptroot" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      allowDiscards = true;
      crypttabExtraOpts = ["tpm2-device=auto" "tpm2-pcrs=0+2+7"];
    };

    # Ensure required tools are available in the systemd initrd.
    # extraBin symlinks the binaries into /bin in the initrd image.
    boot.initrd.systemd.extraBin = {
      awk = "${pkgs.gawk}/bin/awk";
      btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
    };

    # Wipe / on every boot by restoring @ from the @blank read-only snapshot.
    # Runs in the systemd initrd before sysroot.mount, so the root subvolume is
    # replaced before the kernel ever pivots into it. /nix (@nix), /persist
    # (@persist), and /home (@home) are separate subvolumes and are never touched.
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root to blank snapshot";
      wantedBy = ["initrd.target"];
      after = ["systemd-cryptsetup@cryptroot.service"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt
        mount -t btrfs -o subvol=/ /dev/mapper/cryptroot /mnt

        # Guard: only wipe @ if @blank exists. Skips safely on first boot
        # before @blank has been seeded, preventing @ from being destroyed
        # with no snapshot to restore from.
        if btrfs subvolume show /mnt/@blank > /dev/null 2>&1; then
          btrfs subvolume list -o /mnt/@ |
            awk '{print $NF}' |
            while read subvol; do
              btrfs subvolume delete "/mnt/$subvol"
            done
          btrfs subvolume delete /mnt/@
          btrfs subvolume snapshot /mnt/@blank /mnt/@
        else
          echo "stellyrland: @blank not found, skipping rollback"
        fi

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
