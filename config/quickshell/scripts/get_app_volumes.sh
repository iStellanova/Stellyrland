#!/bin/bash

# Fetch sink-inputs in JSON format
# prioritizing pactl if it works, falling back to pw-dump/wpctl for better Pipewire compatibility.

if command -v pactl >/dev/null && pactl info >/dev/null 2>&1; then
    # Some versions of pactl don't have --format=json
    if pactl --format=json list sink-inputs >/dev/null 2>&1; then
        pactl --format=json list sink-inputs | jq -c '[.[] | {
            id: .index,
            name: (.properties["application.name"] // .properties["media.name"] // "Unknown"),
            icon: (.properties["application.icon-name"] // "audio-x-generic"),
            volume: (.volume["front-left"].value_percent | tostring | sub("%"; "") | tonumber),
            muted: .mute
        }]' 2>/dev/null && exit 0
    fi
fi

# Fallback for systems where pactl is missing or not working with Pipewire
# Use pw-dump to find the streams and wpctl for volume (most robust on modern Pipewire)
DUMP=$(pw-dump 2>/dev/null)
if [ -z "$DUMP" ]; then
    echo "[]"
    exit 0
fi

echo "$DUMP" | jq -c '
  [.[] | select(.type == "PipeWire:Interface:Node" and .info.props["media.class"] == "Stream/Output/Audio" and .info.props["application.name"] != "cava") | {
    id: .id,
    pid: (.info.props["application.process.id"] // ""),
    name: (.info.props["application.name"] // .info.props["node.name"] // .info.props["media.name"] // "Unknown"),
    icon: (.info.props["application.icon-name"] // "")
  }]
' | jq -c '.[]' | while read -r item; do
    id=$(echo "$item" | jq -r .id)
    pid=$(echo "$item" | jq -r .pid)
    name=$(echo "$item" | jq -r .name)
    icon=$(echo "$item" | jq -r .icon)
    
    if [ "$icon" == "null" ]; then
        icon=""
    fi

    # Try to resolve true binary name for Electron apps (e.g. Vesktop instead of Chromium)
    if [ -n "$pid" ]; then
        real_name=$(ps -p "$pid" -o comm= 2>/dev/null)
        if [ -n "$real_name" ] && [ "$real_name" != "chromium" ] && [ "$name" == "Chromium" ]; then
            name="$real_name"
            # Capitalize first letter
            name="$(tr '[:lower:]' '[:upper:]' <<< ${name:0:1})${name:1}"
            if [ "$icon" == "chromium-browser" ] || [ -z "$icon" ]; then
                 icon=$(echo "$real_name" | tr '[:upper:]' '[:lower:]')
            fi
        fi
    fi

    # Fallback for Zen browser
    if [ "$name" == "Zen" ] && [ -z "$icon" ]; then
        icon="zen-browser"
    fi

    # Get volume from wpctl (it is fast for a single ID)
    vol_info=$(wpctl get-volume "$id" 2>/dev/null)
    if [ $? -eq 0 ]; then
        # wpctl output format: Volume: 0.64 [MUTED]
        volume=$(echo "$vol_info" | awk '{print $2 * 100}' | cut -d. -f1)
        muted="false"
        [[ "$vol_info" == *"[MUTED]"* ]] && muted="true"
        # Overwrite item with correct name and icon
        echo "$item" | jq -c ". + {\"volume\": $volume, \"muted\": $muted, \"name\": \"$name\", \"icon\": \"$icon\"}"
    else
        # Fallback values if wpctl fails
        echo "$item" | jq -c ". + {\"volume\": 100, \"muted\": false, \"name\": \"$name\", \"icon\": \"$icon\"}"
    fi
done | jq -s '.'
