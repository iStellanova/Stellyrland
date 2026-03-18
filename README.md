# decfiles

Declarative Arch Linux system configuration for `stellanova@stellarhost`.

Managed via [decman](https://github.com/kiviktnm/decman) — packages and dotfiles are defined in a single `source.py`, deployed with 'decman'.

---

## Dependencies

Before first sync, bootstrap the following:

- [`decman`](https://github.com/kiviktnm/decman) (AUR)
- Decman will handle all packages on its own.

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

`decman sync` will install declared packages and configurations.

---

## Theming

Theming is driven by [matugen](https://github.com/InioX/matugen) — wallpaper changes result in theming across all supported apps.

**Pipeline:**

1. Colors set through selected wallpaper and matugen.
2. Matugen distributes color profiles across quickshell and applications.

> **Note:** If matugen runs non-interactively (e.g. from a script), pass `--source-color-index 0` to suppress the color picker prompt (required since matugen 4.0.0).

---

## Known Issues

- The `custom/pkg-aur` Waybar widget runs `yay -Qua` on an interval. **Do not set this interval below ~3600 seconds** — polling too frequently will get your IP rate-limited by the AUR.

---

## Hardware

| | |
|---|---|
| Host | `stellanova@stellarhost` |
| OS | Arch Linux x86_64 |
| Kernel | Linux zen |
| WM | Hyprland (Wayland) |
| CPU | AMD Ryzen 9 9950X3D |
| GPU | AMD Radeon RX 7900 XTX |
| RAM | 64 GiB |
| Displays | DP-2 (ultrawide, primary) · DP-3 (vertical, secondary) |
