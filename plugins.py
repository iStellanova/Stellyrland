# ==========================================
# PLUGINS
# ==========================================

import os
import time
import decman
from decman import Plugin
from config import USER, HOME, REGION

_CLR   = "\033[1;35m"
_RST   = "\033[0m"
PREFIX = f"[{_CLR}DECMAN{_RST}]"


class ParuPlugin(Plugin):
    def __init__(self, packages: set):
        super().__init__()
        self._packages = packages

    def apply(self, store, dry_run=False, params=None) -> bool:
        if not self._packages:
            return True
        try:
            installed_raw = decman.sh("pacman -Qme", check=False, pty=False)
            installed = set(line.strip().split()[0] for line in installed_raw.splitlines() if line.strip())

            to_install = self._packages - installed
            to_remove  = installed - self._packages

            if dry_run:
                print(f"{PREFIX} INFO: [paru] Would update all AUR packages (paru -Sua)")
                if to_install:
                    print(f"  -> Would install: {' '.join(sorted(to_install))}")
                if to_remove:
                    print(f"  -> Would remove: {' '.join(sorted(to_remove))}")
                return True

            # 1. Update existing AUR packages if needed.
            updates = decman.sh(f"sudo -i -u {USER} bash -c 'paru -Qua || true'", check=False, pty=False).strip()
            if updates:
                print(f"{PREFIX} INFO: Found AUR updates. Updating...")
                decman.sh(f"sudo -i -u {USER} bash -c 'paru -Sua --noconfirm'")
            else:
                print(f"{PREFIX} SUMMARY: No AUR updates available.")

            # 2. Install missing packages.
            if to_install:
                pkg_list = " ".join(sorted(to_install))
                print(f"  -> Installing: {pkg_list}")
                decman.sh(f"sudo -i -u {USER} bash -c 'paru -S --needed --noconfirm {pkg_list}'")

            # 3. Remove unlisted packages.
            if to_remove:
                remove_list = " ".join(sorted(to_remove))
                print(f"  -> Removing: {remove_list}")
                decman.sh(f"sudo -i -u {USER} bash -c 'paru -Rns --noconfirm {remove_list}'")

            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: [paru] {e}")
            return False


class GsettingsPlugin(Plugin):
    def __init__(self, settings: dict):
        super().__init__()
        self.settings = settings

    def _get_user_dbus_address(self) -> str:
        """Attempts to find the DBUS_SESSION_BUS_ADDRESS for the user."""
        try:
            # Check for Hyprland session first as it's the primary shell
            pids_raw = decman.sh(f"pgrep -u {USER} -x 'hyprland|quickshell|sway|dbus-daemon'", check=False, pty=False).strip()
            if not pids_raw:
                # Last ditch effort: any process owned by the user
                pids_raw = decman.sh(f"pgrep -u {USER}", check=False, pty=False).strip()
            
            if not pids_raw:
                return ""

            for pid in pids_raw.splitlines()[:10]: # Check first 10 for performance
                environ_file = f"/proc/{pid}/environ"
                if os.path.exists(environ_file):
                    try:
                        with open(environ_file, "rb") as f:
                            env_data = f.read().split(b"\0")
                            for item in env_data:
                                if item.startswith(b"DBUS_SESSION_BUS_ADDRESS="):
                                    return item.decode("utf-8").split("=", 1)[1]
                    except (PermissionError, IOError):
                        continue
        except Exception:
            pass
        return ""

    def apply(self, store, dry_run=False, params=None) -> bool:
        if not self.settings:
            return True

        changes_made = False
        dbus_addr = self._get_user_dbus_address()
        
        # Build the command prefix
        if dbus_addr:
            prefix = f"sudo -u {USER} DBUS_SESSION_BUS_ADDRESS={dbus_addr}"
        else:
            # Fallback to starting a session if none is found
            prefix = f"sudo -u {USER} dbus-run-session"

        try:
            for schema, keys in self.settings.items():
                for key, desired_value in keys.items():
                    get_cmd = f"{prefix} gsettings get {schema} {key}"
                    current_value = decman.sh(get_cmd, check=False, pty=False).strip()

                    # Gsettings returns strings quoted (e.g., 'value'). 
                    # If desired is listed without quotes, common in config files, normalize it.
                    normalized_desired = desired_value
                    if current_value.startswith("'") and current_value.endswith("'"):
                        if not desired_value.startswith("'"):
                            normalized_desired = f"'{desired_value}'"

                    if current_value != normalized_desired:
                        changes_made = True
                        if not dry_run:
                            set_cmd = f"{prefix} gsettings set {schema} {key} {desired_value}"
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
                    print(f"  -> {'Enabling' if not dry_run else '[DRY RUN] Would enable'} service: {service} on {runlevel}")
                    if not dry_run:
                        decman.sh(f"rc-update add {service} {runlevel}", check=False)

                for service in to_disable:
                    protected = {"udev", "dbus", "elogind", "local", "bootmisc", "hostname", "sysfs", "root"}
                    if service not in protected:
                        print(f"  -> {'[CLEANUP] Disabled' if not dry_run else '[DRY RUN] [CLEANUP] Would disable'} unlisted service: {service}")
                        if not dry_run:
                            decman.sh(f"rc-update del {service} default", check=False)
            else:
                print(f"{PREFIX} SUMMARY: All services are up-to-date.")

            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: OpenRC plugin failed: {e}")
            return False


class ReflectorPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        try:
            mirrorlist_path = "/etc/pacman.d/mirrorlist"
            week_in_seconds = 604800
            
            # Check if file exists first to avoid crash on new systems
            if os.path.exists(mirrorlist_path):
                file_age = time.time() - os.path.getmtime(mirrorlist_path)
            else:
                file_age = week_in_seconds + 1

            if file_age > week_in_seconds:
                print(f"{PREFIX} INFO: Mirrorlist is old. Refreshing mirrors...")
                if not dry_run:
                    decman.sh(f"reflector --country {REGION} --latest 10 --protocol https --sort rate --connection-timeout 5 --download-timeout 5 --save /etc/pacman.d/mirrorlist", check=False)
                    print(f"  -> Mirrors refreshed successfully.")
                else:
                    print(f"  -> [DRY RUN] Would run: reflector --country {REGION} --latest 10 --protocol https --sort rate --connection-timeout 5 --download-timeout 5 --save /etc/pacman.d/mirrorlist")
            else:
                print(f"{PREFIX} SUMMARY: Mirrorlist is fresh (Age: {round(file_age/3600, 1)} hours).")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Reflector plugin issue: {e}")
            return False


class SnapperPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        try:
            if not dry_run:
                decman.sh("snapper create --type pre --print-number --description 'Decman Sync'", check=False)
                print(f"{PREFIX} SUMMARY: BTRFS snapshot created.")
            else:
                print(f"{PREFIX} INFO: [snapper] Would create snapshot.")
                print(f"  -> [DRY RUN] Would run: snapper create --type pre --print-number --description 'Decman Sync'")
            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Snapper plugin issue: {e}")
            return False


class GrubPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        try:
            if not dry_run:
                print(f"{PREFIX} INFO: Generating GRUB configuration...")
                decman.sh("grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1")
                print(f"  -> GRUB configuration generated successfully.")
            else:
                print(f"{PREFIX} INFO: [grub] Would generate configuration.")
                print(f"  -> [DRY RUN] Would run: grub-mkconfig -o /boot/grub/grub.cfg")
            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: Grub plugin failed: {e}")
            return False


class CacheCleanupPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        marker_file = "/var/cache/pacman/pkg/.decman_last_cleared"
        week_in_seconds = 604800

        try:
            file_age = time.time() - os.path.getmtime(marker_file) if os.path.exists(marker_file) else week_in_seconds + 1

            if file_age > week_in_seconds:
                print(f"{PREFIX} INFO: Cache is older than a week. Cleaning up...")
                if not dry_run:
                    print(f"  -> Running paccache cleanup...")
                    decman.sh("paccache -r", check=False)
                    decman.sh("paccache -ruk0", check=False)
                    print(f"  -> Cleaning AUR cache (paru -Sc)...")
                    decman.sh(f"sudo -i -u {USER} bash -c 'paru -Sc --noconfirm'", check=False)
                    decman.sh(f"touch {marker_file}", check=False)
                    print(f"  -> Cache cleared successfully.")
                else:
                    print(f"  -> [DRY RUN] Would run: paccache -r && paccache -ruk0")
                    print(f"  -> [DRY RUN] Would run: paru -Sc --noconfirm")
            else:
                print(f"{PREFIX} SUMMARY: Cache was cleared recently (Age: {round(file_age/86400, 1)} days). Skipping.")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Cache cleanup plugin issue: {e}")
            return False


class OrphanCleanupPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        try:
            orphans_raw = decman.sh("pacman -Qtdq 2>/dev/null || true", check=False, pty=False).strip()

            if not orphans_raw:
                print(f"{PREFIX} SUMMARY: No orphaned packages found. System is clean.")
                return True

            orphan_list = " ".join(orphans_raw.splitlines())
            print(f"{PREFIX} INFO: Found orphaned packages. Cleaning up...")

            if not dry_run:
                decman.sh(f"pacman -Rns --noconfirm {orphan_list}", check=False)
                print(f"  -> Removed orphans: {orphan_list}")
            else:
                print(f"{PREFIX} INFO: [orphans] Found orphaned packages.")
                print(f"  -> [DRY RUN] Would remove orphans: {orphan_list}")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: Orphan cleanup plugin issue: {e}")
            return False


class BtrfsMaintenancePlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        marker_file = "/var/cache/.decman_btrfs_last_run"
        month_in_seconds = 2592000  # 30 days

        try:
            file_age = time.time() - os.path.getmtime(marker_file) if os.path.exists(marker_file) else month_in_seconds + 1

            if file_age > month_in_seconds:
                print(f"{PREFIX} INFO: BTRFS maintenance is due. Starting tasks...")
                if not dry_run:
                    decman.sh("btrfs balance start -dusage=30 /", check=False)
                    decman.sh("btrfs scrub start /", check=False)
                    decman.sh(f"touch {marker_file}", check=False)
                    print(f"  -> BTRFS balance finished and background scrub started.")
                else:
                    print(f"  -> [DRY RUN] Would run: btrfs balance start -dusage=30 /")
                    print(f"  -> [DRY RUN] Would run: btrfs scrub start /")
            else:
                print(f"{PREFIX} SUMMARY: BTRFS is healthy (Last checked: {round(file_age/86400, 1)} days ago).")

            return True
        except Exception as e:
            print(f"{PREFIX} WARN: BTRFS maintenance plugin issue: {e}")
            return False


class XdgDirsPlugin(Plugin):
    def apply(self, store, dry_run=False, params=None) -> bool:
        try:
            if not dry_run:
                decman.sh(f"sudo -i -u {USER} bash -c 'xdg-user-dirs-update'", check=False)
                print(f"{PREFIX} SUMMARY: XDG user directories ensured.")
            else:
                print(f"  -> [DRY RUN] Would run: xdg-user-dirs-update as {USER}")

            return True
        except Exception as e:
            print(f"{PREFIX} ERROR: [xdg] {e}")
            return False
