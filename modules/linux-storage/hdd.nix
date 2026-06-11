{
  sn,
  ...
}: {
  sn.linux-storage = {includes = [sn.hdd];};

  sn.hdd.nixos = {pkgs, ...}: let
    hddPartlabel = "disk-hdd-luks";
    mapperName = "crypthdd";
    poolName = "zhdd";
    keyFile = "/run/secrets/hdd-keyfile";

    backupScript = pkgs.writeShellScript "backup-hdd" ''
      set -euo pipefail

      echo "Starting ZFS syncoid backup to encrypted HDD..."

      if [ ! -f "${keyFile}" ]; then
        echo "Error: Keyfile ${keyFile} not found!"
        exit 1
      fi

      cleanup() {
        echo "Cleaning up..."
        ${pkgs.zfs}/bin/zpool export ${poolName} 2>/dev/null || true
        ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName} 2>/dev/null || true
      }
      trap cleanup EXIT

      # Open LUKS container
      if [ ! -e "/dev/mapper/${mapperName}" ]; then
        echo "Opening encrypted HDD..."
        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --key-file ${keyFile} \
          /dev/disk/by-partlabel/${hddPartlabel} \
          ${mapperName}
      else
        echo "Encrypted HDD already open."
      fi

      # Import ZFS pool (pool lives on the mapper device, not a directory)
      if ! ${pkgs.zfs}/bin/zpool list ${poolName} &>/dev/null; then
        echo "Importing ZFS pool ${poolName}..."
        ${pkgs.zfs}/bin/zpool import -d /dev/mapper/${mapperName} ${poolName}
      else
        echo "ZFS pool ${poolName} already imported."
      fi

      echo "Syncing zroot/safe/home → ${poolName}/home..."
      ${pkgs.sanoid}/bin/syncoid \
        --recursive \
        --no-privilege-elevation \
        --force-delete \
        zroot/safe/home ${poolName}/home

      echo "Syncing zroot/safe/persist → ${poolName}/persist..."
      ${pkgs.sanoid}/bin/syncoid \
        --recursive \
        --no-privilege-elevation \
        --force-delete \
        zroot/safe/persist ${poolName}/persist

      echo "Backup complete. Exporting pool and closing LUKS..."
      ${pkgs.zfs}/bin/zpool export ${poolName}
      ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName}
      trap - EXIT
      echo "Done."
    '';
  in {
    environment.systemPackages = [pkgs.sanoid]; # includes syncoid

    # Prevent udisks/udiskie/file managers from showing or automounting the backup HDD.
    services.udev.extraRules = ''
      SUBSYSTEM=="block", ENV{ID_PART_ENTRY_NAME}=="${hddPartlabel}", ENV{UDISKS_IGNORE}="1"
      SUBSYSTEM=="block", ENV{DM_NAME}=="${mapperName}", ENV{UDISKS_IGNORE}="1"
    '';

    # Unlock → import pool → syncoid → export → lock.
    # The trap ensures the HDD is always cleanly exported and locked even if syncoid fails.
    systemd.services.backup-hdd = {
      description = "Syncoid ZFS backup of home and persist to encrypted HDD";
      after = ["local-fs.target" "zfs.target"];
      unitConfig.RequiresMountsFor = ["/persist"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${backupScript}";
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
}
