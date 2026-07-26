# Disko layout for ItsRedFlame's disk (Samsung 860 EVO 500GB SATA SSD).
# enableConfig = false: only used to format at install time —
# _hardware-configuration.nix is the source of truth at runtime.
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.enableConfig = false;

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S5B2NDFNA34655R";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            label = "REDFLAMEBOOT";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0022"
                "dmask=0022"
              ];
            };
          };
          swap = {
            priority = 2;
            size = "8G";
            content = {
              type = "swap";
            };
          };
          root = {
            priority = 3;
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
      };
      rootFsOptions = {
        compression = "zstd";
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
