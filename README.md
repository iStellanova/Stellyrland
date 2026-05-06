# Stellyrland Nix Configuration

This is my personal configuration for my systems, managed by the nix language and its package manager.
I stick to the dendritic style. Documentation will explain all concepts I use here.
I use this to tinker, deploy, and manage my computers from home and remote. :)

## ✨ Concepts Utilized

I make use of various concepts, each of the big ones I'll explain here.

### Dendritic Configuration
I use the dendritic pattern, which condenses the "features" I use into specific single files. Things such as git, networking, and gaming configurations live in their own, single files. These individual files are then defined as single, individual "aspects" that I can enable in bulk from a single host-machine specific configuration.

I chose this as it makes maintaining my systems much cleaner. I can enable aspects defined in my configurations on different machines as I please without having to write new host-specific configurations. I just tell it to enable my git aspect and it's there. Quite convenient, no matter the machine.
### Flakes
I use nix flakes, which consist of inputs and outputs. This feature allows me to input various systems and libraries, such as nix packages, home-manager, github controlled projects, and my identity from a private repository I keep. It then outputs these libraries and configurations into a buildable system using the wider range of configurations listed dendritically. Using an input and output system allows me to version control and define what my configuration imports in order to get the result I want.
### Darwin
Nix-Darwin is my Macbook configuration. I not only manage my NixOS Linux system declaratively, but also my Macbook Pro. I define programs, system defaults, ssh keys, and more using it. This is a must for my Macbook, as typical Nix is made for other architectures and kernels.
### Private Identity
I have a custom flake outside of this repo keeping my identity separate. It is imported using the main flake in this configuration with private keys that allow me access to import that information. This is to keep it out of public prying eyes.
### Overall Declarative Nature
I love declarative deployment. Defining my system this way keeps it organized and exactly the way I want it. It is a different way of thinking about programming, but certainly one I prefer over imperative management. Nix is not exclusively declarative, I can nix-shell or nix-env imperative projects and packages I wish to run in certain points as I please.

## 📖 Documentation

- [Workflow Journey](./docs/workflow-journey.md)
- [Multi-System Management](./docs/multi-systems.md)

### 🔧 Troubleshooting
- [GPU White Screen](./docs/troubleshooting/gpu-whitescreen.md)
- [GPU Snow Artifacts](./docs/troubleshooting/gpu-snow.md)
- [Boot Loss](./docs/troubleshooting/boot-loss.md)

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

## ✨ Notable Configurations
- **Zero-Boilerplate Imports:** Modules are automatically discovered via a recursive scanner in `lib/`.
  This recursively scans the configuration folder for modules without having to explicitly import anything in said configs. Things are detected automatically.
- **BORE Scheduler:** Optimized CPU scheduling.
  Perfect for my X3D CPU, making it smarter on what gets the extra cache and what gets the extra clock speeds.
- **Smart Cleanup:** `nh` configured to strictly retain the last 20 generations.
  Keeps my system version controlled and gives me multiple rollback points.
- **Btrfs Snapshots + Scrubber:** Integrated `snapper` with automated pre-rebuild hooks.
  Maintainable filesystems and snapshots to return my home folder to previous states if I must roll back file changes.

## 🛠️ Main Aspects Involved
- **Architecture:** Dendritic (Keeps things separate and maintainable as aspects that can be toggled.)
- **Framework:** `flake-parts` (Allows version control and using defined inputs.)
- **OS:** NixOS (Unstable) & macOS (Darwin)
- **WM:** Hyprland
- **Shell:** Zsh
- **Editor:** Zed / Neovim
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

## 📜 Credits & Inspiration
- **Vimjoyer:** For popularizing the Dendritic pattern.
- [LazyVim](https://github.com/LazyVim/LazyVim) for the Neovim base.
- [Noctalia Dev](https://github.com/noctalia-dev) for the shell components.
