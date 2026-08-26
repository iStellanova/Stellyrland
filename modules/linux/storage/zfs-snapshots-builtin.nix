{
  # NixOS's dataset-agnostic autoSnapshot for hosts without a host-specific
  # Sanoid policy.
  flake.modules.nixos.zfs-snapshots-builtin = {
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

  flake.modules.finix.zfs-snapshots-builtin = { modules, ... }: {
    imports = [ modules.zfs ];

    services.zfs.autoSnapshot = {
      enable = true;
      frequent = 0;
      hourly = 0;
      daily = 7;
      weekly = 4;
      monthly = 1;
    };
    services.zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
  };
}
