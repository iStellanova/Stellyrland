{ host, pkgs, ... }:
{
  fileSystems."/ExtraDisk" = {
    device = "zextra/data";
    fsType = "zfs";
    options = [
      "nofail"
      "x-gvfs-show"
      "x-gvfs-name=Extra Disk"
    ];
  };

  finit.tmpfiles.rules = [
    "d /ExtraDisk 0755 ${host.username} users -"
  ];

  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 0;
    hourly = 0;
    daily = 7;
    weekly = 0;
    monthly = 0;
  };

  finit.tasks.zfs-auto-snapshot-enable = {
    description = "enable ZFS auto-snapshots for protected datasets";
    runlevels = "S";
    command = pkgs.writeShellScript "zfs-auto-snapshot-enable" ''
      ${pkgs.zfs}/bin/zfs set com.sun:auto-snapshot=true zroot/safe/home
      ${pkgs.zfs}/bin/zfs set com.sun:auto-snapshot=true zroot/safe/persist
    '';
  };

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
    pools = [
      "zroot"
      "zextra"
    ];
  };

  services.fstrim.enable = true;
}
