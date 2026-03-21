#!/bin/bash

# Fetch known apps for icon mapping (fast)
# Using associative array for O(1) lookups in the loop
declare -A APP_ICONS
while IFS=$'\t' read -r name icon; do
    [ -z "$name" ] || APP_ICONS["$(echo "$name" | tr '[:upper:]' '[:lower:]')"]="$icon"
done < <(bash "$(dirname "$0")/list_apps.sh" 2>/dev/null | jq -r '[.name, .icon] | @tsv')

fetch_data() {
    # Try pactl first (fast and reliable for pulse/pipewire-pulse)
    if command -v pactl >/dev/null && pactl info >/dev/null 2>&1; then
        pactl --format=json list sink-inputs 2>/dev/null | jq -c '.[] | {
            id: .index,
            pid: (.properties["application.process.id"] // ""),
            name: (.properties["application.name"] // .properties["media.name"] // "Unknown"),
            icon: (.properties["application.icon-name"] // ""),
            volume: (.volume["front-left"].value_percent | tostring | sub("%"; "") | tonumber),
            muted: .mute
        }' && return 0
    fi

    # Fallback to pw-dump for pure Pipewire setups
    DUMP=$(pw-dump 2>/dev/null)
    if [ -n "$DUMP" ]; then
        echo "$DUMP" | jq -c '
          .[] | select(.type == "PipeWire:Interface:Node" and .info.props["media.class"] == "Stream/Output/Audio" and .info.props["application.name"] != "cava") | {
            id: .id,
            pid: (.info.props["application.process.id"] // ""),
            name: (.info.props["application.name"] // .info.props["node.name"] // .info.props["media.name"] // "Unknown"),
            icon: (.info.props["application.icon-name"] // "")
          }
        '
        return 0
    fi
    return 1
}

# Process each stream and resolve icons/volumes efficiently
fetch_data | while read -r item; do
    # Extract all relevant fields safely in one jq call
    eval "$(echo "$item" | jq -r '@sh "id=\(.id); pid=\(.pid // ""); name=\(.name); icon=\(.icon // ""); volume=\(.volume // ""); muted=\(.muted // "")"')"
    
    # Cleanup icon and muted status
    [ "$icon" == "null" ] || [ "$icon" == "audio-x-generic" ] && icon=""

    # Resolve true binary name for Electron apps
    if [ -n "$pid" ] && [ "$name" == "Chromium" ]; then
        real_name=$(ps -p "$pid" -o comm= 2>/dev/null)
        if [ -n "$real_name" ] && [ "$real_name" != "chromium" ]; then
            name="$real_name"
            # Refresh name case for search
            name="$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}"
        fi
    fi

    # Robust Icon Resolution using cached desktop file data
    if [ -z "$icon" ]; then
        lookup_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        icon="${APP_ICONS[$lookup_name]}"
    fi

    # Specific fallbacks for common apps not in desktop files or needing overrides
    if [ -z "$icon" ]; then
        case "$name" in
            "Zen") icon="zen-browser" ;;
            "Spotify") icon="spotify-client" ;;
            "Firefox"*) icon="firefox" ;;
            "LibreWolf"*) icon="librewolf" ;;
        esac
    fi

    # Fetch volume via wpctl if not provided (for pw-dump path)
    if [ -z "$volume" ] || [ "$volume" == "null" ]; then
        vol_info=$(wpctl get-volume "$id" 2>/dev/null)
        if [ $? -eq 0 ]; then
            # wpctl output: Volume: 0.64 [MUTED]
            volume=$(echo "$vol_info" | awk '{print $2 * 100}' | cut -d. -f1)
            [[ "$vol_info" == *"[MUTED]"* ]] && muted="true" || muted="false"
        else
            volume=100; muted="false"
        fi
    fi
    
    # Ensure volume and muted are valid JSON values
    [ -z "$volume" ] || [ "$volume" == "null" ] && volume="0"
    [ -z "$muted" ] || [ "$muted" == "null" ] && muted="false"

    # Output final JSON with correct types
    jq -n -c --argjson id "$id" --arg name "$name" --arg icon "$icon" \
          --argjson volume "$volume" --argjson muted "$muted" \
          '{$id, $name, $icon, $volume, $muted}'
done | jq -s '.'
