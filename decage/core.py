#!/usr/bin/env python3
"""
Decage — Declarative Portage

A command-line utility for managing Gentoo packages declaratively.
The desired world set is defined in a standard Python file (source.py),
and decage synchronizes the running system to match that declaration
using the native portage API for reads and the emerge binary for writes.

Usage:
    decage                          # Dry-run diff against the default source.py
    decage --apply                  # Apply changes (install + deselect)
    decage --apply --depclean       # Apply changes, then run depclean
    decage -s /path/to/source.py    # Use an alternate source file
    decage -n                       # Explicit dry-run (default behavior)

Dependencies: python 3.10+, portage (native Gentoo module), emerge
"""

from __future__ import annotations

import sys
from pathlib import Path

# Disable bytecode generation (__pycache__)
sys.dont_write_bytecode = True

# Ensure the parent of the 'decage' package is in sys.path for internal imports
_pkg_root = Path(__file__).resolve().parent.parent
if str(_pkg_root) not in sys.path:
    sys.path.insert(0, str(_pkg_root))

import argparse
import importlib.util
import os
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, NoReturn

# ---------------------------------------------------------------------------
# ANSI helpers — no external dependency needed
# ---------------------------------------------------------------------------

class _Color:
    """Namespace for ANSI escape sequences.  Respects NO_COLOR / TERM=dumb."""

    _enabled: bool = (
        sys.stdout.isatty()
        and os.environ.get("NO_COLOR") is None
        and os.environ.get("TERM") != "dumb"
    )

    RESET   = "\033[0m"   if _enabled else ""
    BOLD    = "\033[1m"    if _enabled else ""
    DIM     = "\033[2m"    if _enabled else ""

    RED     = "\033[1;31m" if _enabled else ""
    GREEN   = "\033[1;32m" if _enabled else ""
    YELLOW  = "\033[1;33m" if _enabled else ""
    BLUE    = "\033[1;34m" if _enabled else ""
    MAGENTA = "\033[1;35m" if _enabled else ""
    CYAN    = "\033[1;36m" if _enabled else ""
    WHITE   = "\033[1;37m" if _enabled else ""

C = _Color


# ---------------------------------------------------------------------------
# Pretty-printing helpers
# ---------------------------------------------------------------------------

_PREFIX = f"[{C.MAGENTA}DECAGE{C.RESET}]"


def _info(msg: str) -> None:
    print(f"{_PREFIX} {C.CYAN}INFO:{C.RESET}  {msg}")


def _ok(msg: str) -> None:
    print(f"{_PREFIX} {C.GREEN}  OK:{C.RESET}  {msg}")


def _warn(msg: str) -> None:
    print(f"{_PREFIX} {C.YELLOW}WARN:{C.RESET}  {msg}", file=sys.stderr)


def _err(msg: str) -> None:
    print(f"{_PREFIX} {C.RED} ERR:{C.RESET}  {msg}", file=sys.stderr)


def _fatal(msg: str, code: int = 1) -> NoReturn:
    _err(msg)
    sys.exit(code)


def _title(text: str) -> None:
    width = 54
    bar = "═" * width
    print(f"\n{C.BOLD}{C.BLUE}{bar}{C.RESET}")
    print(f"{C.BOLD}{C.BLUE}  {text}{C.RESET}")
    print(f"{C.BOLD}{C.BLUE}{bar}{C.RESET}")


def _section(text: str) -> None:
    _info(f"Running step {text}...")


def _atom_list(atoms: set[str], symbol: str, color: str) -> None:
    """Print a sorted list of atoms with a symbol prefix."""
    for atom in sorted(atoms):
        print(f"  {color}{symbol}{C.RESET} {atom}")


# ---------------------------------------------------------------------------
# Constants & Shared State
# ---------------------------------------------------------------------------

USER = os.environ.get("SUDO_USER") or os.environ.get("USER") or "root"
HOME = "/root" if USER == "root" else f"/home/{USER}"

@dataclass
class SourceConfig:
    """Container for the loaded source.py declaration."""
    packages: set[str] = field(default_factory=set)
    execution_order: list[str] = field(default_factory=lambda: ["portage"])
    plugins: dict[str, Any] = field(default_factory=dict)
    files: dict[str, Any] = field(default_factory=dict)
    directories: dict[str, Any] = field(default_factory=dict)
    source_path: Path | None = None


