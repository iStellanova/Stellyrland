# Stellyrland 🌌

> **Modular, declarative, and aesthetically driven NixOS configuration.**

Stellyrland is a personal NixOS configuration built for performance, modularity, and a polished visual experience. It leverages **Nix Flakes** and **Home Manager** to provide a fully reproducible environment across the system and user levels.

Originally evolved through the "classic" Linux journey (Arch → Artix → Gentoo), this setup now finds its home on NixOS, where every detail is defined in code.

---

## 🛠️ Tech Stack

- **OS:** [NixOS](https://nixos.org/) (Unstable branch)
- **Kernel:** [CachyOS Kernel](https://github.com/cachyos/linux-cachyos) (Optimized for desktop responsiveness)
- **WM/Compositor:** [Hyprland](https://hyprland.org/) (Wayland-based, dynamic tiling)
- **Shell & UI:** [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) (Dynamic, extensible system shell)
- **Theming:** **Noctalia** (Material You-inspired palette generation and real-time UI updates)
- **Package Management:** Nix Flakes + Home Manager + [nh](https://github.com/viperML/nh) (Nix Helper)
- **File System:** Btrfs with [Snapper](https://github.com/ambv/snapper) for automated timelines and rollbacks

---

## ✨ Key Features

- **🎨 Dynamic Theming:** Powered by **Noctalia**. When you change your wallpaper, the system extracts a color palette and propagates it to your shell, terminal, and system UI instantly.
- **🏗️ Modular Architecture:** Clean separation between system-level (`modules/nixos`) and user-level (`modules/home`) configurations. Adding new programs or services is as simple as importing a new `.nix` file.
- **🚀 Performance Focused:** Uses the CachyOS kernel and optimized flags for a smooth, high-refresh-rate gaming and development experience.
- **🛡️ Atomic Updates:** Leveraging NixOS's core strength—if a build fails or a change breaks something, rolling back is a single boot entry away.
- **🔧 Hardware Control:** Integrated [LACT](https://github.com/ilya-zlobintsev/LACT) for AMD GPU tuning and **OpenRGB** for synchronized lighting control.

---

## 📂 Project Structure

```text
/etc/nixos/
├── flake.nix              # Entry point for the system configuration
├── hosts/
│   └── stellyrland/       # Machine-specific configuration (Host: stellyrland)
│       ├── default.nix    # Main host configuration
│       └── home.nix       # User-specific home-manager imports
└── modules/
    ├── nixos/             # System-level modules (Services, Hardware, Core)
    └── home/              # User-level modules (Programs, Desktop, Shell)
        ├── desktop/       # Hyprland, binds, and window rules
        └── programs/      # Modular app configs (Neovim, Zed, Kitty, etc.)
```

---

## 🚀 Bootstrap

### 1. Initial Setup
If you are on a fresh NixOS install, ensure you have `git` and `nix-command flakes` enabled.

```bash
# Clone the repository
git clone https://github.com/istellanova/stellyrland /etc/nixos
cd /etc/nixos
```

### 2. Apply Configuration
We use `nh` (Nix Helper) for a better CLI experience, but you can use standard Nix commands to bootstrap.

**Using `nh` (Recommended):**
```bash
nh os switch . --hostname stellyrland
```

**Using standard Nix:**
```bash
sudo nixos-rebuild switch --flake .#stellyrland
```

---

## ⌨️ Key Workflows

- **Rebuild System:** `rebuild` (Custom Zsh alias that creates a Snapper snapshot before switching)
- **Update Flake:** `upgrade` (Updates inputs and rebuilds)
- **Clean Generations:** `clean` (Keeps the last 5 generations)
- **Shell UI:**
  - `SUPER + Tab`: Toggle Wallpaper / Theme
  - `SUPER + Shift + X`: Session Menu
  - `SUPER`: Toggle App Launcher

---

## 💻 Hardware

| Component | Specification |
|:--- |:--- |
| **CPU** | AMD Ryzen 9 9950X3D |
| **GPU** | AMD Radeon RX 7900 XTX (24GB VRAM) |
| **RAM** | 64 GiB DDR5 |
| **Storage** | 2TB NVMe (Btrfs) + Extra Disk (Ext4) |
| **Displays** | 3440x1440@175Hz (Primary Ultra-wide) · 2560x1440@100Hz (Vertical) |
| **Kernel** | Linux Cachyos |

---

## 📜 Credits & Inspiration
- [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) for the beautiful UI.
- [LazyVim](https://www.lazyvim.org/) for the Neovim foundation.
- The Nix community for the endless modularity.
