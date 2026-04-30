# Stellyrland Personal Nix Configuration

This is my configuration I follow for my systems managed by nix. I follow the dendritic style as best I can :)

Note: This configuration depends on a private identity flake for personal secrets and configuration.

## 📂 Project Structure

```text
/etc/nixos/
├── flake.nix               # Entry point using flake-parts
├── hosts/                  # Machine-specific entry points
│   ├── stellyrland/        # Primary NixOS workstation configuration
│   └── stellyrtop/         # Secondary macOS (Darwin) configuration
├── modules/                # Self-contained feature modules (Aspects)
│   ├── common/             # Shared across all platforms (NixOS/Darwin)
│   │   ├── core/           # Shared core settings (Nix, Fonts)
│   │   └── programs/       # Shared CLI & TUI apps (Git, Zsh, Neovim)
│   ├── darwin/             # macOS specific modules
│   └── nixos/              # NixOS specific modules
│       ├── core/           # Base system (Boot, Hardware, Storage, Users)
│       ├── desktop/        # UI & Theming (Hyprland, Styling)
│       ├── programs/       # GUI Applications (Zed, Gaming, Browser)
│       └── services/       # Background daemons (Lact, OpenRGB)
├── assets/                 # Non-code resources (Wallpapers, etc.)
├── lib/                    # Custom Nix helpers (Recursive scanner)
└── README.md
```

## 🛠️ Main Aspects Involved
- **Architecture:** Dendritic
- **Framework:** `flake-parts`
- **OS:** NixOS (Unstable) & macOS (Darwin)
- **WM:** Hyprland
- **Shell:** Zsh
- **Editor:** Zed / Neovim
- **Terminal:** Kitty
- **Bar/Shell:** Noctalia Shell

## ✨ Notable Configurations
- **Zero-Boilerplate Imports:** Modules are automatically discovered via a recursive scanner in `lib/`.
- **Unified Configs:** System (NixOS) and User (Home Manager) logic for a single feature live in the same file/folder.
- **BORE Scheduler:** Optimized CPU scheduling.
- **Smart Cleanup:** `nh` configured to strictly retain the last **20 generations**.
- **Btrfs Snapshots + Scrubber:** Integrated `snapper` with automated pre-rebuild hooks.

## ⌨️ Key Aliases
- `rebuild`: Snapshots /home, adds all changes to git, and applies configuration.
- `upgrade`: Similar to rebuild but performs a flake update first.
- `clean`: Triggers `nh clean all --keep 20`.
- `nixinfo`: Generation lists.

Can also flag ``check`` to look for changes before applying anything.

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

## 📜 Credits & Inspiration
- **Vimjoyer:** For popularizing the Dendritic pattern.
- [LazyVim](https://github.com/LazyVim/LazyVim) for the Neovim base.
- [Noctalia Dev](https://github.com/noctalia-dev) for the shell components.
