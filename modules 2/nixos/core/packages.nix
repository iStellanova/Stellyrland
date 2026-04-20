{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- CLI Utilities ---
    bat                      # A cat(1) clone with wings
    eza                      # A modern replacement for ‘ls’
    fd                       # A simple, fast and user-friendly alternative to 'find'
    fzf                      # A command-line fuzzy finder
    jq                       # A lightweight and flexible command-line JSON processor
    ripgrep                  # A line-oriented search tool that recursively searches directories
    tldr                     # Simplified and community-driven man pages
    tree                     # A recursive directory listing program that produces a depth indented listing of files
    wget                     # A free software package for retrieving content from web servers
    zoxide                   # A smarter cd command

    # --- Development ---
    git                      # Distributed version control system
    nix-output-monitor       # Pipe your nix-build to nom to get a better output
    python3Packages.uv       # An extremely fast Python package installer and resolver

    # --- System Management ---
    btrfs-assistant          # GUI manager for Btrfs and Snapper
    btrfs-progs              # Userspace utilities for the btrfs filesystem
    coolercontrol.coolercontrol-gui # GUI for viewing and controlling cooling devices
    efibootmgr               # A Linux user-space application to modify the Intel Extensible Firmware Interface (EFI) Boot Manager
    glib                     # Low-level core library that forms the basis for projects such as GNOME and GTK
    gnome-disk-utility       # A utility for managing disk drives and media
    ntfs3g                   # Open source implementation of NTFS
    snapper                  # Tool for Linux filesystem snapshots
    udiskie                  # Removable disk automounter for udisks
    usbutils                 # USB device counting and configuration tools

    # --- Desktop Environment / UI ---
    gdk-pixbuf               # A library for image loading and manipulation
    gnome-keyring            # A collection of components in GNOME that store secrets, passwords, keys, certificates
    gsettings-desktop-schemas # Shared GSettings schemas for the desktop, used by various projects
    gvfs                     # Userspace virtual filesystem
    hyprcursor               # The hyprland cursor format, library and utilities
    linux-wallpaperengine    # Wallpaper Engine for Linux
    mpvpaper                 # A video wallpaper program for Wayland
    hyprpicker               # A wlroots-compatible color picker
    hyprpolkitagent          # A simple polkit authentication agent for Hyprland
    hyprshot                 # Hyprland screenshot tool
    kdePackages.qtstyleplugin-kvantum # SVG-based theme engine for Qt5/Qt6
    libsForQt5.qtstyleplugin-kvantum # SVG-based theme engine for Qt5/Qt6 (Qt5 version)
    libsForQt5.qtwayland     # Wayland support for Qt5
    nwg-look                 # GTK3 settings editor adapted to work on wlroots-based compositors
    qt6.qt5compat            # Qt 6 module that contains the APIs that were removed from Qt 6
    qt6.qtmultimedia         # Qt 6 module for audio, video, radio and camera functionality
    qt6.qtwayland            # Wayland support for Qt6
    qt6Packages.qt6ct        # Qt6 Configuration Tool
    xauth                    # X.org authorization settings utility
    xdg-user-dirs            # Tool to help manage "well known" user directories
    xhost                    # Server access control program for X
    xwayland                 # X server for Wayland

    # --- Graphics & Multimedia ---
    cava                     # Console-based Audio Visualizer for Alsa
    davinci-resolve          # Professional video editing, color correction, visual effects and audio post-production
    ffmpeg                   # A complete, cross-platform solution to record, convert and stream audio and video
    ffmpegthumbnailer        # A lightweight video thumbnailer that can be used by file managers
    gst_all_1.gst-plugins-base # Base GStreamer plugins
    gst_all_1.gst-plugins-good # Good GStreamer plugins
    imv                      # A command line image viewer for Wayland and X11
    libva-utils              # A collection of tools and tests for VA-API
    losslesscut-bin          # Lossless video editing.
    mpv                      # A free, open source, and cross-platform media player
    mprisence                # Discord Rich Presence for MPRIS

    # --- Applications ---
    ani-cli                  # A cli tool to browse and watch anime
    blanket                  # Listen to different sounds to improve focus and increase your productivity
    fastfetch                # Like neofetch, but much faster because it's written in C
    flatpak                  # Linux application sandboxing and distribution framework
    gpu-screen-recorder-gtk  # GTK frontend for gpu-screen-recorder
    kitty                    # A modern, hackable, featureful, OpenGL based terminal emulator
    liquidctl                # Cross-platform CLI and Python drivers for AIO liquid coolers and other devices
    lollypop                 # A modern music player for GNOME
    nicotine-plus            # A graphical client for the Soulseek file sharing network
    obs-studio               # Free and open source software for video recording and live streaming
    parabolic                # A fast and simple video downloader for GNOME
    peaclock                 # A colorful clock, timer, and stopwatch for the terminal
    planify                  # Task manager with Todoist support designed for GNU/Linux
    prismlauncher            # A free, open source launcher for Minecraft
    proton-vpn               # Official Proton VPN Linux app
    heroic                   # Open-source launcher for Epic, GOG and Amazon Games
    protonup-qt              # Install and manage GE-Proton, Luxtorpeda & more for Steam and Lutris
    r2modman                 # A simple and easy to use mod manager for several games
    vesktop                  # Custom Discord desktop app
    zed-editor               # A high-performance, multiplayer code editor from the creators of Atom and Tree-sitter

    # --- File Management ---
    file-roller              # Archive manager for the GNOME desktop
    libnotify                # A library that sends desktop notifications to a notification daemon
    nautilus                 # Default file manager for the GNOME desktop
    sushi                    # A quick previewer for Nautilus

    # --- Monitoring ---
    btop                     # A monitor of resources
    resources                # Resource monitor.

    # --- Shell & Completions ---
    zsh-completions          # Additional completion definitions for Zsh

    # --- Utilities ---
    pavucontrol              # PulseAudio Volume Control
    xdg-utils                # Command line tools that assist applications with different desktop integration tasks

    # --- Custom / Git Builds ---
    (python3Packages.buildPythonApplication {
      pname = "terminal-rain-lightning";
      version = "0.1.0";
      src = fetchFromGitHub {
        owner = "rmaake1";
        repo = "terminal-rain-lightning";
        rev = "master";
        sha256 = "1r4ccxnrww1wn35sis6qmqlkn70735izhii0n3i55nfz8xs2l4w2";
      };
      pyproject = true;
      nativeBuildInputs = [ python3Packages.setuptools python3Packages.wheel ];
    })
  ];
}
