# ZFS Migration

Full migration of stellyrland from Btrfs to ZFS. **Phases 1–3 complete — system boots on ZFS with impermanence.**

---

## System

- **CPU:** Ryzen 9 9950X3D
- **GPU:** Radeon 7900 XTX
- **Kernel:** CachyOS BORE LTO (`pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto`), custom-built from `xddxdd/nix-cachyos-kernel`
- **RAM:** 64GB+

### Drives

| Device | Size | Role | Current Filesystem |
|--------|------|------|--------------------|
| `nvme2n1` (Corsair MP700, by-id: `nvme-Corsair_MP700_A72YB338003QTJ`) | 1.8T | System root | **ZFS** (`zroot`) ✓ |
| `nvme1n1` (Sabrent SB-RKT4P-2TB) | 1.8T | Extra storage | Btrfs at `/ExtraDisk` — pending `zextra` reformat |
| `nvme0n1` | 465G | Unused | ext4 — leave alone |
| `sda` | 1.8T | Backup HDD | Btrfs — unchanged for now |

LUKS containers referenced by **partlabel** (`disk-main-root`, `disk-extra-luks`) — stable across reformats. Boot partition by **label** (`STELLYRBOOT`). HDD by **UUID** (not being reformatted). NVMe kernel names (`nvme*n1`) can shift on reboot; partlabels and by-id paths are authoritative.

---

## ZFS Architecture

### Pool: `zroot` (main root drive, inside LUKS2 `cryptroot`)

| Dataset | Mount | Mountpoint property | Purpose |
|---------|-------|---------------------|---------|
| `zroot/local` | — | `none` | Organizational parent |
| `zroot/local/root` | `/` | `legacy` | Rolled back to `@blank` on every boot |
| `zroot/local/nix` | `/nix` | `legacy` | Nix store — not backed up, rebuilds cleanly |
| `zroot/safe` | — | `none` | Organizational parent |
| `zroot/safe/home` | `/home` | `legacy` | Rolled back to `@blank` on every boot |
| `zroot/safe/persist` | `/persist` | `legacy` | Persists across reboots, backed up by syncoid |

`local/` = expendable, not backed up. `safe/` = backed up by syncoid (post-migration).

### Pool: `zextra` (extra disk, inside LUKS `cryptextra`) — pending

| Dataset | Mount | Purpose |
|---------|-------|---------|
| `zextra/data` | `/ExtraDisk` | General extra storage |

`zextra` is configured after the main migration (see Migration Process below).

### Key Values

- `networking.hostId = "63d11f1d"` — fixed, generated once
- `boot.zfs.package = config.boot.kernelPackages.zfs_cachyos` — CachyOS ZFS build
- `boot.zfs.forceImportRoot = true` — **critical**: NixOS 26.11 changed this default to `false`. Without it, the pool fails to import on every boot because the hostid cached in the pool (written by the install environment) differs from the running system's hostid. Keep `true` until TPM2 is enrolled and the system is stable.
- Pool properties: `ashift=12`, `autotrim=on`
- Dataset properties: `compression=zstd`, `atime=off`, `acltype=posixacl`, `xattr=sa`, `dnodesize=auto`
- All pool/dataset properties set **in disko** (not NixOS module options)
- OpenZFS 2.4.2 (CachyOS kernel) — confirmed support for Linux 7.x

### Impermanence

Root and home are wiped on every boot via `zfs rollback -r <dataset>@blank`. The rollback service in `initrd.nix` runs after `zfs-import-zroot.service` and before `sysroot.mount`. Guards skip safely on first boot if `@blank` doesn't exist yet. The `@blank` snapshots are seeded by the stellyrsetp installer immediately after disko formats the drives.

The `home-manager-stellanova.service` (enabled, `WantedBy=multi-user.target`) runs at every boot before any user session and recreates all dotfile symlinks. `.local/state/nix` and `.local/state/home-manager` are persisted so the service's profile lookup and gcroots survive the rollback.

---

## Migration Process

