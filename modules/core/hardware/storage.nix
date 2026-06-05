_: {
  # NixOS Storage and Sanoid configuration
  flake.modules.nixos.storage = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        btrfs-progs # Btrfs tools retained for ExtraDisk during ZFS migration
        ntfs3g # Open source NTFS driver
      ];

      # Sanoid: ZFS snapshot management for safe/ datasets.
      # Replaces snapper. Timeline snapshots for /home and /persist only —
      # local/ datasets (root, nix) are ephemeral and never snapshotted.
      services.sanoid = {
        enable = true;
        datasets = {
          "zroot/safe/home" = {
            useTemplate = ["default"];
          };
          "zroot/safe/persist" = {
            useTemplate = ["default"];
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

      # Post-rebuild snapshots for home and persist.
      # Runs during nixos-rebuild activation after each successful rebuild.
      # Timestamp captured once so home and persist share the same snapshot name.
      # These are outside sanoid's naming convention and will not be auto-pruned.
      system.activationScripts.snapshot-after-rebuild = ''
        ts=$(${pkgs.coreutils}/bin/date +%s)
        ${pkgs.zfs}/bin/zfs snapshot "zroot/safe/home@rebuild-$ts" 2>/dev/null || true
        ${pkgs.zfs}/bin/zfs snapshot "zroot/safe/persist@rebuild-$ts" 2>/dev/null || true
      '';

      # Monthly scrub of the root pool. Replaces services.btrfs.autoScrub.
      services.zfs.autoScrub = {
        enable = true;
        interval = "monthly";
        pools = ["zroot"];
      };
    };
  };
}
