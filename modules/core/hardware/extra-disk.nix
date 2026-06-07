_: {
  den.aspects.extra-disk.nixos = {host, ...}: {
    # LUKS Decryption for Extra Disk (Sabrent SB-RKT4P-2TB nvme2n1)
    # Automatically decrypted at boot stage 1 using systemd-cryptsetup and the TPM2 chip.
    boot.initrd.luks.devices."cryptextra" = {
      device = "/dev/disk/by-partlabel/disk-extra-luks";
      allowDiscards = true;
      crypttabExtraOpts = ["tpm2-device=auto" "tpm2-pcrs=0+2+7"];
    };

    # Extra Storage: Sabrent SB-RKT4P-2TB (zextra pool, inside LUKS cryptextra)
    # Mountpoint property is legacy; filesystem entry owns the actual mount.
    # nofail ensures the system still boots if the drive is missing.
    # x-gvfs options make the drive identifiable in the file manager.
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
