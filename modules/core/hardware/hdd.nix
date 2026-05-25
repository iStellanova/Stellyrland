_: {
  # NixOS HDD Backup configuration
  flake.modules.nixos.hdd = {pkgs, ...}: let
    hddUuid = "0592b026-666d-4a26-b416-2f3b9c7046ae";
    mapperName = "crypthdd";
    mountPoint = "/mnt/backup-hdd";
    keyFile = "/run/secrets/hdd-keyfile";

    backupScript = pkgs.writeShellScript "backup-hdd" ''
      set -euo pipefail

      echo "Starting backup to encrypted HDD..."

      if [ ! -f "${keyFile}" ]; then
        echo "Error: Keyfile ${keyFile} not found!"
        exit 1
      fi

      cleanup() {
        echo "Cleaning up..."
        ${pkgs.util-linux}/bin/umount ${mountPoint} 2>/dev/null || true
        ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName} 2>/dev/null || true
      }
      trap cleanup EXIT

      if [ ! -e "/dev/mapper/${mapperName}" ]; then
        echo "Opening encrypted device..."
        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --key-file ${keyFile} \
          /dev/disk/by-uuid/${hddUuid} \
          ${mapperName}
      else
        echo "Encrypted device already open."
      fi

      if ! mountpoint -q ${mountPoint}; then
        echo "Mounting backup HDD..."
        ${pkgs.util-linux}/bin/mount -t btrfs \
          -o noatime,compress=zstd:3,space_cache=v2 \
          /dev/mapper/${mapperName} ${mountPoint}
      else
        echo "Backup HDD already mounted."
      fi

      echo "Ensuring target directories exist..."
      mkdir -p ${mountPoint}/home ${mountPoint}/persist

      echo "Running btrbk..."
      ${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/hdd.conf run

      echo "Backup complete. Unmounting and closing..."
      ${pkgs.util-linux}/bin/umount ${mountPoint}
      ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName}
      trap - EXIT
      echo "Done."
    '';
  in {
    config = {
      environment.systemPackages = [pkgs.btrbk];

      # Prevent udisks/udiskie/file managers from showing or automounting the backup HDD.
      # This keeps the disk completely isolated for the systemd backup service.
      services.udev.extraRules = ''
        SUBSYSTEM=="block", ENV{ID_FS_UUID}=="${hddUuid}", ENV{UDISKS_IGNORE}="1"
      '';

      # btrbk config: weekly snapshots of /home and /persist sent to the HDD.
      # snapshot_preserve keeps a small local buffer; target_preserve owns long-term history.
      # Adjust target_preserve to taste — the HDD is 1.8T so space is not a concern.
      environment.etc."btrbk/hdd.conf".text = ''
        timestamp_format        long
        snapshot_preserve_min   2d
        snapshot_preserve       2w

        target_preserve_min     no
        target_preserve         8w 6m

        volume /home
          subvolume .
            snapshot_dir        .btrbk_snapshots
            target send-receive ${mountPoint}/home

        volume /persist
          subvolume .
            snapshot_dir        .btrbk_snapshots
            target send-receive ${mountPoint}/persist
      '';

      # Recreate the mount point and required local btrbk snapshot directories.
      systemd.tmpfiles.rules = [
        "d ${mountPoint} 0700 root root -"
        "d /home/.btrbk_snapshots 0700 root root -"
        "d /persist/.btrbk_snapshots 0700 root root -"
      ];

      # Unlock → mount → btrbk → unmount → lock.
      # The trap ensures the HDD is always locked even if btrbk fails.
      systemd.services.backup-hdd = {
        description = "Backup /home and /persist to encrypted HDD";
        after = ["local-fs.target"];
        unitConfig.RequiresMountsFor = ["/home" "/persist"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${backupScript}";
          # Ensure the backup doesn't starve the rest of the system
          IOWeight = 20;
          CPUWeight = 20;
        };
      };

      # Weekly backup. Persistent = true catches up if the system was offline at schedule time.
      systemd.timers.backup-hdd = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };
  };
}
