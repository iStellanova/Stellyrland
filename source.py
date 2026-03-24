# ==========================================
# =======STELLYRLAND==ARTIX==LINUX==========
# ==========================================

import decman
from decman import Directory, File, Plugin, Module

# ==========================================
# EXECUTION PIPELINE
# ==========================================

decman.execution_order = [
    "reflector",    # Update mirrors first for fastest downloads.
    "snapper",      # Create a rollback point before any changes.
    "pacman",       # Sync official repositories.
    "paru",         # Handle AUR packages
    "flatpak",      # Update sandboxed apps.
    "files",        # Deploy Hyprland/Quickshell dotfiles.
    "gsettings",    # Enforce GSettings.
    "xdg",          # Ensure standard Home directories exist.
    "openrc",       # Manage system services.
    "orphans",      # Clean up unused dependencies.
    "cache",        # Purge old package caches.
    "btrfs",        # Run maintenance.
    "grub"          # Finalize the bootloader config.
]

# ==========================================
# PACMAN PACKAGES
# ==========================================

# --- System Base ---
decman.pacman.packages |= {
    "amd-ucode",            # AMD Microcode.
    "base",                 # Arch Base System.
    "base-devel",           # Base Development Tools.
    "btrfs-progs",          # BTRFS Engine.
    "cronie",               # Timer Daemon.
    "cronie-openrc",        # OpenRC Compat for Cronie.
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
    "docker-openrc",        # Docker.
    "docker-compose",       # Docker Compose Tool.
    "dnsmasq",              # For VM Networking.
    "gnome-themes-extra",   # GTK Themes.
    "gtk-engine-murrine",   # GTK Dependency for Catpuccin.
    "smartmontools",        # Storage Health Tool.
    "cliphist",             # Clipboard Manager.
    "ddcutil",              # Monitor Control.
    "impala",               # TUI Wifi Settings.
    "iwd",                  # Internet Connectivity Daemon.
    "libvirt-openrc",       # OpenRC Compat for QEMU.
    "networkmanager-openrc",# Network Management TUI.
    "python-pip",           # Python Package Installer.
    "python-pipx",          # Isolated Python App Installer.
    "quickshell",       # System Shell.
    "reflector",            # Mirrorlist Updater.
    "seahorse",             # Keyring Utility.
    "unzip",                # Better Zip Support for File Roller.
    "zramen-openrc",        # OPENRC zramen support.
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
    "xdg-user-dirs",                    # Generates standard user directories.
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
    "lact-openrc",          # GPU Tuning Control.
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
paru_packages = set()

# --- System Base ---
paru_packages |= {
    "decman",               # Declarative Management.
    "paru",                 # AUR Helper.
}

# --- General Dependencies ---
paru_packages |= {
    "nautilus-open-any-terminal", # Nautilus Terminal Integration.
}

# --- CLI & TUI Tools ---
paru_packages |= {
    "downgrade",            # Bash Script to Downgrade Packages.
    "fzf-tab-git",          # ZSH Tab Completion.
    "pipes.sh",             # Pipes Terminal Display.
    "ani-cli",              # Anime CLI Tool.
    "terminal-rain-lightning", # Terminal Rain Showcase.
    "peaclock",             # Terminal Clock Showcase.
}

# --- ZSH ---
paru_packages |= {
    "oh-my-zsh-git",                # Oh My ZSH Git Repository.
    "zsh-theme-powerlevel10k",      # ZSH Theme.
}

# --- Daemons ---
paru_packages |= {
    "mprisence",            # Discord Live Music Presence Daemon.
}

# --- Icons & Theming ---
paru_packages |= {
    "colloid-icon-theme-git",        # Icon Theme, Boxy, Mac-Look.
    "iconic",                        # App Icon Editor.
    "catppuccin-gtk-theme-macchiato",# GTK Theme.
}

# --- Applications ---
paru_packages |= {
    "antigravity",          # Antigravity, Agentic Assistant.
    "betterbird-bin",       # Betterbird Browser.
    "bottles",              # Wine Bottler.
    "cpptrace",             # C++ Trace Utility, Quickshell Dependency.
    "coolercontrold",       # Dependency for Coolercontrol.
    "coolercontrol",        # Controller for Hardware AIO.
    "fluxer-git",           # Discord Alternative, Fluxer.
    "github-desktop-bin",   # Github Desktop Client.
    "gpu-screen-recorder-gtk", # GPU Screen Recorder GTK Frontend.
    "google-breakpad",      # Crash Report Dependency for Quickshell.
    "nbteditor-bin",        # Minecraft Save Editor.
    "oh-my-posh-bin",       # Oh My Posh, Terminal Theme.
    "parabolic",            # YT Downloader.
    "protonup-qt-bin",      # Proton Version Manager.
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
# OPENRC SERVICES
# ==========================================
openrc_services = {
    "agetty.tty1": "default",       # TTY1 Console.
    "agetty.tty2": "default",       # TTY2 Console.
    "elogind": "boot",              # Login Manager.
    "dbus": "default",              # System Message Bus.
    "NetworkManager": "default",    # Network Connection.
    "netmount": "default",          # Network Mounts.
    "bluetoothd": "default",        # Bluetooth Daemon.
    "coolercontrold": "default",    # Hardware Control.
    "sddm": "default",              # Display Manager.
    "cronie": "default",            # Cron Jobs.
    "docker": "default",            # Docker Daemon.
    "libvirtd": "default",          # Virtualization.
    "local": "default",             # Local Startup.
    "zramen": "default",            # Zram Management.
    "lactd": "default",             # GPU Control.
    "hypridle": "default",          # Hypridle Control.
}

# ==========================================
# GSETTINGS CONFIGURATION
# ==========================================
gsettings_config = {
    "org.gnome.desktop.interface": {
        "color-scheme": "'prefer-dark'",
        "gtk-theme": "'catppuccin-macchiato-blue-standard+default'",
        "icon-theme": "'Colloid-Dark'",
        "cursor-theme": "'Bibata-Modern-Ice'",
        "font-name": "'JetBrainsMono Nerd Font 11'",
        "document-font-name": "'JetBrainsMono Nerd Font 12'",
        "monospace-font-name": "'JetBrainsMono Nerd Font 11'"
    },
    "org.gnome.desktop.wm.preferences": {
        "button-layout": "'appmenu:'"
    }
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

# ==========================================
# SYSTEM PLUGINS
# ==========================================

class ParuPlugin(Plugin):
    def __init__(self, packages: set):
        super().__init__()
        self._packages = packages

    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        if not self._packages:
            return True
        try:
            installed_raw = decman.sh("pacman -Qme", check=False, pty=False)
            installed = set(line.strip().split()[0] for line in installed_raw.splitlines() if line.strip())

            to_install = self._packages - installed
            to_remove = installed - self._packages

            if dry_run:
                if to_install:
                    print(f"{PREFIX} INFO: [paru] Would install: {' '.join(sorted(to_install))}")
                if to_remove:
                    print(f"{PREFIX} INFO: [paru] Would remove: {' '.join(sorted(to_remove))}")
                return True

            if to_install:
                pkg_list = " ".join(sorted(to_install))
                # Let sudo handle the privilege drop properly so the wheel group isn't stripped
                cmd = f"sudo -i -u stellanova bash -c 'paru -S --needed --noconfirm {pkg_list}'"
                decman.sh(cmd)

            if to_remove:
                remove_list = " ".join(sorted(to_remove))
                # Let sudo handle the privilege drop properly so the wheel group isn't stripped
                cmd = f"sudo -i -u stellanova bash -c 'paru -Rns --noconfirm {remove_list}'"
                decman.sh(cmd)

            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: [paru] {e}")
            return False

class GsettingsPlugin(Plugin):
    def __init__(self, settings: dict):
        super().__init__()
        self.settings = settings

    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        if not self.settings:
            return True

        changes_made = False

        try:
            for schema, keys in self.settings.items():
                for key, desired_value in keys.items():
                    # dbus-run-session creates a private bus for the command to
                    # prevent the "Permission denied" errors on /root/.cache/dconf
                    get_cmd = f"sudo -u stellanova dbus-run-session gsettings get {schema} {key}"
                    current_value = decman.sh(get_cmd, check=False, pty=False).strip()

                    if current_value != desired_value:
                        changes_made = True
                        if not dry_run:
                            set_cmd = f"sudo -u stellanova dbus-run-session gsettings set {schema} {key} {desired_value}"
                            decman.sh(set_cmd, check=False)
                            print(f"  -> Applied: {schema} {key} = {desired_value}")
                        else:
                            print(f"  -> [DRY RUN] Would set: {schema} {key} = {desired_value} (Current: {current_value})")

            if not changes_made:
                print(f"{PREFIX} SUMMARY: Gsettings are up-to-date.")
            else:
                print(f"{PREFIX} SUMMARY: Gsettings applied successfully.")

            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: [gsettings] {e}")
            return False

class OpenRCPlugin(Plugin):
    def __init__(self, services: dict):
        super().__init__()
        self.services = services

    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        try:
            current_raw = decman.sh("rc-update show", check=False, pty=False)
            current_state = {}
            for line in current_raw.splitlines():
                if "|" in line:
                    parts = line.split("|")
                    svc = parts[0].strip()
                    runlevels = set(parts[1].strip().split())
                    current_state[svc] = runlevels

            to_enable = {s: r for s, r in self.services.items()
                         if s not in current_state or r not in current_state[s]}
            current_enabled_default = {svc for svc, rls in current_state.items() if "default" in rls}
            to_disable = current_enabled_default - set(self.services.keys())

            if to_enable or to_disable:
                for service, runlevel in to_enable.items():
                    if not dry_run:
                        decman.sh(f"rc-update add {service} {runlevel}", check=False)
                    print(f"  -> {'Enabling' if not dry_run else '[DRY RUN] Would enable'} service: {service} on {runlevel}")

                for service in to_disable:
                    protected = {"udev", "dbus", "elogind"}
                    if service not in protected:
                        if not dry_run:
                            decman.sh(f"rc-update del {service} default", check=False)
                        print(f"  -> {'[CLEANUP] Disabled' if not dry_run else '[DRY RUN] [CLEANUP] Would disable'} unlisted service: {service}")
            else:
                print(f"{PREFIX} SUMMARY: All services are up-to-date.")
            return True
        except Exception as e:
            print(f"  -> [{CLR}ERROR{RST}] OpenRC plugin failed: {e}")
            return False

class ReflectorPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        import os
        import time
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        try:
            mirrorlist_path = "/etc/pacman.d/mirrorlist"
            week_in_seconds = 604800
            file_age = time.time() - os.path.getmtime(mirrorlist_path)

            if file_age > week_in_seconds:
                print(f"{PREFIX} INFO: Mirrorlist is old. Refreshing mirrors...")
                if not dry_run:
                    decman.sh("reflector --country 'United States' --latest 10 --protocol https --sort rate --connection-timeout 5 --download-timeout 5 --save /etc/pacman.d/mirrorlist", check=False)
                else:
                    print(f"  -> [DRY RUN] Would run: reflector --country 'United States' --latest 10 --protocol https --sort rate --connection-timeout 5 --download-timeout 5 --save /etc/pacman.d/mirrorlist")
            else:
                print(f"{PREFIX} SUMMARY: Mirrorlist is fresh (Age: {round(file_age/3600, 1)} hours). Skipping Reflector.")
            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Reflector plugin issue: {e}")
            return False

class SnapperPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        try:
            if not dry_run:
                decman.sh("snapper create --type pre --print-number --description 'Decman Sync'", check=False)
            else:
                print(f"  -> [DRY RUN] Would run: snapper create --type pre --print-number --description 'Decman Sync'")
            print(f"{PREFIX} SUMMARY: BTRFS snapshot created.")
            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Snapper plugin issue: {e}")
            return False

class GrubPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        try:
            if not dry_run:
                print(f"  -> Generating grub configuration file...")
                decman.sh("grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1")
                print("  -> success")
            else:
                print(f"  -> [DRY RUN] Would run: grub-mkconfig -o /boot/grub/grub.cfg")
            return True
        except Exception as e:
            print(f"  -> failed: {e}")
            return False

class CacheCleanupPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        import os
        import time
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        marker_file = "/var/cache/pacman/pkg/.decman_last_cleared"
        week_in_seconds = 604800

        try:
            # Check if marker exists and calculate age
            if os.path.exists(marker_file):
                file_age = time.time() - os.path.getmtime(marker_file)
            else:
                # Force run if the marker doesn't exist yet
                file_age = week_in_seconds + 1

            if file_age > week_in_seconds:
                print(f"{PREFIX} INFO: Cache is older than a week. Cleaning up...")
                if not dry_run:
                    # Clean system pacman cache
                    decman.sh("paccache -r", check=False)
                    decman.sh("paccache -ruk0", check=False)

                    # Clean user AUR cache by dropping privileges
                    decman.sh("sudo -i -u stellanova bash -c 'rm -rf /home/stellanova/.cache/paru/clone/*'", check=False)

                    # Update the marker timestamp
                    decman.sh(f"touch {marker_file}", check=False)
                    print(f"  -> Cache cleared successfully.")
                else:
                    print(f"  -> [DRY RUN] Would run: paccache -r && paccache -ruk0")
                    print(f"  -> [DRY RUN] Would clear: /home/stellanova/.cache/paru/clone/*")
            else:
                print(f"{PREFIX} SUMMARY: Cache was cleared recently (Age: {round(file_age/86400, 1)} days). Skipping.")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Cache cleanup plugin issue: {e}")
            return False

class OrphanCleanupPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        try:
            # pacman -Qtdq lists true orphans.
            # It returns an error code if none exist, so check=False is required.
            orphans_raw = decman.sh("pacman -Qtdq 2>/dev/null || true", check=False, pty=False).strip()

            if not orphans_raw:
                print(f"{PREFIX} SUMMARY: No orphaned packages found. System is clean.")
                return True

            # Format the multiline output into a single space-separated string
            orphan_list = " ".join(orphans_raw.splitlines())

            print(f"{PREFIX} INFO: Found orphaned packages. Cleaning up...")

            if not dry_run:
                decman.sh(f"pacman -Rns --noconfirm {orphan_list}", check=False)
                print(f"  -> Removed orphans: {orphan_list}")
            else:
                print(f"  -> [DRY RUN] Would remove orphans: {orphan_list}")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Orphan cleanup plugin issue: {e}")
            return False

class BtrfsMaintenancePlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        import os
        import time
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        marker_file = "/var/cache/.decman_btrfs_last_run"
        month_in_seconds = 2592000  # 30 days

        try:
            # Check if marker exists and calculate age
            if os.path.exists(marker_file):
                file_age = time.time() - os.path.getmtime(marker_file)
            else:
                # Force run if the marker doesn't exist yet
                file_age = month_in_seconds + 1

            if file_age > month_in_seconds:
                print(f"{PREFIX} INFO: BTRFS maintenance is due. Starting tasks...")
                if not dry_run:
                    # 1. Balance first: Cleans up fragmented chunks.
                    # -dusage=30 is extremely fast on an NVMe and prevents "full disk" errors.
                    decman.sh("btrfs balance start -dusage=30 /", check=False)

                    # 2. Scrub second: Checks for bit-rot.
                    # This command natively drops to the background, so it won't freeze the script.
                    decman.sh("btrfs scrub start /", check=False)

                    # Update the marker timestamp
                    decman.sh(f"touch {marker_file}", check=False)
                    print(f"  -> BTRFS balance finished and background scrub started.")
                else:
                    print(f"  -> [DRY RUN] Would run: btrfs balance start -dusage=30 /")
                    print(f"  -> [DRY RUN] Would run: btrfs scrub start /")
            else:
                print(f"{PREFIX} SUMMARY: BTRFS is healthy (Last checked: {round(file_age/86400, 1)} days ago). Skipping.")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: BTRFS maintenance plugin issue: {e}")
            return False

class XdgDirsPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        CLR = "\033[1;35m"
        RST = "\033[0m"
        PREFIX = f"[{CLR}DECMAN{RST}]"

        try:
            if not dry_run:
                # Drop privileges to ensure folders are owned by stellanova, not root
                decman.sh("sudo -i -u stellanova bash -c 'xdg-user-dirs-update'", check=False)
                print(f"{PREFIX} SUMMARY: XDG user directories ensured.")
            else:
                print(f"  -> [DRY RUN] Would run: xdg-user-dirs-update as stellanova")

            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: [xdg] {e}")
            return False

# Instantiate and register plugins
decman.plugins["reflector"] = ReflectorPlugin()
decman.plugins["snapper"] = SnapperPlugin()
decman.plugins["paru"] = ParuPlugin(paru_packages)
decman.plugins["openrc"] = OpenRCPlugin(openrc_services)
decman.plugins["grub"] = GrubPlugin()
decman.plugins["gsettings"] = GsettingsPlugin(gsettings_config)
decman.plugins["cache"] = CacheCleanupPlugin()
decman.plugins["orphans"] = OrphanCleanupPlugin()
decman.plugins["btrfs"] = BtrfsMaintenancePlugin()
decman.plugins["xdg"] = XdgDirsPlugin()
