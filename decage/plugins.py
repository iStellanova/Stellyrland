"""
decage.plugins — Base classes and built-in plugin implementations.

Provides the Plugin, File, and Directory abstractions used by source.py,
along with every concrete plugin for system management.

All subprocess invocations go through the shared ``_run()`` helper in
``decage.decage`` so dry-run / ANSI formatting stays consistent.
"""

from __future__ import annotations

import sys
# Disable bytecode generation (__pycache__)
sys.dont_write_bytecode = True

import hashlib
import grp
import os
import pwd
import shlex
import shutil
import subprocess
import time
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any


# ---------------------------------------------------------------------------
# Lazy import of decage internals — avoids circular imports at module level.
# These are resolved on first use inside apply() methods.
# ---------------------------------------------------------------------------

def _decage():
    """Return the decage.core module (lazy import)."""
    from decage import core as _mod
    return _mod


# ---------------------------------------------------------------------------
# Auto-detected user constants
# ---------------------------------------------------------------------------

def _detect_user() -> str:
    """Resolve the real (non-root) user, even under sudo."""
    return os.environ.get("SUDO_USER") or os.environ.get("USER") or "nobody"


def _detect_home(user: str) -> str:
    if user == "root":
        return "/root"
    return f"/home/{user}"


USER: str = _detect_user()
HOME: str = _detect_home(USER)


# ---------------------------------------------------------------------------
# Idempotency Helpers
# ---------------------------------------------------------------------------

def get_hash(path: Path) -> str:
    """Compute SHA256 hash of a file's content."""
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(8192):
            h.update(chunk)
    return h.hexdigest()


def get_uid(user_name: str | None) -> int:
    """Resolve username to UID. Defaults to 0 (root)."""
    if not user_name:
        return 0
    try:
        return pwd.getpwnam(user_name).pw_uid
    except KeyError:
        return 0


def get_gid(user_name: str | None) -> int:
    """Resolve username to their primary GID. Defaults to 0 (root)."""
    if not user_name:
        return 0
    try:
        return pwd.getpwnam(user_name).pw_gid
    except KeyError:
        return 0


# ═══════════════════════════════════════════════════════════════════════════
# Base classes
# ═══════════════════════════════════════════════════════════════════════════

class Plugin(ABC):
    """Abstract base for all decage pipeline plugins.

    Every plugin receives:
        store    — a mutable dict shared across the pipeline run
        dry_run  — when True, only print what *would* happen

    Must return True on success, False on failure.
    """

    @abstractmethod
    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        ...


# ---------------------------------------------------------------------------
# File / Directory descriptors
# ---------------------------------------------------------------------------

class File:
    """Describes a single file to deploy from the config repo to the system.

    Parameters
    ----------
    source_file : str
        Path relative to the directory containing ``source.py``.
    owner : str | None
        Username for ``chown``. Defaults to root when None.
    permissions : int
        Octal mode for ``chmod``. Defaults to 0o644.
    """

    def __init__(
        self,
        source_file: str,
        owner: str | None = None,
        permissions: int = 0o644,
    ) -> None:
        self.source_file = source_file
        self.owner = owner
        self.permissions = permissions

    def matches(self, src: Path, target: str) -> bool:
        """Check if target file matches source content and metadata."""
        tgt = Path(target)
        if not tgt.exists():
            return False

        # Metadata checks (fast)
        stat = tgt.stat()
        if stat.st_size != src.stat().st_size:
            return False
        if (stat.st_mode & 0o777) != self.permissions:
            return False
        if stat.st_uid != get_uid(self.owner):
            return False

        # Content check (slow)
        return get_hash(src) == get_hash(tgt)


