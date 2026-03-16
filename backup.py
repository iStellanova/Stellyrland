import decman
from decman import Directory, File

decman.execution_order = ["files", "pacman", "aur", "flatpak", "systemd"]
# ==========================================
# 1. CORE SYSTEM PACKAGES (Pacman)
# ==========================================
decman.pacman.packages |= {
    # System Base:
    "amd-ucode",  # AMD Microcode.
    "base",  # Base Packages.
    "base-devel",  # Base Packages.
    "btrfs-progs",  # BTRFS Engine.
    "efibootmgr",  # EFI Boot Manager.
    "flatpak",  # Flatpak Apps
    "grub",  # Bootloader.
    "grub-btrfs",  # BTRFS Grub Loader.
    "gst-plugin-pipewire",  # Pipewire Engine.
    "linux",  # Linux Packages.
    "linux-firmware",  # Linux Firmware.
    "linux-headers",  # Linux Headers.
    "linux-zen-headers", # Linux Zen Headers.
    "linux-zen",  # Zen Linux Kernel.
    "pacman-contrib",  # Pacman Library Utilities.
    "pipewire",  # Pipewire System.
    "pipewire-alsa",  # Alsamixer for Pipewire.
    "pipewire-jack",  # Pipewire Jack System.
    "pipewire-pulse",  # Pipewire Pulseaudio Integration.
    "rsync",  # Copy Utility for Files and Directories.
    "sddm",  # Login greeter.
    "snapper",  # Backup Manager.
    "sof-firmware",  # Audio Support.
    "uwsm",  # Universal Wayland Session Manager, bridge for Hyprland.
    "wireplumber",  # Pipewire Dependency to Manage Sound.
    "wl-clip-persist",  # Wayland Clipboard Persistence even when Programs Exit.
    "xorg-server",  # Xord Window Server.
    "xorg-xwayland",  # Wayland X compat layer.
    # General Dependencies:
    "docker",  # Docker.
    "docker-compose",  # Docker Compose Tool.
    "ffmpegthumbnailer",  # Thumbnail Generator for FFMPEG
    "gst-plugins-ugly",  # Plugins for audio and media.
    "gtk-vnc",  # GTK viewer for VNC libraries in GTK Apps.
    "mpv-mpris",  # MPV mpris Integration.
    "smartmontools",  # Storage Health Tool.
    "snap-pac",  # Pacman Snapper Integration.
    # Hyprland:
    "hypridle",  # Hyprland idle utility.
    "hyprland",  # Wayland Compositor.
    "hyprlock",  # Lock Screen.
    "hyprpolkitagent",  # Hyprland Dependency.
    "hyprshot",  # Hyprland Screenshotter.
    "unzip", # Better Zip Support for File Roller.
    "xdg-desktop-portal-gtk",  # Hyprland Dependency for Open File Dialogues.
    "xdg-desktop-portal-hyprland",  # Hyprland Dependency for Screenshare and Shortcuts.
    "xdg-utils",  # Hyprland Dependency for Default Apps.
    # CLI QOL Tools:
    "bat",  # cat Clone with Syntax Highlighting.
    "eza",  # ls Command Alternative.
    "fd",  # Find Command Alternative.
    "git",  # git command line utility.
    "man-db",  # Manual Pages for UNIX.
    # TUI Applications:
    "btop",  # HTOP Alternative.
    "cava",  # TUI Visualizer.
    "impala", # TUI Wifi Settings.
    "iwd",  # Internet Connectivity Daemon.
    "neovim",  # VIM but better.
    "networkmanager",  # Network Management TUI.
    "wiremix", # TUI Audio Mixer.
    "yazi",  # TUI file manager.
    # CLI Tools:
    "cpufetch",  # Fastfetch, but for CPU.
    "figlet",  # Cool Text Generator.
    "fastfetch",  # System Information Grabber
    "firewalld",  # Firewall Utility
    "wget",  # HTTP, HTTPS, FTP cli tool.
    "unarchiver",  # TUI Tool for zip files.
    # Applications:
    "blanket",  # Sounds App.
    "bleachbit",  # File Cleanup Utility.
    "btrfs-assistant",  # BTRFS dashboard.
    "discord",  # Discord Package.
    "file-roller",  # Extraction Utility.
    "filelight",  # Disk Image GUI App
    "gimp",  # Graphic Manipulation Tool.
    "gpu-screen-recorder",  # GPU Screen Recorder.
    "imv",  # Image Viewer.
    "kdenlive",  # Editor for Video Production.
    "kvantum",  # QT Themer.
    "kvantum-qt5",  # Kvantum, but for older QT.
    "lact",  # GPU Tuning Utility.
    "lapce", # GUI Text Editor.
    "liquidctl",  # AIO Control.
    "lollypop",  # GTK Music Player.
    "mpv",  # Video Player.
    "nautilus",  # GNOME File Manager.
    "nicotine+",  # P2P Network Manager.
    "nwg-displays",  # NWG Display Manager for Hyprland.
    "nwg-look",  # NWG Look, an app for display configuration.
    "obs-studio",  # OBS studio recording.
    "pavucontrol",  # Pulseaudio Volume Control.
    "prismlauncher",  # Minecraft Launcher.
    "resources",  # System Resource Manager.
    "steam",  # Game Launcher
    "sushi",  # Quick Look for Nautilus.
    "telegram-desktop",  # Telegram App.
    "transmission-gtk",  # Bitorrent Client.
    "virtualbox", # Virtual Machines.
    "vlc",  # Media Player.
    "kitty",  # Terminal Emulator
    # Drivers:
    "bluez",  # Bluetooth Driver.
    "bluez-utils",  # Bluetooth Utils for Debugging.
    "cliphist",  # Clipboard Manager.
    "ddcutil",  # Monitor Control.
    "ollama-rocm",  # Ollama ROCM Driver for AMD cards.
    "vulkan-radeon",  # Radeon Vulkan Driver.
    # Steam Tools:
    "gamescope",  # Steam Runner.
    # Fonts:
    "noto-fonts",  # Noto Fonts.
    "noto-fonts-cjk",  # Noto Fonts.
    "noto-fonts-emoji",  # Noto Emoji Fonts.
    "ttf-jetbrains-mono",  # Nerd Font.
    "ttf-jetbrains-mono-nerd",  # Nerd Font.
    # Daemons:
    "power-profiles-daemon",  # Power Profiles Daemon for Performance Mode.
    # Python:
    "python-pip",  # Pip Commands.
    "python-pipx",  # Pip Commands.
    # WM Additions:
    "dunst",  # Notifications.
    "swww",  # Wallpaper Engine.
    "waybar",  # Bar GUI for Wayland Compositor.
    "rofi", # Launcher.
    "nwg-dock-hyprland", # NWG Dock for pinned apps.
    "nwg-drawer", # App Drawer for the Dock.
    "matugen", # Theme Color Generator.
    # ZSH Additions:
    "zoxide",  # ZSH Plugin to remember contextual cd commands.
    "zram-generator",  # SystemD Memory Manager
    "zsh",  # Zsh, alternative to Bash.
    "zsh-autosuggestions",  # ZSH Auto Suggestion Plugin.
    "zsh-history-substring-search",  # ZSH History Search Plugin.
    "zsh-syntax-highlighting",  # ZSH Plugin for Syntax Highlighting.
}

