#!/bin/bash
export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
# switchwall.sh — Simplified theme extractor for unified QML background.
# Usage: switchwall.sh <path>

WALLPAPER="$1"
FRAME="/tmp/wall_frame.png"
LOGFILE="/tmp/switchwall.log"

# Clear log for each run
echo "--- $(date) ---" > "$LOGFILE"

is_video() {
    local ext="${1##*.}"
    ext="${ext,,}" # lowercase
    [[ "$ext" =~ ^(mp4|mkv|webm|mov|avi|flv)$ ]]
}

extract_frame() {
    local video="$1"
    echo "Extracting frame from $video" >> "$LOGFILE"
    ffmpeg -y -i "$video" -ss 00:00:01 -vframes 1 "$FRAME" >> "$LOGFILE" 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract frame from $video" >> "$LOGFILE"
        return 1
    fi
}

apply_theme() {
    local image="$1"
    echo "Applying theme for $image" >> "$LOGFILE"

    # Run matugen with fallback color and capture output
    # Added --continue-on-error to handle read-only files gracefully
    if ! matugen image "$image" \
        --mode dark \
        --source-color-index 0 \
        --continue-on-error \
        --fallback-color "#35415c" >> "$LOGFILE" 2>&1; then
        echo "Matugen encountered an error but --continue-on-error was used." >> "$LOGFILE"
    fi

    # Using pkill/hyprctl from PATH
    hyprctl reload >> "$LOGFILE" 2>&1
    
    # Reload cava to pick up new colors (pkill instead of killall)
    pkill -USR1 cava >> "$LOGFILE" 2>&1 || echo "Cava not running" >> "$LOGFILE"
    
    for sock in /tmp/kitty*; do 
        if [[ -S "$sock" ]]; then
            echo "Updating kitty at $sock" >> "$LOGFILE"
            kitty @ --to "unix:$sock" set-colors -a "/home/stellanova/.config/kitty/current-theme.conf" >> "$LOGFILE" 2>&1
        fi
    done
}

# --- Main ---
CACHE_DIR="$HOME/.cache/quickshell/wallpapers"
mkdir -p "$CACHE_DIR"

if [[ "$1" == "--all" ]]; then
    shift
    DIR="${1:-$HOME/Pictures/wallpapers}"
    find "$DIR" -maxdepth 1 -type f | while read -r vid; do
        if is_video "$vid"; then
            NAME=$(basename "$vid")
            OUT="$CACHE_DIR/${NAME}.png"
            if [[ ! -f "$OUT" ]]; then
                ffmpeg -y -i "$vid" -ss 00:00:01 -vframes 1 "$OUT" >/dev/null 2>&1 &
            fi
        fi
    done
    exit 0
fi

if [[ -z "$WALLPAPER" ]]; then
    echo "Usage: switchwall.sh <path>" | tee -a "$LOGFILE"
    exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
    echo "File not found: $WALLPAPER" | tee -a "$LOGFILE"
    exit 1
fi

# Kill previous instances to avoid races
# We use pgrep to find other instances of this script
for pid in $(pgrep -f "bash.*switchwall.sh"); do
    if [[ $pid != $$ ]]; then
        echo "Killing previous instance $pid" >> "$LOGFILE"
        kill $pid 2>/dev/null
    fi
done
# Kill any stale matugen processes
pkill -x matugen 2>/dev/null || true

# Deterministic frame path
NAME=$(basename "$WALLPAPER")
FRAME="$CACHE_DIR/${NAME}.png"


if is_video "$WALLPAPER"; then
    if [[ ! -f "$FRAME" ]]; then
        extract_frame "$WALLPAPER"
    fi
    apply_theme "$FRAME"
else
    apply_theme "$WALLPAPER"
fi
