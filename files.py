# ==========================================
# DOTFILES & DIRECTORIES
# ==========================================

import decman
from decman import Directory, File
from config import HOME, USER

# --- Hyprland ---
decman.files[f"{HOME}/.config/hypr/hyprland.conf"]   = File(source_file="./config/hypr/hyprland.conf",   owner=USER)
decman.files[f"{HOME}/.config/hypr/keybinds.conf"]   = File(source_file="./config/hypr/keybinds.conf",   owner=USER)
decman.files[f"{HOME}/.config/hypr/looknfeel.conf"]  = File(source_file="./config/hypr/looknfeel.conf",  owner=USER)
decman.files[f"{HOME}/.config/hypr/rules.conf"]      = File(source_file="./config/hypr/rules.conf",      owner=USER)
decman.files[f"{HOME}/.config/hypr/hyprlock.conf"]   = File(source_file="./config/hypr/hyprlock.conf",   owner=USER)
decman.files[f"{HOME}/.config/hypr/hyprtoolkit.conf"]= File(source_file="./config/hypr/hyprtoolkit.conf",owner=USER)
decman.files[f"{HOME}/.config/hypr/hypridle.conf"]   = File(source_file="./config/hypr/hypridle.conf",   owner=USER)

# --- Terminal ---
decman.files[f"{HOME}/.config/kitty/kitty.conf"]  = File(source_file="./config/kitty/kitty.conf",  owner=USER)
decman.files[f"{HOME}/.config/kitty/kittymy.conf"] = File(source_file="./config/kitty/kittymy.conf", owner=USER)

# --- Theming ---
decman.files[f"{HOME}/.config/matugen/config.toml"]      = File(source_file="./config/matugen/config.toml", owner=USER)
decman.directories[f"{HOME}/.config/matugen/templates"]  = Directory(source_directory="./config/matugen/templates", owner=USER)

# --- Bar ---
decman.directories[f"{HOME}/.config/quickshell"] = Directory(source_directory="./config/quickshell", owner=USER, permissions=0o755)

# --- Apps ---
decman.files[f"{HOME}/.config/btop/btop.conf"]      = File(source_file="./config/btop/btop.conf", owner=USER)
decman.directories[f"{HOME}/.config/fastfetch"]     = Directory(source_directory="./config/fastfetch", owner=USER)
decman.files[f"{HOME}/.config/zed/settings.json"]   = File(source_file="./config/zed/settings.json", owner=USER)
decman.files[f"{HOME}/.config/cava/config"]         = File(source_file="./config/cava/config", owner=USER)
decman.directories[f"{HOME}/.config/cava/shaders"]  = Directory(source_directory="./config/cava/shaders", owner=USER)

# --- Shell ---
decman.files[f"{HOME}/.zshrc"]       = File(source_file="./zshrc/.zshrc", owner=USER)
decman.directories[f"{HOME}/zshrc"]  = Directory(source_directory="./zshrc/zshrc", owner=USER)

# --- CoolerControl ---
decman.files["/etc/coolercontrol/config.toml"]  = File(source_file="./etc/coolercontrol/config.toml")
decman.files["/etc/coolercontrol/config-ui.json"] = File(source_file="./etc/coolercontrol/config-ui.json")
decman.files["/etc/coolercontrol/modes.json"]   = File(source_file="./etc/coolercontrol/modes.json")