1. **Pre-install ✓** — Final btrbk snapshot of `/home` and `/persist` to encrypted HDD.
2. **Reinstall ✓** — NixOS live USB, `stellyrsetp` bootstrapper. Reformatted `nvme2n1` only; ExtraDisk left as Btrfs.
3. **First boot ✓** — ZFS root live. ExtraDisk accessible at `/ExtraDisk` for file restoration.
4. **Restore** — Copy needed files from `/ExtraDisk` back to the ZFS system. *In progress.*
5. **Reformat ExtraDisk** — Reformat Sabrent to ZFS (`zextra`), update `extra-disk.nix`, rebuild.
6. **HDD module** — Write `hdd.nix` using syncoid, re-add `"hdd"` to host aspects.

---

## What Has Been Done

### Stellyrland Flake

**`modules/hosts/stellyrland/_hardware-configuration.nix`**
- All Btrfs `fileSystems` entries replaced with ZFS dataset mounts
- `/home/.snapshots` and `/persist/.snapshots` removed (ZFS snapshots are in-pool)
- `networking.hostId = "63d11f1d"` added
- `/boot` (vfat by label) and `swapDevices` (by partlabel, random encryption) unchanged

**`modules/core/boot/initrd.nix`**
- `boot.initrd.supportedFilesystems` changed from `["btrfs"]` to `["zfs"]`
- `boot.zfs.forceImportRoot = true` added — prevents pool import failure due to hostid mismatch on every boot
- Rollback service rewritten: `zfs rollback -r zroot/local/root@blank` and `zroot/safe/home@blank`
- Service ordered `after = ["zfs-import-zroot.service"]`, `before = ["sysroot.mount"]`
- `extraBin.zfs` removed — it conflicted with NixOS's own `zfs.nix` module which already injects `/sbin/zfs` into the initrd. The error was: *"The option `boot.initrd.systemd.extraBin.zfs` has conflicting definition values: `.../initrd.nix: /bin/zfs` vs `.../zfs.nix: /sbin/zfs`"*
- `config` parameter removed from module args (was only used for the removed `extraBin` line)

**`modules/core/boot/kernel.nix`**
- `"btrfs"` removed from `boot.initrd.availableKernelModules`
- `FS_BTRFS = yes` retained in `structuredExtraConfig` (needed for ExtraDisk and HDD)

**`modules/core/hardware/hardware.nix`**
- `boot.zfs.package = config.boot.kernelPackages.zfs_cachyos` added

**`modules/core/hardware/storage.nix`**
- `snapper`, `btrfs-assistant` removed; `btrfs-progs` retained for ExtraDisk transition
- `services.snapper.configs` replaced with `services.sanoid` (same daily-7 retention)
- Sanoid manages `zroot/safe/home` and `zroot/safe/persist` only
- Activation script now runs `zfs snapshot` with shared timestamp instead of snapper
- `services.btrfs.autoScrub` replaced with `services.zfs.autoScrub` on `["zroot"]`

**`modules/hosts/stellyrland.nix`**
- `"hdd"` removed from host aspects — btrbk would fail on a ZFS root
- `core.boot.secureBoot = false` — disabled ahead of reinstall; re-enable after Secure Boot key enrollment

### stellyrsetp (`github:iStellanova/stellyrsetp`)

**`flake.nix`**
- Added `nixosConfigurations.stellyrland-install` pointing to `setup/default-install.nix` — install-time disko config with only `disk.main` and `zpool.zroot`, no ExtraDisk

**`setup/default-install.nix`** (new file)
- Main-only disko config — identical to `default.nix` but with `disk.extra` and `zpool.zextra` blocks removed
- Prevents disko from touching the Sabrent during initial install

