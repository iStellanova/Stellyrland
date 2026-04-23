# Dendritic NixOS & Home Manager Configuration

A highly modular, feature-centric **Dendritic** NixOS configuration for **stellyrland**, powered by **flake-parts** and **Hyprland**.

## 📂 Project Structure (Dendritic)

The configuration follows the **Dendritic Pattern**, where logic is organized by **feature** rather than system/user splits. Every file in `modules/` is automatically discovered and imported.

```text
/etc/nixos/
├── flake.nix               # Entry point using flake-parts
├── hosts/                  # Machine-specific entry points
│   └── stellyrland/        # Primary workstation configuration
│       ├── default.nix     # Enabled features (aspects) for this host
│       └── hardware-configuration.nix
├── modules/                # Self-contained feature modules (Aspects)
│   ├── core/               # Base system (Boot, Users, Hardware, XDG)
│   ├── desktop/            # UI & Theming (Hyprland, Styling)
│   ├── programs/           # Applications (Gaming, Neovim, Zsh, Zed)
│   └── services/           # Background daemons (Lact, OpenRGB, Snapper)
├── assets/                 # Non-code resources (Wallpapers, etc.)
├── lib/                    # Custom Nix helpers (Recursive scanner)
└── README.md
```

## 🛠️ Tech Stack
- **Architecture:** Dendritic (Feature-centric)
- **Framework:** `flake-parts`
- **OS:** NixOS (Unstable)
- **WM:** Hyprland
- **Shell:** Zsh (Powerlevel10k)
- **Editor:** Zed / Neovim (LazyVim)
- **Terminal:** Kitty
- **Bar/Shell:** Noctalia Shell
- **Theming:** Catppuccin Macchiato (Flamingo)

## ✨ Key Features
- **Zero-Boilerplate Imports:** Modules are automatically discovered via a recursive scanner in `lib/`.
- **Unified Aspects:** System (NixOS) and User (Home Manager) logic for a single feature live in the same file/folder.
- **Sched-ext (scx):** Optimized CPU scheduling with `scx_lavd`.
- **Performance Kernel:** Running `linux-zen` for low latency.
- **Smart Cleanup:** `nh` configured to strictly retain the last **20 generations**.
- **Btrfs Snapshots:** Integrated `snapper` with automated pre-rebuild hooks.

### 3. Apply Configuration
```bash
# Using 'nh' (recommended)
nh os switch .

# Or using the 'rebuild' alias
rebuild
```

## ⌨️ Key Workflows
- `rebuild`: Snapshots /home, adds all changes to git, and applies configuration.
- `upgrade`: Similar to rebuild but performs a flake update first.
- `clean`: Triggers `nh clean all --keep 20`.
- `nis`: Fuzzy-find files and open them in Neovim.

## 💻 Hardware
- **CPU:** AMD Ryzen (Zen 5 Optimized)
- **GPU:** AMD Radeon (ROCm enabled)
- **Storage:** Btrfs with Zstd compression and Async discard.

## 📜 Credits & Inspiration
- **Vimjoyer:** For popularizing the Dendritic pattern.
- [LazyVim](https://github.com/LazyVim/LazyVim) for the Neovim base.
- [Catppuccin](https://github.com/catppuccin/catppuccin) for the color palette.
- [Noctalia Dev](https://github.com/noctalia-dev) for the shell components.
