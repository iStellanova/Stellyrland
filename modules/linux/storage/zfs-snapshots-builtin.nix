_: {
  # NixOS's own dataset-agnostic autoSnapshot — the simpler alternative to
  # Sanoid (see zfs-snapshots-sanoid.nix), used by hosts without impermanence
  # or a backup HDD to pair with Syncoid.
  flake.modules.nixos.zfs-snapshots-builtin = _: {
    # Automatic dataset-agnostic ZFS timeline snapshots
    services.zfs.autoSnapshot = {
      enable = true;
      frequent = 0;
      hourly = 0;
      daily = 7;
      weekly = 4;
      monthly = 1;
    };

    # Monthly background ZFS pool health scrub
    services.zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
  };
}
