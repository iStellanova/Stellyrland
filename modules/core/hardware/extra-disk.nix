_: {
  # NixOS Extra Disk Storage
  flake.modules.nixos.extra-disk = {config, ...}: {
    config = {
      # LUKS Decryption for Extra Disk (Sabrent SB-RKT4P-2TB nvme0n1)
      # Automatically decrypted at boot stage 1 using systemd-cryptsetup and the TPM2 chip.
      boot.initrd.luks.devices."cryptextra" = {
        device = "/dev/disk/by-partlabel/disk-extra-luks";
        allowDiscards = true;
        crypttabExtraOpts = ["tpm2-device=auto" "tpm2-pcrs=0+2+7"];
      };

      # Extra Storage: nvme1n1 (1.8T btrfs, "Extra Drive")
      # nofail ensures the system still boots if the drive is missing.
      # x-gvfs options make the drive easily accessible and identifiable in the file manager.
      fileSystems."${config.identity.homeDir}/ExtraDisk" = {
        device = "/dev/mapper/cryptextra";
        fsType = "btrfs";
        options = [
          "nofail"
          "x-gvfs-show"
          "x-gvfs-name=Extra Disk"
          "noatime"
          "compress=zstd:3"
          "ssd"
          "discard=async"
          "space_cache=v2"
        ];
      };
    };
  };
}
