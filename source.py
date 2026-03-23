import decman
from decman import Directory, File

# NOTES:
# Don't forget to add amdgpu.ppfeaturemask=0xffffffff to grub config.

decman.execution_order = ["pacman", "aur", "flatpak", "files"]

# ==========================================
# PACMAN PACKAGES
# ==========================================

# --- System Base ---
decman.pacman.packages |= {
    "amd-ucode",            # AMD Microcode.
    "base",                 # Arch Base System.
    "base-devel",           # Base Development Tools.
    "btrfs-progs",          # BTRFS Engine.
    "cronie",               # OpenRC Timer Daemon.
    "efibootmgr",           # EFI Boot Manager.
    "elogind",              # OpenRC Login Manager.
    "flatpak",              # Flatpak Apps.
    "grub",                 # Bootloader.
    "grub-btrfs",           # BTRFS Grub Loader.
    "gst-plugin-pipewire",  # Pipewire Engine.
    "linux-firmware",       # Linux Firmware.
    "linux-zen",            # Zen Linux Kernel.
    "linux-zen-headers",    # Linux Zen Headers.
    "pacman-contrib",       # Pacman Library Utilities.
    "pipewire",             # Pipewire System.
    "pipewire-alsa",        # Alsamixer for Pipewire.
    "pipewire-jack",        # Pipewire Jack System.
    "pipewire-pulse",       # Pipewire Pulseaudio Integration.
    "rsync",                # Copy Utility for Files and Directories.
    "sddm-openrc",          # Login Greeter.
    "snapper",              # Backup Manager.
    "sof-firmware",         # Audio Support.
    "wireplumber",          # Pipewire Dependency to Manage Sound.
    "xorg-server",          # Xorg Window Server.
    "xorg-xwayland",        # Wayland X Compat Layer.
}

# --- Audio & Media Dependencies ---
decman.pacman.packages |= {
    "ffmpegthumbnailer",    # Thumbnail Generator for FFMPEG.
    "gst-plugins-ugly",     # Plugins for Audio and Media.
    "mpv-mpris",            # MPV MPRIS Integration.
}

# --- System Utilities ---
decman.pacman.packages |= {
    "docker",               # Docker.
    "docker-compose",       # Docker Compose Tool.
    "dnsmasq",              # For VM Networking.
    "smartmontools",        # Storage Health Tool.
    "cliphist",             # Clipboard Manager.
    "ddcutil",              # Monitor Control.
    "impala",               # TUI Wifi Settings.
    "iwd",                  # Internet Connectivity Daemon.
    "networkmanager-openrc",# Network Management TUI.
    "python-pip",           # Python Package Installer.
    "python-pipx",          # Isolated Python App Installer.
    "reflector",            # Mirrorlist Updater.
    "seahorse",             # Keyring Utility.
    "unzip",                # Better Zip Support for File Roller.
    "zram-openrc",       # SystemD Memory Manager.
}

# --- Hyprland & Wayland ---
decman.pacman.packages |= {
    "hypridle",                         # Hyprland Idle Utility.
    "hyprland",                         # Wayland Compositor.
    "hyprlock",                         # Lock Screen.
    "hyprpicker",                       # Hyprland Color Picker.
    "hyprpolkitagent",                  # Hyprland Dependency.
    "hyprshot",                         # Hyprland Screenshotter.
    "xdg-desktop-portal-gtk",           # Hyprland Dependency for Open File Dialogues.
    "xdg-desktop-portal-hyprland",      # Hyprland Dependency for Screenshare and Shortcuts.
    "xdg-utils",                        # Hyprland Dependency for Default Apps.
}

# --- WM Additions ---
decman.pacman.packages |= {
    "matugen",              # Theme Color Generator.
    "nwg-displays",         # NWG Display Manager for Hyprland.
    "nwg-look",             # NWG Look, an App for Display Configuration.
    "kvantum",              # QT Themer.
    "kvantum-qt5",          # Kvantum, but for Older QT.
    "wl-clip-persist",      # Wayland Clipboard Persistence even when Programs Exit.
}

# --- Drivers ---
decman.pacman.packages |= {
    "bluez-openrc",         # Bluetooth Driver.
    "bluez-utils",          # Bluetooth Utils for Debugging.
    "ollama-rocm",          # Ollama ROCM Driver for AMD Cards.
    "vulkan-radeon",        # Radeon Vulkan Driver.
}

# --- Fonts ---
decman.pacman.packages |= {
    "noto-fonts",           # Noto Fonts.
    "noto-fonts-cjk",       # Noto CJK Fonts.
    "noto-fonts-emoji",     # Noto Emoji Fonts.
    "ttf-jetbrains-mono-nerd", # JetBrains Mono Nerd Font.
}

