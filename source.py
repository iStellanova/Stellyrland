# ==========================================
# =======STELLYRLAND==ARTIX==LINUX==========
# ==========================================

import decman
from decman import Directory, File, Plugin, Module
from plugins import (
    ParuPlugin, GsettingsPlugin, OpenRCPlugin,
    ReflectorPlugin, SnapperPlugin, GrubPlugin,
    CacheCleanupPlugin, OrphanCleanupPlugin,
    BtrfsMaintenancePlugin, XdgDirsPlugin,
)

# Import configurations from modular files
from packages import paru_packages
from services import openrc_services
from gsettings import gsettings_config
import files

# ==========================================
# EXECUTION PIPELINE
# ==========================================

decman.execution_order = [
    "reflector",    # Update mirrors first for fastest downloads.
    "snapper",      # Create a rollback point before any changes.
    "pacman",       # Sync official repositories.
    "paru",         # Handle AUR packages.
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
# PLUGIN REGISTRATION
# ==========================================

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
