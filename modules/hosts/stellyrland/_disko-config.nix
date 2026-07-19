# Disko layout for stellyrland's disks (root NVMe + extra NVMe).
# enableConfig = false: only used to format at install time —
# _hardware-configuration.nix is the source of truth at runtime.
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.enableConfig = false;

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Corsair_MP700_A72YB338003QTJ";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              label = "STELLYRBOOT";
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
              size = "4G";
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
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "tpm2-device=auto"
                    "tpm2-pcrs=0+2+7"
                  ];
                };
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      extra = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Sabrent_SB-RKT4P-2TB_48820969804065";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptextra";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "tpm2-device=auto"
                    "tpm2-pcrs=0+2+7"
                  ];
                };
                content = {
                  type = "zfs";
                  pool = "zextra";
                };
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
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
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/local/root@blank$' || zfs snapshot zroot/local/root@blank";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          "safe" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/safe/home@blank$' || zfs snapshot zroot/safe/home@blank";
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
        };
      };
      zextra = {
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
          "data" = {
            type = "zfs_fs";
            mountpoint = "/ExtraDisk";
            options.mountpoint = "legacy";
            mountOptions = [
              "nofail"
              "x-gvfs-show"
              "x-gvfs-name=Extra Disk"
            ];
          };
        };
      };
    };
  };
}
