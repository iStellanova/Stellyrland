{
  flake.modules.nixos.hdd =
    {
      host,
      lib,
      pkgs,
      config,
      ...
    }:
    let
      hddPartlabel = "disk-hdd-luks";
      mapperName = "crypthdd";
      poolName = "zhdd";
      # hdd-keyfile is declared in modules/system/personal-secrets.nix, not
      # here — this module requires personal-secrets to also be imported.
      keyFile = config.sops.secrets.hdd-keyfile.path;
      sourceKey = config.sops.secrets.stellacode.path;
      sshOptions = "--sshoption=StrictHostKeyChecking=yes --sshoption=UserKnownHostsFile=/etc/ssh/ssh_known_hosts";

      syncSource =
        sourceName: source:
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (
            _dirName: dir:
            let
              isRemote = source.host != null;
              sourceDataset = if isRemote then "${host.username}@${source.host}:${dir.source}" else dir.source;
              sshOptions' = lib.optionalString isRemote ''
                --sshkey ${sourceKey} \\
                ${sshOptions} \\
              '';
            in
            ''
              echo "Syncing ${sourceName}:${dir.source} → ${poolName}/${dir.target}..."
              ${pkgs.sanoid}/bin/syncoid \\
                --recursive \\
                --no-privilege-elevation \\
                --force-delete \\
                ${sshOptions'}
                ${sourceDataset} ${poolName}/${dir.target}
            ''
          ) source.dirs
        );

      syncSources = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (sourceName: source: syncSource sourceName source) host.backupHdd.sources
      );

      backupScript = pkgs.writeShellScript "backup-hdd" ''
        set -euo pipefail

        echo "Starting ZFS syncoid backup to encrypted HDD..."

        if [ ! -f "${keyFile}" ]; then
          echo "Error: Keyfile ${keyFile} not found!"
          exit 1
        fi

        mapperOpened=false
        poolImported=false
        cleanup() {
          echo "Cleaning up..."
          if $poolImported; then
            ${pkgs.zfs}/bin/zpool export ${poolName} 2>/dev/null || true
          fi
          if $mapperOpened; then
            ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName} 2>/dev/null || true
          fi
        }
        trap cleanup EXIT

        if [ ! -e "/dev/mapper/${mapperName}" ]; then
          echo "Opening encrypted HDD..."
          ${pkgs.cryptsetup}/bin/cryptsetup open \
            --key-file ${keyFile} \
            /dev/disk/by-partlabel/${hddPartlabel} \
            ${mapperName}
          mapperOpened=true
        else
          echo "Encrypted HDD already open."
        fi

        if ! ${pkgs.zfs}/bin/zpool list ${poolName} &>/dev/null; then
          echo "Importing ZFS pool ${poolName}..."
          ${pkgs.zfs}/bin/zpool import -d /dev/mapper/${mapperName} ${poolName}
          poolImported=true
        else
          echo "ZFS pool ${poolName} already imported."
        fi

        ${syncSources}

        echo "Backup complete."
        echo "Done."
      '';
    in
    {
      environment.systemPackages = [ pkgs.sanoid ]; # includes syncoid

      # Prevent udisks/udiskie/file managers from showing or automounting the backup HDD.
      services.udev.extraRules = ''
        SUBSYSTEM=="block", ENV{ID_PART_ENTRY_NAME}=="${hddPartlabel}", ENV{UDISKS_IGNORE}="1"
        SUBSYSTEM=="block", ENV{DM_NAME}=="${mapperName}", ENV{UDISKS_IGNORE}="1"
      '';

      # Unlock → import pool → syncoid. The trap cleans up resources opened by this run,
      # even if syncoid fails.
      systemd.services.backup-hdd = {
        description = "Syncoid ZFS backup of home and persist to encrypted HDD";
        after = [
          "local-fs.target"
          "zfs.target"
          "network-online.target"
        ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${backupScript}";
          IOWeight = 20;
          CPUWeight = 20;
        };
      };

      # Weekly backup. Persistent = true catches up if the system was offline at schedule time.
      systemd.timers.backup-hdd = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };

  # Source-side delegation for the homelab receiver. The deployment identity
  # can send only the safe datasets; it cannot receive or access other pools.
  flake.modules.nixos.hdd-source =
    { host, pkgs, ... }:
    {
      systemd.services.backup-hdd-zfs-delegation = {
        description = "Delegate safe ZFS replication to the homelab receiver";
        after = [ "zfs.target" ];
        wantedBy = [ "zfs.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = ''
            ${pkgs.zfs}/bin/zfs allow -d -u ${host.username} snapshot,send,destroy,hold,release zroot/safe
          '';
        };
      };
    };
}
