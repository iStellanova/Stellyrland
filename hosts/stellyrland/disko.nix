{
  # enableConfig = false: disko does not manage fstab or swapDevices.
  # hardware-configuration.nix continues to own mounts.
  # This file exists as a reinstall blueprint — run with:
  #   disko --flake .#stellyrland --mode disko
  disko.enableConfig = false;

  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1";
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
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime" "discard=async" "commit=60" "space_cache=v2"];
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
}
