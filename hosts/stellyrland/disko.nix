{
  # enableConfig = false: disko does not manage fstab or swapDevices.
  # hardware-configuration.nix continues to own mounts.
  # This file exists as a reinstall blueprint — run with:
  #   disko --flake .#stellyrland --mode disko
  disko.enableConfig = false;

  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/nvme-Corsair_MP700_A72YB338003QTJ";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = ["-n" "STELLYRBOOT"];
              mountpoint = "/boot";
              mountOptions = ["fmask=0022" "dmask=0022"];
            };
          };
          swap = {
            size = "4G";
            content = {
              type = "swap";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L" "stellyrland-root"];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime" "discard=async" "commit=60" "space_cache=v2"];
                  };
                  "@blank" = {
                    # Empty subvolume. Rollback service in boot.nix restores @ to this on every boot.
                    mountpoint = null;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime" "discard=async" "commit=60" "space_cache=v2"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime" "discard=async" "commit=60" "space_cache=v2"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime" "discard=async" "commit=60" "space_cache=v2"];
                  };
                  "@home_snapshots" = {
                    mountpoint = "/home/.snapshots";
                    mountOptions = ["noatime" "compress=zstd" "discard=async" "commit=60" "space_cache=v2"];
                  };
                };
              };
            };
          };
        };
      };
    };
    disk.extra = {
      device = "/dev/disk/by-id/nvme-Sabrent_SB-RKT4P-2TB_48820969804065";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptextra";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L" "EXTRADISK"];
              };
            };
          };
        };
      };
    };
  };
}
