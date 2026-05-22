_: {
  config = {
    # NixOS initrd settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.core.initrd.enable = lib.mkEnableOption "Initrd configuration (LUKS, rollback, systemd initrd)";

      config = lib.mkIf config.aspects.core.initrd.enable {
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

        # Ensure required tools are available in the systemd initrd.
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
      };
    };
  };
}
