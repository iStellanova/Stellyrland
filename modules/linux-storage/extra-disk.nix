{ sn, ... }: {
  sn.linux-storage = {
    includes = [ sn.extra-disk ];
  };

  sn.extra-disk.nixos = { host, ... }: {
    # Extra disk LUKS: TPM2 auto-decrypted at initrd stage 1.
    boot.initrd.luks.devices."cryptextra" = {
      device = "/dev/disk/by-partlabel/disk-extra-luks";
      allowDiscards = true;
      crypttabExtraOpts = [
        "tpm2-device=auto"
        "tpm2-pcrs=0+2+7"
      ];
    };

    # zextra pool (inside LUKS cryptextra); nofail boots cleanly if drive is missing;
    # x-gvfs options make it visible and named in file managers.
    fileSystems."/ExtraDisk" = {
      device = "zextra/data";
      fsType = "zfs";
      options = [
        "nofail"
        "x-gvfs-show"
        "x-gvfs-name=Extra Disk"
      ];
    };

    # ZFS legacy mounts land as nobody:nogroup — fix ownership so the user can write here.
    systemd.tmpfiles.rules = [
      "d /ExtraDisk 0755 ${host.username} users -"
    ];
  };
}