class Directory:
    """Describes a directory tree to deploy from the config repo.

    Parameters
    ----------
    source_directory : str
        Path relative to the directory containing ``source.py``.
    owner : str | None
        Username for ``chown -R``. Defaults to root when None.
    permissions : int
        Octal mode for ``chmod`` on the top-level dir. Defaults to 0o755.
    """

    def __init__(
        self,
        source_directory: str,
        owner: str | None = None,
        permissions: int = 0o755,
    ) -> None:
        self.source_directory = source_directory
        self.owner = owner
        self.permissions = permissions

    def matches(self, src: Path, target: str) -> bool:
        """Check if target directory and all its recursive contents match the source."""
        tgt = Path(target)
        if not tgt.exists() or not tgt.is_dir():
            return False

        # Metadata check for the directory itself
        stat = tgt.stat()
        if (stat.st_mode & 0o777) != self.permissions:
            return False
        if stat.st_uid != get_uid(self.owner):
            return False

        # Recursive check of all source items
        for s_item in src.rglob("*"):
            rel = s_item.relative_to(src)
            t_item = tgt / rel

            if not t_item.exists():
                return False

            if s_item.is_dir():
                if not t_item.is_dir():
                    return False
                # Metadata check for subdirectories
                if t_item.stat().st_uid != get_uid(self.owner):
                    return False
            else:
                if not t_item.is_file():
                    return False
                # Content and metadata check for files
                if t_item.stat().st_size != s_item.stat().st_size:
                    return False
                if t_item.stat().st_uid != get_uid(self.owner):
                    return False
                if get_hash(s_item) != get_hash(t_item):
                    return False

        return True


# ═══════════════════════════════════════════════════════════════════════════
# Built-in: File & Directory deployment
# ═══════════════════════════════════════════════════════════════════════════

class FilePlugin(Plugin):
    """Deploy File and Directory objects declared in source.py."""

    def __init__(
        self,
        files: dict[str, File] | None = None,
        directories: dict[str, Directory] | None = None,
        source_root: Path | None = None,
    ) -> None:
        self.files = files or {}
        self.directories = directories or {}
        self.source_root = source_root  # set by decage at load time

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()
        ok = True
        changes = False

        if not self.files and not self.directories:
            d._ok("No files or directories declared.")
            return True

        root = self.source_root or Path.cwd()

        # --- Files ---
        for target, fobj in sorted(self.files.items()):
            src = (root / fobj.source_file).resolve()
            if not src.is_file():
                d._warn(f"Source file not found, skipping: {src}")
                ok = False
                continue

            if fobj.matches(src, target):
                continue

            changes = True
            if dry_run:
                d._info(f"Would deploy file: {src} → {target}")
            else:
                tgt = Path(target)
                tgt.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(str(src), str(tgt))
                os.chmod(str(tgt), fobj.permissions)
                if fobj.owner:
                    shutil.chown(str(tgt), user=fobj.owner)
                d._ok(f"Deployed: {target}")

        # --- Directories ---
        for target, dobj in sorted(self.directories.items()):
            src = (root / dobj.source_directory).resolve()
            if not src.is_dir():
                d._warn(f"Source directory not found, skipping: {src}")
                ok = False
                continue

            if dobj.matches(src, target):
                continue

            changes = True
            if dry_run:
                d._info(f"Would deploy directory: {src} → {target}")
            else:
                tgt = Path(target)
                tgt.mkdir(parents=True, exist_ok=True)
                shutil.copytree(str(src), str(tgt), dirs_exist_ok=True)
                os.chmod(str(tgt), dobj.permissions)
                if dobj.owner:
                    # Recursively chown
                    for dirpath, dirnames, filenames in os.walk(str(tgt)):
                        shutil.chown(dirpath, user=dobj.owner)
                        for fn in filenames:
                            shutil.chown(os.path.join(dirpath, fn), user=dobj.owner)
                d._ok(f"Deployed: {target}")

        if not changes and ok:
            d._ok("All declared files and directories are up-to-date.")

        return ok


# ═══════════════════════════════════════════════════════════════════════════
# Gentoo-specific plugins
# ═══════════════════════════════════════════════════════════════════════════

