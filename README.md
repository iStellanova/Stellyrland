# decfiles

Declarative Arch Linux system configuration for `stellanova@stellarhost`.

Managed via [decman](https://github.com/kiviktnm/decman) — packages and dotfiles are defined in a single `source.py`, deployed with `decman`. The desktop shell is [Quickshell](https://quickshell.outfoxxed.me/).

---

## Dependencies

Before first sync, bootstrap the following:

- [`decman`](https://github.com/kiviktnm/decman) (AUR)
- Decman will handle all packages on its own.

### Quickshell Shell

The following must be present for the shell to function fully. Most are
declared as packages in `source.py` — this table documents their purpose
for reference.

| Package | Source | Purpose |
|---|---|---|
| [`quickshell`](https://quickshell.outfoxxed.me/) | AUR | Shell framework |
| `hyprland` | AUR | Compositor; required for IPC, workspace, and app launching |
| `hyprlock` | AUR | Screen locker (`lock()`) |
| `hypridle` | AUR | Idle inhibitor toggle |
| `matugen` | AUR | Wallpaper-driven theming pipeline |
| `ffmpeg` | extra | Video wallpaper frame extraction |
| `networkmanager` | extra | WiFi scanning, VPN state detection |
| `pipewire-pulse` | extra | App volume control fallback (`pactl`) |
| `pacman-contrib` | extra | `checkupdates` for pacman update count |
| `yay` | AUR | AUR update count (`yay -Qua`) |
| `rfkill` | core | Bluetooth hardware toggle |
| `python` | core | Safe config file writes |
| `jq` | extra | App volume JSON parsing |
| `nerd-fonts` | AUR | Icon glyphs throughout the UI (JetBrains Mono Nerd Font Propo) |
---

## Bootstrap

```bash
# 1. Clone the repo
git clone git@github.com:istellanove/decfiles ~/decfiles

# 2. cd in
cd ~/decfiles

# 3. Sync packages and dotfiles
decman sync
```

`decman` will install declared packages and configurations.

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
| OS | Arch Linux x86_64 |
| Kernel | Linux zen |
| WM | Hyprland (Wayland) |
| Shell | Quickshell |
| CPU | AMD Ryzen 9 9950X3D |
| GPU | AMD Radeon RX 7900 XTX |
| RAM | 64 GiB |
| Displays | DP-2 (ultrawide, primary) · DP-3 (vertical, secondary) |
