_: {
  config = {
    # NixOS HDD Backup configuration
    flake.modules.nixos.hdd = {
      config,
      lib,
      pkgs,
      ...
    }: let
      hddUuid = "0592b026-666d-4a26-b416-2f3b9c7046ae";
      mapperName = "crypthdd";
      mountPoint = "/mnt/backup-hdd";
      keyFile = "/run/secrets/hdd-keyfile";

      backupScript = pkgs.writeShellScript "backup-hdd" ''
        set -euo pipefail

        cleanup() {
          ${pkgs.util-linux}/bin/umount ${mountPoint} 2>/dev/null || true
          ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName} 2>/dev/null || true
        }
        trap cleanup EXIT

        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --key-file ${keyFile} \
          /dev/disk/by-uuid/${hddUuid} \
          ${mapperName}

        ${pkgs.util-linux}/bin/mount -t btrfs \
          -o noatime,compress=zstd:3,space_cache=v2 \
          /dev/mapper/${mapperName} ${mountPoint}

        mkdir -p ${mountPoint}/home ${mountPoint}/persist

        ${pkgs.btrbk}/bin/btrbk -c /etc/btrbk/hdd.conf run

        ${pkgs.util-linux}/bin/umount ${mountPoint}
        ${pkgs.cryptsetup}/bin/cryptsetup close ${mapperName}
        trap - EXIT
      '';
    in {
      options.aspects.core.hdd.enable = lib.mkEnableOption "HDD backup (LUKS + btrfs + btrbk)";

      config = lib.mkIf config.aspects.core.hdd.enable {
        environment.systemPackages = [pkgs.btrbk];

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
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${backupScript}";
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
  };
}