class RepositoryPlugin(Plugin):
    """Manage Gentoo overlays via ``eselect repository``.

    Enables missing overlays and syncs them.  Warns about unlisted overlays
    that are present on the system but takes no destructive action.
    """

    def __init__(self, repos: set[str]) -> None:
        self.repos = repos

    def _get_enabled_repos(self) -> set[str]:
        """Parse ``eselect repository list -i`` for currently enabled repos."""
        try:
            result = subprocess.run(
                ["eselect", "repository", "list", "-i"],
                capture_output=True, text=True, check=False,
            )
            enabled: set[str] = set()
            for line in result.stdout.splitlines():
                # Format:  "  [N]  repo-name  ..."
                line = line.strip()
                if not line or line.startswith("Available") or line.startswith("("):
                    continue
                # Typical: "  [1]   guru   ..."
                parts = line.split()
                if len(parts) >= 2:
                    # The repo name is the token after the [N] index.
                    for part in parts:
                        if part.startswith("[") and part.endswith("]"):
                            continue
                        if part.startswith("*"):
                            part = part.lstrip("*")
                        if part and not part.startswith("("):
                            enabled.add(part)
                            break
            return enabled
        except FileNotFoundError:
            return set()

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        enabled = self._get_enabled_repos()
        to_enable = self.repos - enabled
        unlisted = enabled - self.repos

        # Warn about unlisted overlays (don't touch them)
        # Exclude the default repos that are always present
        default_repos = {"gentoo", "gentoo-zh"}  # always-on repos
        for repo in sorted(unlisted - default_repos):
            d._warn(
                f"Overlay '{repo}' is enabled but not in your configuration. "
                f"Leaving it alone to prevent dependency breakage."
            )

        if not to_enable:
            d._ok("All declared overlays are enabled.")
            return True

        for repo in sorted(to_enable):
            if dry_run:
                d._info(f"Would enable overlay: {repo}")
                d._info(f"Would sync overlay:   {repo}")
            else:
                d._info(f"Enabling overlay: {repo}")
                rc = d._run(["eselect", "repository", "enable", repo])
                if rc != 0:
                    d._err(f"Failed to enable overlay '{repo}'.")
                    continue
                d._info(f"Syncing overlay: {repo}")
                d._run(["emaint", "sync", "-r", repo])
                d._ok(f"Overlay '{repo}' enabled and synced.")

        return True


class SyncPlugin(Plugin):
    """Sync the Portage tree and all overlays via ``emaint sync -A``.

    Throttled to run at most once every 2 days using a marker file.
    """

    _MARKER = "/var/cache/.decage_last_sync"
    _THROTTLE = 172800  # 2 days

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        if os.path.exists(self._MARKER):
            age = time.time() - os.path.getmtime(self._MARKER)
        else:
            age = self._THROTTLE + 1

        if age <= self._THROTTLE:
            d._ok(
                f"Repositories were synced recently "
                f"({round(age / 3600, 1)} hours ago). Skipping."
            )
            store["repos_synced"] = True
            return True

        d._info("Synchronizing Portage tree and all overlays …")
        rc = d._run(["emaint", "sync", "-A"], dry_run=dry_run)
        if rc != 0 and not dry_run:
            d._err(f"emaint sync exited with code {rc}.")
            return False

        if not dry_run:
            Path(self._MARKER).touch()
            d._ok("Portage tree synced.")

        store["repos_synced"] = True
        return True


class CacheCleanupPlugin(Plugin):
    """Clean old distfiles and binary packages via ``eclean``.

    Throttled to run at most once a week using a marker file.
    """

    _MARKER = "/var/cache/.decage_last_eclean"
    _WEEK = 604800

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        if os.path.exists(self._MARKER):
            age = time.time() - os.path.getmtime(self._MARKER)
        else:
            age = self._WEEK + 1

        if age <= self._WEEK:
            d._ok(
                f"Cache was cleaned recently "
                f"({round(age / 86400, 1)} days ago). Skipping."
            )
            return True

        d._info("Cleaning old distfiles and binary packages …")

        if dry_run:
            d._info("Would run: eclean-dist -d")
            d._info("Would run: eclean-pkg -d")
            return True

        d._run(["eclean-dist", "-d"])
        d._run(["eclean-pkg", "-d"])

        # Touch marker
        Path(self._MARKER).touch()
        d._ok("Cache cleanup completed.")
        return True


# ═══════════════════════════════════════════════════════════════════════════
# Distro-agnostic plugins (ported from Artix)
# ═══════════════════════════════════════════════════════════════════════════

