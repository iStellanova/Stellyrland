{inputs, ...}: {
  # NixOS Storage and Snapper configuration
  flake.modules.nixos.storage = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.disko.nixosModules.disko];

    config = {
      environment.systemPackages = with pkgs; [
        btrfs-assistant # GUI manager for Btrfs and Snapper
        btrfs-progs # Userspace utilities for the btrfs filesystem
        snapper # Tool for Linux filesystem snapshots
        ntfs3g # Open source implementation of NTFS
      ];

      services.snapper.configs = {
        home = {
          SUBVOLUME = "/home";
          ALLOW_USERS = [config.identity.username];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = "1800";
          TIMELINE_LIMIT_HOURLY = "0";
          TIMELINE_LIMIT_DAILY = "7";
          TIMELINE_LIMIT_WEEKLY = "0";
          TIMELINE_LIMIT_MONTHLY = "0";
          TIMELINE_LIMIT_YEARLY = "0";
          NUMBER_CLEANUP = true;
          NUMBER_LIMIT = "10";
        };
        persist = {
          SUBVOLUME = "/persist";
          ALLOW_USERS = [config.identity.username];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = "1800";
          TIMELINE_LIMIT_HOURLY = "0";
          TIMELINE_LIMIT_DAILY = "7";
          TIMELINE_LIMIT_WEEKLY = "0";
          TIMELINE_LIMIT_MONTHLY = "0";
          TIMELINE_LIMIT_YEARLY = "0";
          NUMBER_CLEANUP = true;
          NUMBER_LIMIT = "10";
        };
      };

      # Post-switch snapshots for both /home and /persist.
      # Runs during nixos-rebuild activation, capturing a known-good state after each successful rebuild.
      # Uses number cleanup so these are kept independently of the daily timeline (last 10 preserved).
      system.activationScripts.snapshot-after-rebuild = ''
        ${pkgs.snapper}/bin/snapper -c home create --cleanup-algorithm number --description "After rebuild" || true
        ${pkgs.snapper}/bin/snapper -c persist create --cleanup-algorithm number --description "After rebuild" || true
      '';

      # Auto-scrubbing for BTRFS filesystems.
      # Periodically checks for and repairs bitrot or data corruption.
      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = ["/" "/persist"];
      };
    };
  };
}