# ==========================================
# 2. AUR PACKAGES
# ==========================================
decman.aur.packages |= {
    # System Base (AUR):
    "yay",  # AUR Helper
    "decman",  # Declarative Management.
    # General Dependencies (AUR):
    "nautilus-open-any-terminal",  # Nautilus Terminal Integration.
    # TUI Applications (AUR):
    "pipes.sh",  # Pipes Terminal Display
    # CLI Tools (AUR):
    "downgrade",  # Bash Script to Downgrade Packages
    "fzf-tab-git",  # Pacman Search Function
    # Applications (AUR):
    "bottles",  # Wine Bottler.
    "coolercontrol",  # Controller for Hardware AIO.
    "fluxer-git",  # Discord Alternative, Fluxer.
    "gpu-screen-recorder-gtk",  # GPU Screen Recorder
    "heroic-games-launcher",  # Launcher for things like Epic, GOG, etc.
    "iconic",  # App Icon Editor
    "linuxthemestore-git",  # Theme Store, GTK I think?
    "nbteditor-bin",  # Minecraft Save Editor
    "parabolic",  # YT Downloader
    "protonup-qt-bin",  # Proton Version Manager
    "r2modman-bin", # Unity Mod Manager.
    "starc-appimage",  # Story Architect, writing app
    "stoat-desktop-git",  # Alternative Discord Client
    "vesktop",  # Discord Client
    "visual-studio-code-bin",  # Visual Studio
    "warehouse-git",  # Flatpak Manager
    "winboat-bin",  # Windows Runner
    "xclicker",  # Autoclicker
    "zen-browser-bin",  # Zen Browser
    # Daemons (AUR):
    "mprisence",  # Discord Live Music Presence Daemon
    # WM Additions (AUR):
    "waybar-mpris-git",  # Mpris Waybar Plugin
    # ZSH Additions (AUR):
    "oh-my-zsh-git",  # Oh my ZSH Git Repository
    "zsh-autocomplete-git",  # ZSH Autocomplete
    "zsh-theme-powerlevel10k",  # ZSH theme
    # Icons and Theming (AUR):
    "colloid-icon-theme-git",  # Icon Theme, Boxy, Mac-Look.
    "sddm-theme-noctalia-git",  # Noctalia Login Theme
}
# ==========================================
# 3. FLATPAK PACKAGES
# ==========================================
decman.flatpak.packages.update(
    {
        "com.github.tchx84.Flatseal",  # Flatpak permission configuration.
        "org.vinegarhq.Sober",  # Roblox.
    }
)

# ==========================================
# 4. DOTFILES & DIRECTORIES
# ==========================================

# ==========================================
# 5. SYSTEMD SERVICES (Optional)
# ==========================================
# decman.systemd.enabled_units |= {"NetworkManager.service"}
