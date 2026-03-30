#!/bin/bash

STATE_FILE="/tmp/hypr_float_mode"

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    hyprctl reload
    notify-send -t 2000 "Hyprland" "Auto-tiling enabled"
else
    touch "$STATE_FILE"
    hyprctl keyword windowrule "float on, match:class .*"
    notify-send -t 2000 "Hyprland" "Global floating enabled"
fi
