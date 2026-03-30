# Stellyrland 🌌

Modular NixOS configuration for `stellanova@stellyrland`, powered by Nix Flakes and Home Manager.

Formerly Arch, then Artix, then Gentoo — now fully declarative on NixOS.

---

## 🛠️ Tech Stack

- **OS:** [NixOS](https://nixos.org/) (Unstable)
- **WM/Compositor:** [Hyprland](https://hyprland.org/)
- **Shell Framework:** [Quickshell](https://quickshell.outfoxxed.me/)
- **Theming:** [Matugen](https://github.com/InioX/matugen) (Material You color generation)
- **Package Management:** Nix Flakes + Home Manager + [nh](https://github.com/viperML/nh)

---

## 🚀 Bootstrap

```bash
# 1. Clone the repository
git clone https://github.com/istellanova/stellyrland /etc/nixos

# 2. Apply the configuration
nh os switch /etc/nixos --hostname stellyrland
```

*Note: `nh` is used as a helper for `nixos-rebuild`. If not yet installed, you can bootstrap with:*
`sudo nixos-rebuild switch --flake .#stellyrland`

---

## 🎨 Dynamic Theming

Theming is driven by **Matugen**. When a wallpaper is selected (via `switchwall.sh`), Matugen extracts a color palette and dynamically updates:

- **Hyprland** (Borders and accents)
- **Quickshell** (Full UI colors & `colors.json`)
- **Kitty** (Terminal colorscheme)
- **Zed** (Theme generation)
- **Neovim** (Lua color variables)
- **Cava** (Visualizer gradients)

Templates and logic are defined in `modules/home/programs/matugen.nix`.

---

## 📦 Key Modules

- **Core:** System-wide packages, Zsh configuration, and user management.
- **Desktop:** Hyprland setup including `hyprlock`, `hypridle`, and custom keybinds.
- **Programs:** Modular configurations for `neovim`, `zed`, `kitty`, `btop`, and more.
- **Services:** `lact` for AMD GPU management and `openrgb` for lighting control.

---

## 💻 Hardware

| | |
|---|---|
| **Host** | `stellanova@stellyrland` |
| **OS** | NixOS (x86_64) |
| **Init** | systemd |
| **CPU** | AMD Ryzen 9 9950X3D |
| **GPU** | AMD Radeon RX 7900 XTX |
| **RAM** | 64 GiB |
| **FS** | Btrfs |
| **Displays** | 3440x1440 (Primary) · 2560x1440 (Vertical) |
