# NixOS Reinstall & Secure Boot Integration Guide

This guide describes the complete workflow for performing a fresh, reproducible installation of **Stellyrland** from a live environment, utilizing Btrfs Impermanence with automatic first-boot rollback, registering Secure Boot keys, and enrolling hardware TPM2 auto-unlock keys.

---

## Phase 1: Live USB Boot & Preparation

### 1. Boot the Live USB
Boot into a standard NixOS Live graphical or minimal USB environment.

### 2. Setup SSH Access for Private Repositories
Since this system pulls private flake inputs (`stellyrdata` and `echo-bridge`) via SSH, you must load your private SSH key in the live environment:

```bash
# Start the SSH agent in the live shell
eval "$(ssh-agent -s)"

# Add your private GitHub SSH key (e.g. from an external backup drive)
ssh-add /path/to/your/backup/id_ed25519

# Verify SSH connectivity to GitHub
ssh -T git@github.com
```

### 3. Clone and Navigate to the Repository
Clone the configuration repository to the live environment:

```bash
git clone git@github.com:iStellanova/Stellyrland.git /tmp/stellyrland
cd /tmp/stellyrland
```

---

## Phase 2: Partitioning & Installation

### 1. The Secure Boot Initial Bypass
Lanzaboote requires system keys to sign kernel images, which cannot exist prior to system initialization. Therefore, we **temporarily disable** Secure Boot in the configuration so that `nixos-install` configures standard `systemd-boot`.

Open `hosts/stellyrland/default.nix` in a terminal editor and temporarily set `secureBoot` to `false`:

```nix
      boot = {
        enable = true;
        secureBoot = false; # Set to false for the initial install phase!
      };
```

### 2. Partition and Mount the Disks via Pinned Disko
Execute the Disko module **directly from your flake** to ensure it matches the exact pinned version in your `flake.lock`:

```bash
sudo nix run .#disko -- --mode destroy,format,mount ./hosts/stellyrland/disko.nix
```

> [!WARNING]
> This command will permanently destroy all existing partition tables and data on `/dev/disk/by-id/nvme-Corsair_MP700_A72YB338003QTJ` and `/dev/disk/by-id/nvme-Sabrent_SB-RKT4P-2TB_48820969804065`.

> [!NOTE]
> Disko automatically creates the pristine, empty `@blank` subvolume during Btrfs formatting.

### 3. Perform the Initial NixOS Installation
Run the NixOS installer using your local configuration flake:

```bash
sudo nixos-install --flake .#stellyrland
```

Once completed, set the user passwords when prompted and reboot the machine.

---

## Phase 3: Post-Boot Onboarding & Helper Utilities

Because the pristine empty `@blank` subvolume was created during the Disko formatting phase, **no manual snapshot seeding is required.** The rollback service automatically initializes `/` on your first boot.

Once booted into your fresh installation, use the custom, automated shell helper scripts (provided by `aspects.core.setup.enable = true`) to fully enroll your system.

### 1. Enroll Secure Boot Keys
Run the custom automated Secure Boot PKI registration utility:

```bash
sudo stellyr-secureboot-setup
```

This generates keys and enrolls custom system signatures (including Microsoft OEM signatures to preserve hardware and dual-boot compatibility).

### 2. Enable Lanzaboote Secure Boot in the Flake
Edit `/etc/nixos/hosts/stellyrland/default.nix` to re-enable Secure Boot globally:

```nix
      boot = {
        enable = true;
        secureBoot = true; # Enabled permanently now!
      };
```

Rebuild the system to generate signed Unified Kernel Images (UKIs) using Lanzaboote:

```bash
sudo nixos-rebuild switch --flake .#stellyrland
```

Reboot your machine, enter the BIOS, and ensure **Secure Boot is enabled**. Your system will now boot fully verified and signed!

### 3. Enroll TPM2 Auto-Unlock
Once booted verified and signed, run the custom TPM2 setup utility to automatically bind your motherboard's hardware TPM chip to both crypt containers (`cryptroot` and `cryptextra`):

```bash
sudo stellyr-tpm-setup
```

> [!IMPORTANT]
> If you ever upgrade your motherboard BIOS, or if UEFI parameters change, the PCR state will shift. The system will prompt you for the standard recovery passphrase you entered during installation. Simply boot using the passphrase, and re-run the `sudo stellyr-tpm-setup` command to re-bind the TPM2 to the new BIOS state.