# --- CLI & TUI Tools ---
decman.pacman.packages |= {
    "bat",                  # cat Clone with Syntax Highlighting.
    "btop",                 # HTOP Alternative.
    "cava",                 # TUI Visualizer.
    "cpufetch",             # Fastfetch, but for CPU.
    "croc",                 # File Sharing Utility.
    "eza",                  # ls Command Alternative.
    "fastfetch",            # System Information Grabber.
    "fd",                   # Find Command Alternative.
    "figlet",               # Cool Text Generator.
    "git",                  # Git Command Line Utility.
    "github-cli",           # Github CLI Interface.
    "kitty",                # Terminal Emulator.
    "man-db",               # Manual Pages for UNIX.
    "neovim",               # VIM but Better.
    "proton-vpn-cli",       # ProtonVPN CLI Interface.
    "ripgrep",              # Better grep Command.
    "tldr",                 # Manual Pages, but Shortened.
    "tree",                 # Directory Tree Command.
    "wget",                 # HTTP, HTTPS, FTP CLI Tool.
    "wiremix",              # TUI Audio Mixer.
    "yazi",                 # TUI File Manager.
}

# --- ZSH ---
decman.pacman.packages |= {
    "zoxide",                           # ZSH Plugin to Remember Contextual cd Commands.
    "zsh",                              # ZSH, Alternative to Bash.
    "zsh-autosuggestions",              # ZSH Auto Suggestion Plugin.
}

# --- Applications ---
decman.pacman.packages |= {
    "alsa-scarlett-gui",    # Scarlett GUI for ALSA.
    "blanket",              # Sounds App.
    "bleachbit",            # File Cleanup Utility.
    "btrfs-assistant",      # BTRFS Dashboard.
    "discord",              # Discord Package.
    "file-roller",          # Extraction Utility.
    "filelight",            # Disk Image GUI App.
    "gimp",                 # Graphic Manipulation Tool.
    "imv",                  # Image Viewer.
    "kdenlive",             # Editor for Video Production.
    "liquidctl",            # AIO Control.
    "lollypop",             # GTK Music Player.
    "mpv",                  # Video Player.
    "nautilus",             # GNOME File Manager.
    "nicotine+",            # P2P Network Manager.
    "obs-studio",           # OBS Studio Recording.
    "pavucontrol",          # Pulseaudio Volume Control.
    "qemu-full",            # QEMU VM.
    "resources",            # System Resource Manager.
    "sushi",                # Quick Look for Nautilus.
    "telegram-desktop",     # Telegram App.
    "transmission-gtk",     # Bittorrent Client.
    "virt-manager",         # Virtual Manager.
    "zed",                  # GUI Text Editor.
}

# --- Gaming ---
decman.pacman.packages |= {
    "gamescope",            # Wayland Game Session Compositor.
    "prismlauncher",        # Minecraft Launcher.
    "steam",                # Game Launcher.
}

# ==========================================
# AUR PACKAGES
# ==========================================

# --- System Base ---
decman.aur.packages |= {
    "decman",               # Declarative Management.
    "yay",                  # AUR Helper.
}

# --- General Dependencies ---
decman.aur.packages |= {
    "nautilus-open-any-terminal", # Nautilus Terminal Integration.
}

# --- CLI & TUI Tools ---
decman.aur.packages |= {
    "downgrade",            # Bash Script to Downgrade Packages.
    "fzf-tab-git",          # ZSH Tab Completion.
    "pipes.sh",             # Pipes Terminal Display.
    "ani-cli",              # Anime CLI Tool.
    "terminal-rain-lightning", # Terminal Rain Showcase.
    "peaclock",            # Terminal Clock Showcase.
}

# --- ZSH ---
decman.aur.packages |= {
    "oh-my-zsh-git",                # Oh My ZSH Git Repository.
    "zsh-theme-powerlevel10k",      # ZSH Theme.
}

# --- Daemons ---
decman.aur.packages |= {
    "mprisence",            # Discord Live Music Presence Daemon.
}

# --- Icons & Theming ---
decman.aur.packages |= {
    "colloid-icon-theme-git",   # Icon Theme, Boxy, Mac-Look.
    "iconic",                   # App Icon Editor.
    "linuxthemestore-git",      # Theme Store, GTK.
}

