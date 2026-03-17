#!/usr/bin/env bash

find -L /usr/share/applications /var/lib/flatpak/exports/share/applications ~/.local/share/applications -name "*.desktop" -type f 2>/dev/null -print0 | xargs -0 awk -F'=' '
BEGIN {
    # Match the Desktop Entry group specially
    in_entry = 0
}

# New file starts
FNR == 1 {
    if (name && exec) {
        # Process primary category
        split(cats, cat_arr, ";")
        pc = (cat_arr[1] == "" ? "Other" : cat_arr[1])
        
        # Clean up exec (remove %f, %u, etc)
        gsub(/ %[fFuUinkKvV]/, "", exec)
        gsub(/"/, "", exec)
        
        # Escape quotes for JSON
        gsub(/"/, "\\\"", name)
        gsub(/"/, "\\\"", exec)
        gsub(/"/, "\\\"", icon)
        gsub(/"/, "\\\"", pc)
        
        printf "{\"name\":\"%s\",\"exec\":\"%s\",\"icon\":\"%s\",\"category\":\"%s\"}\n", name, exec, icon, pc
    }
    
    # Reset for next file
    name = ""; exec = ""; icon = ""; cats = ""; in_entry = 0; skip = 0
}

# Ignore NoDisplay=true apps
/^NoDisplay=true/ { skip = 1 }

# Only parse within [Desktop Entry] section
/^\[Desktop Entry\]/ { in_entry = 1; next }
/^\[/ && !/^\[Desktop Entry\]/ { in_entry = 0 } # Other sections

in_entry && !skip {
    if ($1 == "Name" && !name) name = substr($0, length($1) + 2)
    else if ($1 == "Exec" && !exec) exec = substr($0, length($1) + 2)
    else if ($1 == "Icon" && !icon) icon = substr($0, length($1) + 2)
    else if ($1 == "Categories" && !cats) cats = substr($0, length($1) + 2)
}

END {
    # Print the last one
    if (name && exec && !skip) {
        split(cats, cat_arr, ";")
        pc = (cat_arr[1] == "" ? "Other" : cat_arr[1])
        gsub(/ %[fFuUinkKvV]/, "", exec)
        gsub(/"/, "", exec)
        gsub(/"/, "\\\"", name)
        gsub(/"/, "\\\"", exec)
        gsub(/"/, "\\\"", icon)
        gsub(/"/, "\\\"", pc)
        printf "{\"name\":\"%s\",\"exec\":\"%s\",\"icon\":\"%s\",\"category\":\"%s\"}\n", name, exec, icon, pc
    }
}
'
