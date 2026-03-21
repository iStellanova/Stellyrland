#!/bin/bash
# switchwall.sh — Simplified theme extractor for unified QML background.
# Usage: switchwall.sh <path>

WALLPAPER="$1"
FRAME="/tmp/wall_frame.png"

is_video() {
    local ext="${1##*.}"
    ext="${ext,,}" # lowercase
    [[ "$ext" =~ ^(mp4|mkv|webm|mov|avi|flv)$ ]]
}

extract_frame() {
    local video="$1"
    ffmpeg -y -i "$video" -ss 00:00:01 -vframes 1 "$FRAME" >/dev/null 2>&1
}

apply_theme() {
    local image="$1"
    matugen image "$image" --source-color-index 0 --mode dark >/dev/null 2>&1
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
    echo "Usage: switchwall.sh <path>"
    exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
    echo "File not found: $WALLPAPER"
    exit 1
fi

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