**`setup/setup-scripts.nix` Phase 3**
- disko call changed from `.#stellyrland` to `"path:$(pwd)#stellyrland-install"` — `path:` prefix forces Nix to use the on-disk flake rather than the cached store copy
- All runtime sed/python masking logic removed (was fragile and broken)
- `@blank` snapshots for `zroot/local/root` and `zroot/safe/home` seeded immediately after disko, before `nixos-install`
- Fixed lanzaboote bypass `sed` target (was pointing to `hosts/stellyrland/default.nix` which doesn't exist)

---

## Install Notes

Key discoveries made during the actual install:

- **ZFS version mismatch**: The NixOS live ISO (June 2026) ships ZFS 2.3.6; the installed system uses OpenZFS 2.4.2 via the CachyOS kernel. The live ISO cannot import a 2.4.x pool even with `nix-shell -p zfs_2_4` — what matters is the **kernel module** version, not the userspace tools. `zpool import -F` (recovery mode) has the same restriction.
- **`forceImportRoot`**: NixOS 26.11 changed the default to `false`. Without `boot.zfs.forceImportRoot = true`, the pool fails to import on every boot because the hostid cached in the pool differs from the running system's hostid.
- **machine-id**: `systemd-machine-id-setup --root=/mnt` must be run before `nixos-install` if `/mnt/etc/machine-id` is empty — otherwise systemd-boot's Python installer crashes with `IndexError: list index out of range`.
- **lanzaboote / Secure Boot**: `nixos-rebuild switch` fails with lanzaboote if sbctl keys aren't enrolled. This failure happens before `switch-to-configuration` runs, so home-manager never activates either. Workaround: set `secureBoot = false` before the first rebuild on the new system.
- **stellyrsetp cleanup trap**: The installer's cleanup trap reverts `secureBoot = false` after install — must re-apply manually before running `nixos-rebuild switch` on the booted system.
- **Flash drive permissions**: Files on root-owned FAT/exFAT flash drives (e.g. SSH/sops keys from backup) require `sudo cp` + `sudo chown nixos` + `chmod 600` before use.
- **Git on FAT/exFAT**: Triggers libgit2 ownership errors — fix with `git config --global --add safe.directory <path>`.

---

## Current State (2026-06-05)

- System boots cleanly into Hyprland on ZFS
- Impermanence working: `/` and `/home` roll back to `@blank` on every boot
- `/persist` survives reboots (SSH host key, sops-nix secrets, etc.)
- sops-nix decrypts secrets correctly using restored SSH host key
- ExtraDisk accessible at `/ExtraDisk` (Btrfs) for file restoration
- Home-manager persistence fixed and confirmed — `.local/state/nix`, `.local/state/home-manager` persisted; home dir ownership corrected via tmpfiles; service activates at boot and recreates dotfile symlinks without manual intervention
- `.claude.json` persisted — Claude Code auth survives rollback

---

## What Is Pending

1. **Fix home-manager persistence** ✓ — `modules/core/hardware/preservation.nix` — **confirmed working 2026-06-05**
   - Added `.local/state/nix` and `.local/state/home-manager` to user persistence directories
   - Added tmpfiles rules to guarantee `profiles/` and `gcroots/` subdirectories always exist in `/persist` even on first boot
   - Added `d /home/stellanova 0700 stellanova users -` tmpfiles rule — the `@blank` snapshot was taken before `nixos-install` ran, so the home dataset root reverts to `root:root` after every rollback; HM (running as the user) couldn't create `~/.cache` etc. in a root-owned directory
   - Added `.claude.json` to preserved files so Claude Code auth survives rollback
   - Manually seeded `/persist/home/stellanova/.local/state/{nix/profiles,home-manager/gcroots}` so first reboot works immediately
   - Root cause: `home-manager-stellanova.service` runs at boot before any user session; its `setupVars()` exits 1 if neither `~/.local/state/nix/profiles` nor `/nix/var/nix/profiles/per-user/stellanova` exists; the fallback `nix-env -q` that creates the former relies on a login-shell PATH not guaranteed at pre-login boot time

2. **Push all config fixes to GitHub** — `initrd.nix`, `stellyrland.nix`, stellyrsetp changes.

3. **Restore files from ExtraDisk** — copy needed personal files from `/ExtraDisk` (Btrfs) to the new ZFS system.

4. **Reformat ExtraDisk to ZFS** — after files are safely restored:
   - Change `fsType` from `btrfs` to `zfs`, device to `zextra/data` in `extra-disk.nix`
   - Remove Btrfs mount options; properties set at pool/dataset level
   - Add `zextra` to `services.zfs.autoScrub.pools`
   - Remove `btrfs-progs` from `storage.nix` packages

5. **Write `hdd.nix` with syncoid** — rewrite backup module using syncoid instead of btrbk; re-add `"hdd"` to host aspects. Decision pending: reformat HDD to ZFS, or keep Btrfs with rsync fallback.

6. **Enroll Secure Boot keys** — run `stellyr-secureboot-setup`, set `secureBoot = true`, rebuild.

7. **Enroll TPM2 auto-unlock** — run `stellyr-tpm-setup` after Secure Boot is enrolled and system is stable.