# ---------------------------------------------------------------------------
# Source loader
# ---------------------------------------------------------------------------

def load_source(path: Path) -> SourceConfig:
    """Dynamically import ``source.py`` and return a SourceConfig object."""
    if not path.is_file():
        _fatal(f"Source file not found: {path}")

    spec = importlib.util.spec_from_file_location("_decage_source", str(path))
    if spec is None or spec.loader is None:
        _fatal(f"Could not create module spec from: {path}")

    module = importlib.util.module_from_spec(spec)

    try:
        spec.loader.exec_module(module)
    except Exception as exc:
        _fatal(f"Failed to execute source file {path}: {exc}")

    # Extract PACKAGES
    packages_raw = getattr(module, "PACKAGES", set())
    if not isinstance(packages_raw, (list, tuple, set, frozenset)):
        _fatal(f"PACKAGES must be a list/set, got {type(packages_raw).__name__}")

    packages = {p.strip() for p in packages_raw if p.strip() and "/" in p}
    if not packages and packages_raw:
         _warn("PACKAGES contains no valid atoms (missing category?).")

    # Extract new modular variables
    execution_order = getattr(module, "execution_order", ["portage"])
    plugins = getattr(module, "plugins", {})
    files = getattr(module, "files", {})
    directories = getattr(module, "directories", {})

    return SourceConfig(
        packages=packages,
        execution_order=execution_order,
        plugins=plugins,
        files=files,
        directories=directories,
        source_path=path.parent
    )


# ---------------------------------------------------------------------------
# Portage interaction
# ---------------------------------------------------------------------------

def get_world_set() -> set[str]:
    """Return the current @selected (world) set via the portage API."""
    try:
        import portage
    except ImportError:
        _fatal("The 'portage' Python module is not available.")

    try:
        from portage._sets import load_default_config
        set_config = load_default_config(portage.settings, portage.db[portage.root])
        selected = set_config.getSets().get("selected")
        if selected:
            selected.load()
            return {str(a) for a in selected.getAtoms()}
    except Exception:
        pass

    # Fallback: raw world file
    world_path = Path(portage.settings["EROOT"]) / "var/lib/portage/world"
    if world_path.is_file():
        _warn("Falling back to direct world-file read.")
        return {l.strip() for l in world_path.read_text().splitlines() if l.strip() and not l.startswith("#")}

    _fatal("Unable to read the @selected (world) set.")


# ---------------------------------------------------------------------------
# Emerge execution
# ---------------------------------------------------------------------------

def _run(cmd: list[str], *, dry_run: bool = False) -> int:
    """Execute a command, printing it first. In dry-run mode, only print."""
    display = " ".join(cmd)
    if dry_run:
        print(f"  {C.DIM}$ {display}{C.RESET}  {C.YELLOW}(skipped — dry run){C.RESET}")
        return 0

    print(f"  {C.DIM}$ {display}{C.RESET}")
    result = subprocess.run(cmd)
    return result.returncode


def emerge_install(atoms: set[str], *, dry_run: bool = False) -> int:
    if not atoms: return 0
    return _run(["emerge", "--ask", "--noreplace"] + sorted(atoms), dry_run=dry_run)


def emerge_deselect(atoms: set[str], *, dry_run: bool = False) -> int:
    if not atoms: return 0
    return _run(["emerge", "--deselect"] + sorted(atoms), dry_run=dry_run)


def emerge_depclean(*, dry_run: bool = False) -> int:
    return _run(["emerge", "--ask", "y", "--depclean"], dry_run=dry_run)


# ---------------------------------------------------------------------------
# Privilege check
# ---------------------------------------------------------------------------

def require_root() -> None:
    if os.geteuid() != 0:
        _fatal("Root privileges are required to apply changes. Re-run with sudo.")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="decage",
        description="Declarative Portage — synchronize system to match source.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("-s", "--source", type=Path, default=None, help="Path to source.py")
    parser.add_argument("-n", "--dry-run", action="store_true", help="Show changes without executing.")
    parser.add_argument("-a", "--apply", action="store_true", help="Actually apply changes.")
    parser.add_argument("-d", "--depclean", action="store_true", help="Run emerge --depclean after applying.")
    return parser


