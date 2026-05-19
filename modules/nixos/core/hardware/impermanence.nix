{
  config,
  lib,
  ...
}: {
  # ============================================================================
  # IMPERMANENCE — SCAFFOLDED, NOT YET ENABLED
  # ============================================================================
  #
  # Impermanence wipes the system root (/) on every boot. Only paths explicitly
  # declared below survive. /home lives on a separate @home Btrfs subvolume and
  # is completely unaffected — game saves, dotfiles, and shell history persist
  # as normal.
  #
  # The net effect: the system always boots into exactly the state declared in
  # this config. No mystery files in /var, no service state drift, no cruft.
  #
  # ── PREREQUISITES — complete all four steps before flipping the enable ────
  #
  # STEP 1: Add @blank and @persist subvolumes (hosts/stellyrland/disko.nix)
  # ─────────────────────────────────────────────────────────────────────────
  # Inside the btrfs `subvolumes` block (alongside @home), add:
  #
  #   "@persist" = {
  #     mountpoint = "/persist";
  #     mountOptions = ["compress=zstd" "noatime" "discard=async" "commit=60" "space_cache=v2"];
  #   };
  #
  # Then manually create the blank snapshot (do this once on a live system
  # before enabling impermanence):
  #
  #   sudo mkdir /btrfs_root
  #   sudo mount -o subvol=/ /dev/nvme2n1p3 /btrfs_root
  #   sudo btrfs subvolume snapshot -r /btrfs_root/@ /btrfs_root/@blank
  #   sudo umount /btrfs_root
  #
  # @blank is a read-only reference point. The boot wipe script (Step 2) rolls
  # @ back to this snapshot before / is mounted on every boot.
  #
  #
  # STEP 2: Add the boot wipe script
  # ─────────────────────────────────
  # IMPORTANT: Check whether boot.initrd.systemd.enable is true in your config.
  # Your boot.nix configures initrd systemd services (systemd-udevd), which means
  # systemd initrd is likely active. In that case, postDeviceCommands is NOT
  # available — you need a systemd initrd service instead.
  #
  # For classic initrd (postDeviceCommands), add to boot.nix or here:
  #
  #   boot.initrd.postDeviceCommands = lib.mkAfter ''
  #     mkdir -p /btrfs_root
  #     mount -o subvol=/ /dev/disk/by-uuid/<ROOT_PARTITION_UUID> /btrfs_root
  #     if [[ -e /btrfs_root/@ ]]; then
  #       btrfs subvolume list -o /btrfs_root/@ | \
  #         cut -f9 -d' ' | \
  #         while read subvolume; do
  #           btrfs subvolume delete /btrfs_root/$subvolume
  #         done
  #       btrfs subvolume delete /btrfs_root/@
  #     fi
  #     btrfs subvolume snapshot /btrfs_root/@blank /btrfs_root/@
  #     umount /btrfs_root
  #   '';
  #
  # For systemd initrd, see:
  # https://github.com/nix-community/impermanence?tab=readme-ov-file#btrfs-subvolumes
  #
  # Get <ROOT_PARTITION_UUID>: sudo blkid /dev/nvme2n1p3
  # (Verify partition — disko.nix declares nvme2n1 with ESP+swap+root order,
  # making the Btrfs partition nvme2n1p3, but confirm with lsblk.)
  #
  #
  # STEP 3: Add /persist to hardware-configuration.nix
  # ────────────────────────────────────────────────────
  # disko.enableConfig = false, so hardware-configuration.nix owns fstab.
  # Add a fileSystems entry for /persist using the subvolume's UUID.
  # Use @home's entry as a template, changing subvol=@home to subvol=@persist.
  #
  #
  # STEP 4: Enable the aspect in hosts/stellyrland/default.nix
  # ───────────────────────────────────────────────────────────
  #   aspects.core.impermanence.enable = true;
  #
  #
  # ── WHAT DOES NOT NEED PERSISTING (nix-managed, regenerated on activation) ─
  #
  #   /var/lib/lact          fully declared in modules/nixos/services/lact.nix
  #   /var/lib/coolercontrol fully declared in modules/nixos/services/coolercontrol.nix
  #   /var/lib/openrgb       fully declared in modules/nixos/services/openrgb.nix
  #   /etc                   mostly symlinks into /nix/store
  #
  #
  # ── WHAT NEEDS PERSISTING ──────────────────────────────────────────────────
  #
  #   /var/lib/postgresql    AI stack database content (facts, rules, traits, messages)
  #   /var/lib/ollama        Downloaded models — can be 10s of GB, do NOT forget this
  #   /var/lib/open-webui    Chat history, OpenWebUI settings and sessions
  #   /var/lib/bluetooth     Paired device state (headset, controllers, etc.)
  #   /var/lib/NetworkManager Saved network connections and credentials
  #   /var/log               Optional — useful for post-reboot debugging
  #   /etc/machine-id        Stable machine identity (affects journald, D-Bus, systemd)
  #   /etc/ssh/ssh_host_*    SSH host keys — losing these breaks known_hosts on all clients
  #
  # NOTE: If Echo Bridge accumulates state outside of PostgreSQL (e.g. a cache dir,
  # model embeddings, or config written at runtime), check its data dir and add it here.
  #
  #
  # ── REFERENCE ──────────────────────────────────────────────────────────────
  # Erase Your Darlings (canonical blog post for this approach):
  #   https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html
  # Impermanence README:
  #   https://github.com/nix-community/impermanence
  # ============================================================================

  options.aspects.core.impermanence.enable = lib.mkEnableOption "Opt-in persistence (wipes / on each boot, keeps only declared paths)";

  config = lib.mkIf config.aspects.core.impermanence.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/postgresql"
        "/var/lib/ollama"
        "/var/lib/open-webui"
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/log"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
