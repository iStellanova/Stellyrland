{
  # finit service definitions for the Finix migration
  environment.etc = {
    # Core Infrastructure: System Logging
    "finit.d/syslog.conf".text = ''
      service [S12345] /run/current-system/sw/bin/syslogd -n -O /var/log/messages
    '';

    # Core Infrastructure: ACPI (Power button handling)
    "finit.d/acpid.conf".text = ''
      service [S12345] /run/current-system/sw/bin/acpid -f
    '';

    # Network: Loopback and Hostname
    "finit.d/loopback.conf".text = ''
      task [S] /run/current-system/sw/bin/ifconfig lo up
      task [S] /run/current-system/sw/bin/hostname stellyrland
    '';

    # ZRAM Setup (Low latency swap)
    "finit.d/zram.conf".text = ''
      task [S] /run/current-system/sw/bin/zramctl --find --size 16G --algorithm zstd
      task [S] /run/current-system/sw/bin/mkswap /dev/zram0
      task [S] /run/current-system/sw/bin/swapon /dev/zram0 -p 100
    '';

    # Time Sync (Simple NTP one-shot at boot)
    "finit.d/ntp.conf".text = ''
      task [2345] <networkmanager> /run/current-system/sw/bin/ntpdate -u pool.ntp.org
    '';

    # Core Infrastructure: mdevd (device manager)
    "finit.d/mdevd.conf".text = ''
      service [S12345] /run/current-system/sw/bin/mdevd -O 4
    '';

    # Nix Daemon (Required for nh and nix commands)
    "finit.d/nix-daemon.conf".text = ''
      service [12345] /run/current-system/sw/bin/nix-daemon
    '';

    # Core Infrastructure: D-Bus System Bus
    "finit.d/dbus.conf".text = ''
      task [S] /run/current-system/sw/bin/mkdir -p /run/dbus
      task [S] /run/current-system/sw/bin/mkdir -p /run/user/1000
      task [S] /run/current-system/sw/bin/mkdir -p /run/user/1000/keyring
      task [S] /run/current-system/sw/bin/chown -R 1000:100 /run/user/1000
      task [S] /run/current-system/sw/bin/chmod 700 /run/user/1000
      service [12345] /run/current-system/sw/bin/dbus-daemon --system --nofork --nopidfile
    '';

    # Polkit (Auth infrastructure)
    "finit.d/polkit.conf".text = ''
      service [12345] <dbus> /run/current-system/sw/bin/polkitd --no-debug
    '';

    # GameMode
    "finit.d/gamemode.conf".text = ''
      service [2345] /run/current-system/sw/bin/gamemoded
    '';

    # CoolerControl Daemon
    "finit.d/coolercontrol.conf".text = ''
      service [2345] <dbus> /run/current-system/sw/bin/coolercontrol-daemon
    '';

    # BTRFS Maintenance (Monthly scrub)
    "finit.d/btrfs-scrub.conf".text = ''
      task [2345] /run/current-system/sw/bin/btrfs scrub start -B / --period=2592000
    '';

    # BTRFS Snapper (Hourly snapshot and daily cleanup)
    "finit.d/snapper.conf".text = ''
      task [2345] /run/current-system/sw/bin/snapper -c home create --description "Timeline Snapshot" --period=3600
      task [2345] /run/current-system/sw/bin/snapper -c home cleanup timeline --period=86400
    '';

    # Mdev Device Properties (Replacing udev rules for ExtraDisk)
    "mdev.conf".text = ''
      sd[a-z][0-9]* root:disk 660 !/run/current-system/sw/bin/sh -c 'if [ "$ID_FS_UUID" = "5082e55b-50fd-4f53-a753-157fa30415cc" ]; then export UDISKS_AUTO=1 UDISKS_IGNORE=0; fi'
    '';

    # udisks2 (depends on dbus)
    "finit.d/udisks2.conf".text = ''
      service [2345] <dbus> /run/current-system/sw/bin/udisksd --no-debug
    '';

    # NetworkManager service (depends on dbus)
    "finit.d/networkmanager.conf".text = ''
      service [2345] <dbus> /run/current-system/sw/bin/NetworkManager --no-daemon --log-level=INFO
    '';

    # LACT daemon for GPU tuning (depends on dbus)
    "finit.d/lact.conf".text = ''
      service [2345] <dbus> /run/current-system/sw/bin/lact daemon
    '';

    # OpenRGB service (depends on dbus)
    "finit.d/openrgb.conf".text = ''
      service [2345] <dbus> /run/current-system/sw/bin/openrgb --server
    '';

    # Sched-ext (scx) - lavd scheduler
    "finit.d/scx.conf".text = ''
      service [2345] /run/current-system/sw/bin/scx_lavd
    '';

    # seatd for Wayland seat management
    "finit.d/seatd.conf".text = ''
      service [12345] /run/current-system/sw/bin/seatd -g seat
    '';

    # greetd (Session Manager) (depends on dbus)
    "finit.d/greetd.conf".text = ''
      service [2345] <dbus> /run/current-system/sw/bin/greetd
    '';

    # SSD Maintenance (fstrim periodic task)
    "finit.d/fstrim.conf".text = ''
      task [2345] /run/current-system/sw/bin/fstrim -a --period=86400
    '';
    # NH Cleanup (Periodic task)
    "finit.d/nh-clean.conf".text = ''
      task [2345] /run/current-system/sw/bin/nh clean all --keep-since 7d --keep 5 --period=604800
    '';
  };
}