class OpenRCPlugin(Plugin):
    """Declaratively manage OpenRC services.

    Input:  dict mapping service name → runlevel (e.g. ``{"sddm": "default"}``)
    Action: Enables missing services, disables unlisted ones (with a
            protected-set to avoid bricking the system).
    """

    _PROTECTED = frozenset({
        "udev", "dbus", "elogind", "local", "bootmisc",
        "hostname", "sysfs", "root", "devfs", "procfs",
        "mount-ro", "killprocs", "savecache", "swap",
        "fsck", "modules", "hwclock", "keymaps", "consolefont",
        "termencoding", "net.lo", "loopback",
    })

    def __init__(self, services: dict[str, str]) -> None:
        self.services = services

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        try:
            result = subprocess.run(
                ["rc-update", "show"],
                capture_output=True, text=True, check=False,
            )
            current_state: dict[str, set[str]] = {}
            for line in result.stdout.splitlines():
                if "|" in line:
                    parts = line.split("|")
                    svc = parts[0].strip()
                    runlevels = set(parts[1].strip().split())
                    current_state[svc] = runlevels

            to_enable = {
                s: r for s, r in self.services.items()
                if s not in current_state or r not in current_state[s]
            }

            # Find services in "default" that aren't in our declaration
            current_default = {
                svc for svc, rls in current_state.items() if "default" in rls
            }
            to_disable = current_default - set(self.services.keys())

            changes = False

            for service, runlevel in sorted(to_enable.items()):
                changes = True
                if dry_run:
                    d._info(f"Would enable service: {service} on {runlevel}")
                else:
                    d._info(f"Enabling service: {service} on {runlevel}")
                    d._run(["rc-update", "add", service, runlevel])

            for service in sorted(to_disable):
                if service in self._PROTECTED:
                    continue
                changes = True
                if dry_run:
                    d._info(f"Would disable unlisted service: {service}")
                else:
                    d._warn(f"Disabling unlisted service: {service}")
                    d._run(["rc-update", "del", service, "default"])

            if not changes:
                d._ok("All services are up-to-date.")

            return True
        except Exception as exc:
            d._err(f"OpenRC plugin failed: {exc}")
            return False


class GsettingsPlugin(Plugin):
    """Declaratively enforce GNOME/GTK settings via ``gsettings``.

    Input:  nested dict  ``{schema: {key: value, ...}, ...}``

    Handles DBUS session lookup so this works when run as root.
    """

    def __init__(self, settings: dict[str, dict[str, str]]) -> None:
        self.settings = settings

    def _get_user_dbus_address(self) -> str:
        """Attempt to find the DBUS_SESSION_BUS_ADDRESS for the real user."""
        try:
            result = subprocess.run(
                ["pgrep", "-u", USER, "-x",
                 "hyprland|quickshell|sway|dbus-daemon"],
                capture_output=True, text=True, check=False,
            )
            pids_raw = result.stdout.strip()

            if not pids_raw:
                result = subprocess.run(
                    ["pgrep", "-u", USER],
                    capture_output=True, text=True, check=False,
                )
                pids_raw = result.stdout.strip()

            if not pids_raw:
                return ""

            for pid in pids_raw.splitlines()[:10]:
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

    def _gs_cmd(self, prefix: str, action: str, schema: str,
                key: str, value: str = "") -> str:
        """Build a gsettings command string."""
        if value:
            # Wrap in quotes for the shell to ensure it reaches gsettings as one arg
            value = shlex.quote(value)
            return f"{prefix} gsettings {action} {schema} {key} {value}"
        return f"{prefix} gsettings {action} {schema} {key}"

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        if not self.settings:
            d._ok("No gsettings declared.")
            return True

        dbus_addr = self._get_user_dbus_address()
        if dbus_addr:
            prefix = f"sudo -u {USER} DBUS_SESSION_BUS_ADDRESS={dbus_addr}"
        else:
            prefix = f"sudo -u {USER} dbus-run-session"

        changes = False

        try:
            for schema, keys in self.settings.items():
                for key, desired in keys.items():
                    get_cmd = self._gs_cmd(prefix, "get", schema, key)
                    result = subprocess.run(
                        get_cmd, shell=True,
                        capture_output=True, text=True, check=False,
                    )
                    current = result.stdout.strip()

                    # Normalise: gsettings returns strings with quotes
                    normalized = desired
                    if (current.startswith("'") and current.endswith("'")
                            and not desired.startswith("'")):
                        normalized = f"'{desired}'"

                    if current == normalized:
                        continue

                    changes = True
                    if dry_run:
                        d._info(
                            f"Would set: {key} = {desired} "
                            f"(current: {current})"
                        )
                    else:
                        set_cmd = self._gs_cmd(prefix, "set", schema, key, normalized)
                        subprocess.run(set_cmd, shell=True, check=True)
                        d._ok(f"Applied: {key} = {desired}")

            if not changes:
                d._ok("GSettings are up-to-date.")
            return True

        except Exception as exc:
            d._err(f"GSettings plugin failed: {exc}")
            return False


