# ZFS Migration

Full migration of stellyrland from Btrfs to ZFS. Work in progress.

---

## System

- **CPU:** Ryzen 9 9950X3D
- **GPU:** Radeon 7900 XTX
- **Kernel:** CachyOS BORE LTO (`pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto`), custom-built from `xddxdd/nix-cachyos-kernel`
- **RAM:** 64GB+

### Drives

| Device | Size | Role | Filesystem |
|--------|------|------|------------|
| `nvme2n1` (Corsair MP700) | 1.8T | System root | Btrfs → **ZFS** (`zroot`) |
| `nvme0n1` (Sabrent SB-RKT4P-2TB) | 1.8T | Extra storage | Btrfs → **ZFS** (`zextra`) — post-migration |
| `nvme1n1` | 465G | Unused | ext4 — leave alone |
| `sda` | 1.8T | Backup HDD | Btrfs — unchanged for now |

LUKS containers referenced by **partlabel** (`disk-main-root`, `disk-extra-luks`) — stable across reformats. Boot partition by **label** (`STELLYRBOOT`). HDD by **UUID** (not being reformatted).

---

## ZFS Architecture

### Pool: `zroot` (main root drive, inside LUKS `cryptroot`)

| Dataset | Mount | Purpose |
|---------|-------|---------|
| `zroot/local/root` | `/` | Rolled back to `@blank` on every boot |
| `zroot/local/nix` | `/nix` | Nix store — not backed up, rebuilds cleanly |
| `zroot/safe/home` | `/home` | Rolled back to `@blank` on every boot |
| `zroot/safe/persist` | `/persist` | Persists across reboots, backed up by syncoid |

`local/` = expendable, not backed up. `safe/` = backed up by syncoid (post-migration).

### Pool: `zextra` (extra disk, inside LUKS `cryptextra`)

| Dataset | Mount | Purpose |
|---------|-------|---------|
| `zextra/data` | `/ExtraDisk` | General extra storage |

`zextra` is configured after the main migration (see Migration Process below).

### Key Values

- `networking.hostId = "63d11f1d"` — fixed, generated once
- `boot.zfs.package = config.boot.kernelPackages.zfs_cachyos` — CachyOS ZFS build
- Compression, atime, autotrim, acltype, xattr set as **dataset/pool properties in disko** (not NixOS module options)
- OpenZFS 2.4.2 — confirmed support for Linux 7.x

### Impermanence

Root and home are wiped on every boot via `zfs rollback -r <dataset>@blank`. The rollback service in `initrd.nix` runs after `zfs-import-zroot.service` and before `sysroot.mount`. Guards skip safely on first boot if `@blank` doesn't exist yet. The `@blank` snapshots are seeded by the stellyrsetup installer immediately after disko formats the drives.

---

## Migration Process

The system migration is staged to avoid data loss:

1. **Pre-install:** Run `backup-hdd` service to snapshot `/home` and `/persist` to the encrypted HDD via btrbk. This is the last Btrfs backup.
2. **Reinstall:** Boot NixOS live USB, run `stellyrsetup` bootstrapper. Wipe and reformat `nvme2n1` only — ExtraDisk (`nvme0n1`) stays Btrfs and mounted.
3. **First boot:** New ZFS root is live. ExtraDisk is still Btrfs at `/ExtraDisk`, accessible for file restoration.
4. **Restore:** Copy needed files from `/ExtraDisk` back to the new ZFS system.
5. **Reformat ExtraDisk:** Files are safe on ZFS root. Reformat `nvme0n1` to ZFS (`zextra`), update `extra-disk.nix`, `nixos-rebuild switch`.
6. **HDD module:** Write a new `hdd.nix` using syncoid instead of btrbk, re-add `"hdd"` to host aspects.

---

## What Has Been Done

### Phase 1 — Hardware Configuration

**`modules/hosts/stellyrland/_hardware-configuration.nix`**
- All Btrfs `fileSystems` entries replaced with ZFS dataset mounts
- `/home/.snapshots` and `/persist/.snapshots` removed (ZFS snapshots are in-pool)
- `networking.hostId = "63d11f1d"` added
- `/boot` (vfat by label) and `swapDevices` (by partlabel, random encryption) unchanged

**`modules/core/boot/initrd.nix`**
- `boot.initrd.supportedFilesystems` changed from `["btrfs"]` to `["zfs"]`
- Rollback service rewritten: `zfs rollback -r zroot/local/root@blank` and `zroot/safe/home@blank`
- Service now ordered `after = ["zfs-import-zroot.service"]` instead of cryptsetup
- `extraBin` now exposes `zfs` from `config.boot.zfs.package` (matched to kernel module version)
- `btrfs`, `awk` removed from `extraBin`

**`modules/core/boot/kernel.nix`**
- `"btrfs"` removed from `boot.initrd.availableKernelModules`
- `FS_BTRFS = yes` retained in `structuredExtraConfig` (needed for ExtraDisk and HDD)

**`modules/core/hardware/hardware.nix`**
- `boot.zfs.package = config.boot.kernelPackages.zfs_cachyos` added

### Phase 2 — Storage Module

**`modules/core/hardware/storage.nix`**
- `snapper`, `btrfs-assistant` removed; `btrfs-progs` retained for ExtraDisk transition
- `services.snapper.configs` replaced with `services.sanoid` (same daily-7 retention)
- Sanoid manages `zroot/safe/home` and `zroot/safe/persist` only
- Activation script now runs `zfs snapshot` with shared timestamp instead of snapper
- `services.btrfs.autoScrub` replaced with `services.zfs.autoScrub` on `["zroot"]`

**`modules/hosts/stellyrland.nix`**
- `"hdd"` removed from host aspects — btrbk would fail on a ZFS root

---

## What Is Pending

### stellyrsetup (`~/Projects/stellyrsetup`)

`setup/default.nix` needs a full rewrite from Btrfs to ZFS. Must produce exactly:
- `zroot` pool inside LUKS `cryptroot` on `disk-main` (Corsair MP700 by-id)
- Four datasets: `local/root`, `local/nix`, `safe/home`, `safe/persist` with legacy mountpoints
- Pool properties: `ashift=12`, `autotrim=on`
- Dataset properties: `compression=zstd`, `atime=off`, `acltype=posixacl`, `xattr=sa`, `dnodesize=auto`
- `zextra` pool inside LUKS `cryptextra` on `disk-extra` (Sabrent by-id) with `zextra/data`
- `stellyr-install` script must seed `zroot/local/root@blank` and `zroot/safe/home@blank` after disko and before `nixos-install`
- Fix existing bug: lanzaboote bypass `sed` targets wrong path (`hosts/stellyrland/default.nix` does not exist)

### ExtraDisk (`extra-disk.nix`)

After ExtraDisk is reformatted:
- Change `fsType` from `btrfs` to `zfs`, device to `zextra/data`
- Remove Btrfs mount options; ZFS properties set at pool/dataset level
- Add `zextra` to `services.zfs.autoScrub.pools`
- Remove `btrfs-progs` from `storage.nix` packages

### HDD Backup Module (`hdd.nix`)

After ExtraDisk migration:
- Rewrite using `syncoid` instead of btrbk
- Target: `zroot/safe/home` and `zroot/safe/persist` → ZFS receive on HDD
- Re-add `"hdd"` to host aspects in `stellyrland.nix`
- Decision pending: reformat HDD to ZFS, or keep Btrfs with rsync fallback
