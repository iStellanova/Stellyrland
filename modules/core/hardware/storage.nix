{nixosIdentity, ...}: {
  config = {
    # NixOS Storage and Snapper configuration
    flake.modules.nixos.storage = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.core.storage.enable = lib.mkEnableOption "Storage utilities (Btrfs, Snapper)";

      config = lib.mkIf config.aspects.core.storage.enable {
        environment.systemPackages = with pkgs; [
          btrfs-assistant # GUI manager for Btrfs and Snapper
          btrfs-progs # Userspace utilities for the btrfs filesystem
          snapper # Tool for Linux filesystem snapshots
          ntfs3g # Open source implementation of NTFS
        ];

        services.snapper.configs = {
          home = {
            SUBVOLUME = "/home";
            ALLOW_USERS = [nixosIdentity.name];
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
            TIMELINE_MIN_AGE = "1800";
            TIMELINE_LIMIT_HOURLY = "5";
            TIMELINE_LIMIT_DAILY = "7";
            TIMELINE_LIMIT_WEEKLY = "2";
            TIMELINE_LIMIT_MONTHLY = "1";
            TIMELINE_LIMIT_YEARLY = "0";
          };
        };

        # Auto-scrubbing for BTRFS filesystems.
        # Periodically checks for and repairs bitrot or data corruption.
        services.btrfs.autoScrub = {
          enable = true;
          interval = "monthly";
          fileSystems = ["/"] ++ lib.optional config.aspects.core.extra-disk.enable "/home/${nixosIdentity.name}/ExtraDisk";
        };
      };
    };
  };
}
