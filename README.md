<p align="center">
  <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/icons/nix-snowflake-gradient.svg" width="140px" /><br/>
  <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/icons/stellyrland-title.svg" width="440px" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-Unstable-8aadf4?style=for-the-badge&logo=nixos&logoColor=24273a" />&nbsp;
  <img src="https://img.shields.io/badge/Home_Manager-Master-c6a0f6?style=for-the-badge&logo=nixos&logoColor=24273a" />&nbsp;
  <img src="https://img.shields.io/badge/Nix-Lix-d690e0?style=for-the-badge&logo=nixos&logoColor=24273a" />
  <br/>
  <img src="https://img.shields.io/badge/Dendritic-flake--parts-f5a97f?style=for-the-badge&logoColor=24273a" />&nbsp;
  <img src="https://img.shields.io/badge/Hyprland-Flake-7dc4e4?style=for-the-badge&logoColor=24273a" />&nbsp;
  <img src="https://img.shields.io/badge/nix--darwin-Master-a6da95?style=for-the-badge&logoColor=24273a" />&nbsp;
</p>

---

This is my personal configuration for my systems, managed by the nix language and the lix package manager.
I stick to the dendritic style, making use of flake-parts.
Documentation will explain all concepts I use here.
I use this to tinker, deploy, and manage my computers from home and remote. :)

<table align="center">
  <tr>
    <td colspan="2" align="center">
      <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/assets/2026-05-26-052047_hyprshot.png" width="100%" />
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/assets/2026-05-27-030856_hyprshot.png" width="100%" />
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/assets/2026-05-26-051605_hyprshot.png" width="100%" />
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/assets/2026-05-26-051516_hyprshot.png" width="100%" />
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/iStellanova/Stellyrland/assets/assets/2026-05-26-051956_hyprshot.png" width="100%" />
    </td>
  </tr>
</table>

> **Note:**<br>
> This is a personal configuration. This is not meant to be forked or used by others.

<p align="center"><strong>DOCUMENTATION</strong></p>
<p align="center">
  <a href="./docs/concepts.md">CONCEPTS</a> &nbsp;&bull;&nbsp;
  <a href="./docs/">GENERAL</a> &nbsp;&bull;&nbsp;
  <a href="./docs/troubleshooting/">DEBUG</a>
</p>

## 🏗️ Architecture

```mermaid
flowchart TD
    FF["flake-file\nauto-generates flake.nix"]

    subgraph FLAKE["flake.nix"]
        IT["flake-parts + import-tree ./modules"]
    end

    subgraph MODS["modules/"]
        AGG["flake.modules.*.*\naspects, collected by flake-parts"]
        HOSTDATA["flake.hosts.*\nper-host data"]
        MK["mkNixos / mkDarwin\nmodules/nix-extras/lib.nix"]
    end

    FF --> FLAKE
    FLAKE --> MODS
    AGG --> MK
    HOSTDATA --> MK
    MK --> SL["stellyrland\nNixOS · x86_64-linux"]
    MK --> ST["stellyrtop\nmacOS · aarch64-darwin"]
    MK --> PPF["plasmapulsefinale\nNixOS · x86_64-linux"]

    style FF fill:#363a4f,color:#cad3f5,stroke:#5b6078
    style IT fill:#363a4f,color:#cad3f5,stroke:#5b6078
    style AGG fill:#24273a,color:#c6a0f6,stroke:#494d64
    style HOSTDATA fill:#24273a,color:#8aadf4,stroke:#494d64
    style MK fill:#24273a,color:#7dc4e4,stroke:#494d64
    style SL fill:#1e2030,color:#8aadf4,stroke:#8aadf4
    style ST fill:#1e2030,color:#a6da95,stroke:#a6da95
    style PPF fill:#1e2030,color:#c6a0f6,stroke:#c6a0f6
```

## 📂 Project Structure