def get_marker_path() -> Path:
    """Return the preferred path for the source persistence marker."""
    global_path = Path("/var/cache/.decage_source_path")
    user_path = Path(HOME) / ".cache" / "decage" / "last_source"
    
    # If we are root or have write access to /var/cache, use global
    if os.geteuid() == 0 or os.access("/var/cache", os.W_OK):
        return global_path
    
    # Otherwise fallback to user-local
    return user_path


def resolve_source_path(explicit: Path | None) -> tuple[Path, bool]:
    if explicit:
        return explicit.expanduser().resolve(), False
    
    # Check markers for last-used path (global then user)
    for p in [Path("/var/cache/.decage_source_path"), Path(HOME) / ".cache" / "decage" / "last_source"]:
        if p.is_file():
            try:
                last_path = Path(p.read_text().strip())
                if last_path.is_file():
                    return last_path, True
            except Exception:
                pass

    for p in [Path.cwd() / "source.py", Path("/etc/decage/source.py")]:
        if p.is_file(): return p.resolve(), False
    _fatal("No source file found. Specify with -s.")


# ---------------------------------------------------------------------------
# Main Pipeline
# ---------------------------------------------------------------------------

def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    dry_run = not args.apply

    _title("Decage — Declarative Portage")

    # 1. Load Source
    source_path, remembered = resolve_source_path(args.source)
    
    # Persist the source path for future runs
    try:
        marker = get_marker_path()
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text(str(source_path))
    except Exception:
        pass

    msg = f"Source file: {C.WHITE}{source_path}{C.RESET}"
    if remembered:
        msg += f" {C.DIM}(remembered){C.RESET}"
    _info(msg)

    config = load_source(source_path)
    _ok(f"Loaded {C.WHITE}{len(config.packages)}{C.RESET} desired atoms.")

    if not dry_run:
        require_root()

    # Shared plugin store
    store: dict[str, Any] = {}

    # 2. Execution Loop
    for step in config.execution_order:
        if step == "portage":
            _section("portage")
            current = get_world_set()
            to_install = config.packages - current
            to_remove = current - config.packages

            if not to_install and not to_remove:
                _ok("The @world set already matches the declaration.")
            else:
                if to_install:
                    _section(f"Atoms to install ({len(to_install)})")
                    _atom_list(to_install, "+", C.GREEN)
                if to_remove:
                    _section(f"Atoms to deselect ({len(to_remove)})")
                    _atom_list(to_remove, "−", C.RED)

                if not dry_run:
                    _section("Applying Portage Changes")
                    if to_install:
                        rc = emerge_install(to_install)
                        if rc != 0: _fatal(f"Emerge install failed: {rc}")
                    if to_remove:
                        rc = emerge_deselect(to_remove)
                        if rc != 0: _fatal(f"Deselect failed: {rc}")

        elif step == "files":
            _section("files")
            from decage.plugins import FilePlugin
            plugin = FilePlugin(config.files, config.directories, config.source_path)
            plugin.apply(store, dry_run=dry_run)

        elif step in config.plugins:
            _section(step)
            config.plugins[step].apply(store, dry_run=dry_run)
        else:
            _warn(f"Step '{step}' not found in plugins or built-ins. Skipping.")

    # 3. Final Depclean
    if args.depclean:
        _section("Dependency Cleanup")
        emerge_depclean(dry_run=dry_run)
    elif args.apply:
        print()
        _warn(f"Run {C.WHITE}emerge --depclean{C.RESET} manually or use {C.WHITE}-d{C.RESET} to clean orphans.")

    # 4. Cleanup any __pycache__ that may have slipped through (e.g. from the first import)
    try:
        decage_dir = Path(__file__).resolve().parent
        for pycache in decage_dir.rglob("__pycache__"):
            if pycache.is_dir():
                import shutil
                shutil.rmtree(str(pycache), ignore_errors=True)
    except Exception:
        pass

    print(f"\n{C.BOLD}{C.GREEN}Done ✓{C.RESET}")


if __name__ == "__main__":
    main()
