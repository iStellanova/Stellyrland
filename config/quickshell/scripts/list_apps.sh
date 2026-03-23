#!/usr/bin/env bash

# Prioritize local applications over system ones (XDG standard)
find -L ~/.local/share/applications /var/lib/flatpak/exports/share/applications /usr/share/applications -name "*.desktop" -type f 2>/dev/null -print0 | xargs -0 awk -F'=' '
BEGIN {
    in_entry = 0
}

# New file starts
FNR == 1 {
    # Extract desktop filename to handle overrides
    n = split(FILENAME, path_parts, "/")
    fname = path_parts[n]
    
    # Process and print the previous completed app if it exists
    if (name && exec && !skip_app) {
        split(cats, cat_arr, ";")
        pc = (cat_arr[1] == "" ? "Other" : cat_arr[1])
        
        # Clean up exec (remove %f, %u, etc)
        gsub(/ %[fFuUinkKvV]/, "", exec)
        
        # Escape backslashes and quotes for JSON
        gsub(/\\/, "\\\\", name)
        gsub(/\\/, "\\\\", exec)
        gsub(/\\/, "\\\\", icon)
        gsub(/\\/, "\\\\", pc)
        gsub(/"/, "\\\"", name)
        gsub(/"/, "\\\"", exec)
        gsub(/"/, "\\\"", icon)
        gsub(/"/, "\\\"", pc)
        
        printf "{\"name\":\"%s\",\"exec\":\"%s\",\"icon\":\"%s\",\"category\":\"%s\"}\n", name, exec, icon, pc
    }
    
    # Check for duplicate desktop filename (first one wins due to find order)
    if (seen[fname]) {
        skip_file = 1
    } else {
        seen[fname] = 1
        skip_file = 0
    }
    
    # Reset for next file
    name = ""; exec = ""; icon = ""; cats = ""; in_entry = 0; skip_app = 0
}

# Ignore lines if we are skipping this duplicate file
skip_file { next }

# Ignore NoDisplay=true apps
/^NoDisplay=true/ { skip_app = 1 }

# Only parse within [Desktop Entry] section
/^\[Desktop Entry\]/ { in_entry = 1; next }
/^\[/ && !/^\[Desktop Entry\]/ { in_entry = 0 } # Other sections

in_entry && !skip_app {
    if ($1 == "Name" && !name) name = substr($0, length($1) + 2)
    else if ($1 == "Exec" && !exec) exec = substr($0, length($1) + 2)
    else if ($1 == "Icon" && !icon) {
        icon = substr($0, length($1) + 2)
        # Handle known icon mismatches
        if (icon == "roblox") icon = "org.vinegarhq.Sober"
    }
    else if ($1 == "Categories" && !cats) cats = substr($0, length($1) + 2)
}

END {
    # Print the last one
    if (name && exec && !skip_app) {
        split(cats, cat_arr, ";")
        pc = (cat_arr[1] == "" ? "Other" : cat_arr[1])
        gsub(/ %[fFuUinkKvV]/, "", exec)
        # Escape backslashes and quotes for JSON
        gsub(/\\/, "\\\\", name)
        gsub(/\\/, "\\\\", exec)
        gsub(/\\/, "\\\\", icon)
        gsub(/\\/, "\\\\", pc)
        gsub(/"/, "\\\"", name)
        gsub(/"/, "\\\"", exec)
        gsub(/"/, "\\\"", icon)
        gsub(/"/, "\\\"", pc)
        printf "{\"name\":\"%s\",\"exec\":\"%s\",\"icon\":\"%s\",\"category\":\"%s\"}\n", name, exec, icon, pc
    }
}
'

