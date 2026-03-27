# Stellyrland

Declarative Gentoo Linux system configuration for `stellanova@stellarhost`.

Managed via Decage — packages and dotfiles are defined in a modular files, sourced from `source.py` and deployed with `decage -sa`. The desktop shell is [Quickshell](https://quickshell.outfoxxed.me/).

---

## Dependencies

Before first sync, bootstrap the following:

- Decage
- Decage will handle all packages on its own.

### Quickshell Shell

The following must be present for the shell to function fully. Most are
declared as packages in the source files — this table documents their purpose
for reference.

| Package | Source | Purpose |
|---|---|---|
| [`quickshell`](https://quickshell.outfoxxed.me/) | AUR | Shell framework |
| `hyprland` | Compositor; required for IPC, workspace, and app launching |
| `hyprlock` | Screen locker (`lock()`) |
| `hypridle` | Idle inhibitor toggle |
| `matugen` | Wallpaper-driven theming pipeline |
| `ffmpeg` | Video wallpaper frame extraction |
| `networkmanager` | WiFi scanning, VPN state detection |
| `pipewire-pulse` | App volume control fallback (`pactl`) |
| `pacman-contrib` | `checkupdates` for pacman update count |
| `python` | Safe config file writes |
| `jq` | App volume JSON parsing |
| `nerd-fonts` | Icon glyphs throughout the UI (JetBrains Mono Nerd Font Propo) |
---

## Bootstrap

```bash
# 1. Clone the repo
git clone git@github.com:istellanova/stellyrland ~/stellyrland

# 2. cd in
cd ~/stellyrland

# 3. Sync packages and dotfiles
decage
```

`decage` will install declared packages and configurations.

---

## Theming

Theming is driven by [matugen](https://github.com/InioX/matugen) — wallpaper changes result in theming across all supported apps.

**Pipeline:**

1. Colors set through selected wallpaper and matugen.
2. Matugen distributes color profiles across Quickshell and applications.

> **Note:** If matugen runs non-interactively (e.g. from a script), pass `--source-color-index 0` to suppress the color picker prompt (required since matugen 4.0.0).

---

## Misc

- `colors.json` — snapshot of the current matugen-generated color palette.
- `etc/coolercontrol/` — fan and pump control profiles managed alongside dotfiles.

---

## Hardware

| | |
|---|---|
| Host | `stellanova@stellarhost` |
| OS | Gentoo Linux x86_64 |
| Kernel | Gentoo Linux |
| Init | OpenRC |
| WM | Hyprland (Wayland) |
| Shell | Quickshell |
| CPU | AMD Ryzen 9 9950X3D |
| GPU | AMD Radeon RX 7900 XTX |
| RAM | 64 GiB |
| Displays | 3440x1440 (ultrawide, primary) · 2560x1440 (vertical, secondary) |