```text
.
├── flake.nix               # Entry point: flake-parts + import-tree ./modules
├── flake.lock              # Flake input lockfile
├── docs/                   # Documentation and troubleshooting
├── secrets/                # sops-nix encrypted secrets
│   ├── secrets.yaml
│   └── plasmapulsefinale.yaml
└── modules/                # All aspects, auto-loaded by import-tree
    ├── flake-config.nix    # Flake inputs, target systems, flake-file declarations
    ├── flake-options.nix   # flake.hosts / flake.lib / flake.factory option declarations
    ├── constants.nix       # Shared defaults merged into every host's `host.*`
    ├── treefmt.nix         # Repo-wide formatter config
    ├── devshell.nix        # Dev shell: treefmt + write-tack app
    ├── factory/             # factory.user: per-user nixos/darwin/homeManager wiring
    ├── hosts/               # Host declarations and host-specific aspect composition
    │   ├── stellyrland/     # NixOS workstation (x86_64-linux)
    │   ├── stellyrtop/      # macOS MacBook (aarch64-darwin)
    │   └── plasmapulsefinale/ # NixOS desktop (x86_64-linux)
    ├── users/               # Shared user aspect definitions
    ├── base/                # Bare necessities for any host: core, lix, nix-settings, openssh, tailscale, secrets, users
    ├── nix-extras/          # home-manager wiring, nix-tools, mkNixos/mkDarwin helpers
    ├── linux-boot/          # UKI, Secure Boot, kernel, initrd ZFS rollback
    ├── linux-hardware/      # Hardware-specific configuration
    ├── linux-storage/       # ZFS datasets, preservation, Sanoid snapshots
    ├── desktop/             # Hyprland, Noctalia, Catppuccin theming, Plasma, Nautilus
    │   ├── hyprland/        # Hyprland config, binds, animations, rules, cursor
    │   └── noctalia/        # Noctalia shell and greeter
    ├── terminal/            # CLI tools, shell aesthetics, cmdline aggregate
    │   └── zsh/             # Zsh config, completion, syntax highlighting
    ├── dev/                 # Zed, Helix, AI tools, Git, dev packages
    ├── gaming/              # Gamescope, HDR, game launchers
    ├── av/                  # GPU Screen Recorder, media players, EasyEffects
    ├── communication/       # Messaging apps
    ├── applications/        # Office, finance, writing, school, VMs, browsers, password managers, cloud storage
    ├── system/              # Darwin defs, Homebrew, mime, XDG, services-base, personal secrets
    └── openrgb/             # Peripheral RGB control
```

## ✨ Notable Configurations
- **Zero-Boilerplate Imports:** All modules under `modules/` are auto-loaded by `import-tree` — no explicit imports needed anywhere in the config.
- **BORE Scheduler:** CachyOS kernel with BORE scheduling.
  Optimized for the X3D CPU — smarter about which workloads get the extra cache vs extra clock.
- **Smart Cleanup:** `nh` configured to strictly retain the last 20 generations.
  Keeps the system version-controlled with multiple rollback points.
- **ZFS Preservation + Sanoid Snapshots:** Root and home roll back to blank ZFS snapshots on every boot; `/persist` survives. Sanoid manages daily snapshots of home and persist, with automated post-rebuild snapshots and monthly pool scrubs.

## 🛠️ Specifications
- **Architecture:** Dendritic (Keeps things separate and maintainable as aspects that can be toggled.)
- **Framework:** Flake-Parts
- **OS:** NixOS (Unstable) & macOS (Darwin)
- **Package Manager:** Lix (Community-created Nix variant)
- **WM:** Hyprland
- **Shell:** Zsh
- **Editor:** Zed / Helix
- **Terminal:** Kitty
- **Bar/Shell:** Noctalia Shell

## 💻 Hardware

### 🖥️ Stellyrland (Workstation)
- **CPU:** AMD Ryzen 9 9950X3D
- **GPU:** AMD Radeon 7900XTX 24GB (Tuned)
- **Architecture:** x86_64
- **Memory:** 64GB DDR5
- **Storage:** 4.5TB
- **OS:** NixOS

### 💻 Stellyrtop (MacBook)
- **CPU:** Apple M4
- **Architecture:** aarch64-darwin
- **Memory:** 16GB Unified
- **Storage:** 512GB
- **OS:** macOS (nix-darwin)

## ⚠️ AI Disclaimer
AI is utilized in the development of this system, largely for learning, review, and debugging.
I'm still actively learning Nix!
More elaboration on my AI morals [here](./docs/ai.md).

## 📜 Credits & Inspiration
- **[Vic](https://github.com/vic):** for Flake-File.
- **Vimjoyer:** For inspiring my adoption of the dendritic pattern.
- **[Hand7s](https://github.com/s0me1newithhand7s):** For inspiring many features I adopted.
