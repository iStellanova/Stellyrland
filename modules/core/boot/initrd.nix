_: {
  den.aspects.initrd.nixos = _: {
    boot.tmp.useTmpfs = true;
    boot.tmp.tmpfsSize = "50%";

    boot.initrd.supportedFilesystems = ["zfs"];

    # forceImportRoot: NixOS 26.11 changed the default to false. Keeping true on a
    # single-machine setup — no downside, and prevents lockout if hostid ever drifts.
    boot.zfs.forceImportRoot = true;
    # Systemd initrd is required for TPM2 auto-unlock and the rollback service.
    boot.initrd.systemd.enable = true;

    # Allow root login in the initrd emergency shell (passwordless).
    # Required because root is locked in the main system — without this,
    # any initrd failure drops to an inaccessible shell.
    boot.initrd.systemd.emergencyAccess = true;

    # Tighter udev timeout for the initrd stage (fewer devices, 5s is safe).
    # Mirrors the system-level timeout in system.nix — both prevent Kraken Z USB
    # stalls from hanging the sequence for the default 90s.
    boot.initrd.systemd.services."systemd-udevd".serviceConfig = {
      TimeoutStartSec = "30s";
      TimeoutStopSec = "30s";
    };

    # Force early loading of USB and keyboard modules in stage 1 initrd.
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

    # Wipe / and /home on every boot by rolling back to blank snapshots.
    # Runs after zroot is imported but before sysroot.mount pivots into it.
    # /nix and /persist are separate datasets and are never touched.
    # Guard conditions skip safely on first boot before blanks are seeded.
    boot.initrd.systemd.services.rollback = {
      description = "Rollback ZFS root and home to blank snapshots";
      wantedBy = ["initrd.target"];
      after = ["zfs-import-zroot.service"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        if zfs list zroot/local/root@blank > /dev/null 2>&1; then
          zfs rollback -r zroot/local/root@blank
        else
          echo "stellyrland: zroot/local/root@blank not found, skipping root rollback"
        fi

        if zfs list zroot/safe/home@blank > /dev/null 2>&1; then
          zfs rollback -r zroot/safe/home@blank
        else
          echo "stellyrland: zroot/safe/home@blank not found, skipping home rollback"
        fi
      '';
    };
  };
}
