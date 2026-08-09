# Install-only layout; runtime mounts are in _hardware-configuration.nix.
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.enableConfig = false;
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL4256HBJD-00BH1_S6B6NU2WB53875";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            label = "AORUSBOOT";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          swap = {
            priority = 2;
            size = "8G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            priority = 3;
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "zfs";
                pool = "zroot";
              };
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
        local = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "local/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        "local/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.mountpoint = "legacy";
        };
        safe = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "safe/home" = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = "legacy";
        };
        "safe/srv" = {
          type = "zfs_fs";
          mountpoint = "/srv";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
