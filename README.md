# Stellyrland Personal Nix Configuration

This is my configuration I follow for my systems managed by nix. I follow the dendritic style as best I can :)

## 📂 Project Structure

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
- **Architecture:** Dendritic
- **Framework:** `flake-parts`
- **OS:** NixOS (Unstable)
- **WM:** Hyprland
- **Shell:** Zsh
- **Editor:** Zed / Neovim
- **Terminal:** Kitty
- **Bar/Shell:** Noctalia Shell

## ✨ Notable Configurations
- **Zero-Boilerplate Imports:** Modules are automatically discovered via a recursive scanner in `lib/`.
- **Unified Aspects:** System (NixOS) and User (Home Manager) logic for a single feature live in the same file/folder.
- **Sched-ext (scx):** Optimized CPU scheduling with `scx_lavd`.
- **Smart Cleanup:** `nh` configured to strictly retain the last **20 generations**.
- **Btrfs Snapshots + Scrubber:** Integrated `snapper` with automated pre-rebuild hooks.

### 3. Apply Configuration
Using 'nh' (recommended)
```bash
nh os switch .
```
Or using the 'rebuild' alias
```bash
rebuild
```

## ⌨️ Key Aliases
- `rebuild`: Snapshots /home, adds all changes to git, and applies configuration.
- `upgrade`: Similar to rebuild but performs a flake update first.
- `clean`: Triggers `nh clean all --keep 20`.
- `nixinfo`: Generation lists.

## 💻 Hardware
- **CPU:** AMD Ryzen 9 9950X3D
- **GPU:** AMD Radeon 7900XTX (Tuned)
- **Storage:** 4.5TB NVMe

## 📜 Credits & Inspiration
- **Vimjoyer:** For popularizing the Dendritic pattern.
- [LazyVim](https://github.com/LazyVim/LazyVim) for the Neovim base.
- [Noctalia Dev](https://github.com/noctalia-dev) for the shell components.
