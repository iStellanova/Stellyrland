{ config, lib, pkgs, identity, ... }:

{
  options.aspects.core.storage.enable = lib.mkEnableOption "Storage utilities (Btrfs, Snapper)";

  config = lib.mkIf config.aspects.core.storage.enable {
    environment.systemPackages = with pkgs; [
      btrfs-assistant          # GUI manager for Btrfs and Snapper
      btrfs-progs              # Userspace utilities for the btrfs filesystem
      snapper                  # Tool for Linux filesystem snapshots
      ntfs3g                   # Open source implementation of NTFS
    ];

    services.snapper.configs = {
      # Snapper configuration for the home subvolume. Aims and creates BTRFS snapshots.
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ identity.name ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
    };

    # Auto-scrubbing for BTRFS filesystems.
    # Periodically checks for and repairs bitrot or data corruption.
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