# --- Applications ---
decman.aur.packages |= {
    "antigravity",          # Antigravity, Agentic Assistant.
    "betterbird-bin",       # Betterbird Browser.
    "bottles",              # Wine Bottler.
    "cpptrace",             # C++ Trace Utility, Quickshell Dependency.
    "coolercontrol",        # Controller for Hardware AIO.
    "fluxer-git",           # Discord Alternative, Fluxer.
    "github-desktop-bin",   # Github Desktop Client.
    "gpu-screen-recorder-gtk", # GPU Screen Recorder GTK Frontend.
    "google-breakpad",      # Crash Report Dependency for Quickshell.
    "heroic-games-launcher", # Launcher for Epic, GOG, etc.
    "nbteditor-bin",        # Minecraft Save Editor.
    "oh-my-posh-bin",       # Oh My Posh, Terminal Theme.
    "parabolic",            # YT Downloader.
    "protonup-qt-bin",      # Proton Version Manager.
    "quickshell-git",       # System Shell.
    "r2modman-bin",         # Unity Mod Manager.
    "starc-appimage",       # Story Architect, Writing App.
    "stoat-desktop-git",    # Alternative Discord Client.
    "warehouse-git",        # Flatpak Manager.
    "xclicker",             # Autoclicker.
    "zen-browser-bin",      # Zen Browser.
}

# ==========================================
# FLATPAK PACKAGES
# ==========================================
decman.flatpak.packages |= {
    "com.github.tchx84.Flatseal",   # Flatpak Permission Configuration.
    "org.vinegarhq.Sober",          # Roblox.
}

# ==========================================
# DOTFILES & DIRECTORIES
# ==========================================

# --- Hyprland ---
decman.files["/home/stellanova/.config/hypr/hyprland.conf"] = File(source_file="./config/hypr/hyprland.conf", owner="stellanova")
decman.files["/home/stellanova/.config/hypr/keybinds.conf"] = File(source_file="./config/hypr/keybinds.conf", owner="stellanova")
decman.files["/home/stellanova/.config/hypr/looknfeel.conf"] = File(source_file="./config/hypr/looknfeel.conf", owner="stellanova")
decman.files["/home/stellanova/.config/hypr/rules.conf"] = File(source_file="./config/hypr/rules.conf", owner="stellanova")
decman.files["/home/stellanova/.config/hypr/hyprlock.conf"] = File(source_file="./config/hypr/hyprlock.conf", owner="stellanova")
decman.files["/home/stellanova/.config/hypr/hyprtoolkit.conf"] = File(source_file="./config/hypr/hyprtoolkit.conf", owner="stellanova")
decman.files["/home/stellanova/.config/hypr/hypridle.conf"] = File(source_file="./config/hypr/hypridle.conf", owner="stellanova")

# --- Terminal ---
decman.files["/home/stellanova/.config/kitty/kitty.conf"] = File(source_file="./config/kitty/kitty.conf", owner="stellanova")
decman.files["/home/stellanova/.config/kitty/kittymy.conf"] = File(source_file="./config/kitty/kittymy.conf", owner="stellanova")

# --- Theming ---
decman.files["/home/stellanova/.config/matugen/config.toml"] = File(source_file="./config/matugen/config.toml", owner="stellanova")
decman.directories["/home/stellanova/.config/matugen/templates"] = Directory(source_directory="./config/matugen/templates", owner="stellanova")

# --- Bar ---
decman.directories["/home/stellanova/.config/quickshell"] = Directory(source_directory="./config/quickshell", owner="stellanova", permissions=0o755)

# --- Apps ---
decman.files["/home/stellanova/.config/btop/btop.conf"] = File(source_file="./config/btop/btop.conf", owner="stellanova")
decman.directories["/home/stellanova/.config/fastfetch"] = Directory(source_directory="./config/fastfetch", owner="stellanova")
decman.files["/home/stellanova/.config/zed/settings.json"] = File(source_file="./config/zed/settings.json", owner="stellanova")
decman.files["/home/stellanova/.config/cava/config"] = File(source_file="./config/cava/config", owner="stellanova")
decman.directories["/home/stellanova/.config/cava/shaders"] = Directory(source_directory="./config/cava/shaders", owner="stellanova")

# --- Shell ---
decman.files["/home/stellanova/.zshrc"] = File(source_file="./zshrc/.zshrc", owner="stellanova")
decman.directories["/home/stellanova/zshrc"] = Directory(source_directory="./zshrc/zshrc", owner="stellanova")

# --- CoolerControl ---
decman.files["/etc/coolercontrol/config.toml"] = File(source_file="./etc/coolercontrol/config.toml")
decman.files["/etc/coolercontrol/config-ui.json"] = File(source_file="./etc/coolercontrol/config-ui.json")
decman.files["/etc/coolercontrol/modes.json"] = File(source_file="./etc/coolercontrol/modes.json")
