# Disko layout for onitop's disk (Crucial BX500 480GB SATA SSD).
# enableConfig = false: only used to format at install time —
# _hardware-configuration.nix is the source of truth at runtime.
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.enableConfig = false;

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/ata-CT480BX500SSD1_2020E3FB91FD";
      content = {
        type = "gpt";
        partitions = {
          # BIOS boot partition for GRUB's core.img — legacy BIOS + GPT needs
          # this since there's no MBR gap to embed into.
          boot = {
            size = "1M";
            type = "EF02";
          };
          swap = {
            size = "8G";
            content = {
              type = "swap";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };

    zpool.zroot = {
      type = "zpool";
      options = {
        ashift = "12";
        autotrim = "on";
        # Restricted feature set GRUB's built-in ZFS reader can actually parse.
        # Never `zpool upgrade` this pool — it'll enable features GRUB can't
        # read and the machine won't boot.
        compatibility = "grub2";
      };
      rootFsOptions = {
        # grub2 compatibility (above) excludes zstd_compress.
        compression = "lz4";
        atime = "off";
        xattr = "sa";
        acltype = "posix";
        mountpoint = "none";
      };
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.mountpoint = "legacy";
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
