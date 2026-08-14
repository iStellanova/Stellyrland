_: {
  # Sanoid + Syncoid: local snapshot policy for the one host using impermanence
  # (root/nix must never be snapshotted — they're ephemeral by design) and a
  # backup HDD (hdd.nix's weekly replication runs on the same Sanoid/Syncoid
  # toolkit, not NixOS's separate builtin autoSnapshot module).
  flake.modules.nixos.zfs-snapshots-sanoid = _: {
    # Sanoid: ZFS snapshot management for safe/ datasets.
    # Timeline snapshots for /home and /persist only —
    # local/ datasets (root, nix) are ephemeral and never snapshotted.
    services.sanoid = {
      enable = true;
      datasets = {
        "zroot/safe/home" = {
          useTemplate = [ "default" ];
        };
        "zroot/safe/persist" = {
          useTemplate = [ "default" ];
        };
      };
      templates.default = {
        hourly = 0;
        daily = 7;
        weekly = 0;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
    };

    # Monthly scrub of both pools.
    services.zfs.autoScrub = {
      enable = true;
      interval = "monthly";
      pools = [
        "zroot"
        "zextra"
      ];
    };
  };
}
