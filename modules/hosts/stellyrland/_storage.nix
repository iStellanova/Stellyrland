{ host, ... }:
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

  systemd.tmpfiles.rules = [
    "d /ExtraDisk 0755 ${host.username} users -"
  ];

  services = {
    sanoid = {
      enable = true;
      datasets = {
        "zroot/safe/home".useTemplate = [ "default" ];
        "zroot/safe/persist".useTemplate = [ "default" ];
      };
      templates.default = {
        hourly = 0;
        daily = 7;
        weekly = 0;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
    };

    zfs.autoScrub = {
      enable = true;
      interval = "monthly";
      pools = [
        "zroot"
        "zextra"
      ];
    };

    fstrim.enable = true;
  };
}