class SnapperPlugin(Plugin):
    """Create a Btrfs pre-snapshot via Snapper before changes."""

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        cmd = [
            "snapper", "-c", "config", "create",
            "--type", "pre",
            "--print-number",
            "--description", "Decage Sync",
        ]

        if dry_run:
            d._info("Would create BTRFS snapshot.")
            d._run(cmd, dry_run=True)
            return True

        d._info("Creating BTRFS pre-snapshot …")
        rc = d._run(cmd)
        if rc != 0:
            d._warn(f"Snapper exited with code {rc} — continuing anyway.")
        else:
            d._ok("BTRFS snapshot created.")
        return True


class GrubPlugin(Plugin):
    """Regenerate GRUB configuration."""

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        cmd = ["grub-mkconfig", "-o", "/boot/grub/grub.cfg"]

        if dry_run:
            d._info("Would regenerate GRUB configuration.")
            d._run(cmd, dry_run=True)
            return True

        d._info("Generating GRUB configuration …")
        rc = d._run(cmd)
        if rc != 0:
            d._err(f"grub-mkconfig exited with code {rc}.")
            return False
        d._ok("GRUB configuration generated.")
        return True


class BtrfsMaintenancePlugin(Plugin):
    """Run periodic BTRFS balance and scrub.

    Throttled to at most once every 30 days via a marker file.
    """

    _MARKER = "/var/cache/.decage_btrfs_last_run"
    _MONTH = 2592000  # 30 days

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        if os.path.exists(self._MARKER):
            age = time.time() - os.path.getmtime(self._MARKER)
        else:
            age = self._MONTH + 1

        if age <= self._MONTH:
            d._ok(
                f"BTRFS is healthy "
                f"(last checked: {round(age / 86400, 1)} days ago)."
            )
            return True

        d._info("BTRFS maintenance is due …")

        if dry_run:
            d._info("Would run: btrfs balance start -dusage=30 /")
            d._info("Would run: btrfs scrub start /")
            return True

        d._run(["btrfs", "balance", "start", "-dusage=30", "/"])
        d._run(["btrfs", "scrub", "start", "/"])
        Path(self._MARKER).touch()
        d._ok("BTRFS balance finished and background scrub started.")
        return True


class XdgDirsPlugin(Plugin):
    """Ensure standard XDG user directories exist."""

    def apply(self, store: dict[str, Any], dry_run: bool = False) -> bool:
        d = _decage()

        # Check if user-dirs.dirs exists and if standard directories exist
        config_file = Path(HOME) / ".config" / "user-dirs.dirs"
        
        # Standard Gentoo/XDG dirs to check for existence
        std_dirs = [
            "Desktop", "Documents", "Downloads", "Music", 
            "Pictures", "Public", "Templates", "Videos"
        ]
        all_exist = all((Path(HOME) / dname).is_dir() for dname in std_dirs)

        if config_file.exists() and all_exist:
            d._ok("XDG user directories are up-to-date.")
            return True

        cmd = ["sudo", "-i", "-u", USER, "bash", "-c", "xdg-user-dirs-update"]

        if dry_run:
            d._info(f"Would run: xdg-user-dirs-update as {USER}")
            d._run(cmd, dry_run=True)
            return True

        d._info(f"Updating XDG user directories for {USER} …")
        d._run(cmd)
        d._ok("XDG user directories ensured.")
        return True
