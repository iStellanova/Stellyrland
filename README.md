# Modular NixOS & Home Manager Configuration

A highly modular, performance-optimized NixOS configuration featuring **Hyprland** and **Noctalia Shell**.

## 📂 Project Structure

```text
/etc/nixos/
├── flake.nix               # Entry point, manages inputs/outputs
├── hosts/                  # Machine-specific configurations
│   └── stellyrland/        # Primary workstation config
│       ├── default.nix     # System-level host config
│       ├── home.nix        # User-level host config (Home Manager)
│       └── hardware-configuration.nix
└── modules/                # Reusable configuration modules
    ├── nixos/              # System modules
    │   ├── core/           # Essential system logic (Boot, Nix, Users)
    │   ├── desktop/        # DE/WM specific logic (Hyprland, Display Managers)
    │   ├── services/       # Custom service configs (Lact, OpenRGB)
    │   └── gaming.nix      # Gaming-specific optimizations
    └── home/               # User modules (Home Manager)
        ├── core/           # Shell, XDG, and basic user settings
        ├── desktop/        # Theming and Desktop Environment logic
        └── programs/       # Individual application configurations
```

## 🛠️ Tech Stack
- **OS:** NixOS (Unstable)
- **WM:** Hyprland
- **Shell:** Zsh
- **Editor:** Zed / Neovim (LazyVim)
- **Terminal:** Kitty
- **Bar/Shell:** Noctalia Shell
- **Theming:** Catppuccin Macchiato (Flamingo)

## ✨ Key Features
- **Sched-ext (scx):** Optimized CPU scheduling with `scx_lavd`.
- **Performance Kernel:** Running `linux-zen` for low latency.
- **Automated Cleanup:** `nh` integrated for periodic store optimization.
- **Btrfs Snapshots:** Integrated `snapper` with automated pre-rebuild hooks.
- **Modular Design:** Separation of concerns between core system, desktop, and user programs.

## 🚀 Bootstrap

### 1. Initial Setup
```bash
# Clone the repository
git clone https://github.com/istellanova/stellyrland /etc/nixos
cd /etc/nixos
```

### 2. Apply Configuration
```bash
# Using 'nh' (recommended)
nh os switch .

# Or using standard nixos-rebuild
sudo nixos-rebuild switch --flake .#stellyrland
```

## ⌨️ Key Workflows
- `rebuild`: Snapshots /home, adds all changes to git, and applies configuration.
- `upgrade`: Similar to rebuild but performs a flake update first.
- `clean`: Manual trigger for `nh clean`.
- `nis`: Fuzzy-find files and open them in Neovim.

## 💻 Hardware
- **CPU:** AMD Ryzen (Zen 5 Optimized)
- **GPU:** AMD Radeon (ROCm enabled)
- **Storage:** Btrfs with Zstd compression and Async discard.

## 📜 Credits & Inspiration
- [LazyVim](https://github.com/LazyVim/LazyVim) for the Neovim base.
- [Catppuccin](https://github.com/catppuccin/catppuccin) for the color palette.
- [Noctalia Dev](https://github.com/noctalia-dev) for the shell components.
