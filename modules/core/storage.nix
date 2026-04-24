{ config, lib, pkgs, ... }:

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
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "stellanova" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
    };

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
