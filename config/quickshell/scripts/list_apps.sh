#!/bin/bash

# Find all .desktop files
find /usr/share/applications /var/lib/flatpak/exports/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | while read -r file; do
    # Extract fields using a single awk call
    eval "$(awk -F'=' '
        /^Name=/ && !name {print "name=\"" substr($0, 6) "\""; name=1}
        /^Exec=/ && !exec {print "exec=\"" substr($0, 6) "\""; exec=1}
        /^Icon=/ && !icon {print "icon=\"" substr($0, 6) "\""; icon=1}
        /^Categories=/ && !cats {print "categories=\"" substr($0, 12) "\""; cats=1}
        /^\[Desktop Action/ {exit} # Stop at first desktop action
    ' "$file")"

    # Skip if no Name or Exec
    [[ -z "$name" || -z "$exec" ]] && continue
    
    # Process fields
    exec=$(echo "$exec" | sed 's/ %[fFuU]//g' | sed 's/"//g')
    primary_category=$(echo "$categories" | cut -d';' -f1)
    [[ -z "$primary_category" ]] && primary_category="Other"
    
    # Escape quotes for JSON
    name=$(echo "$name" | sed 's/"/\\"/g')
    exec=$(echo "$exec" | sed 's/"/\\"/g')
    icon=$(echo "$icon" | sed 's/"/\\"/g')
    primary_category=$(echo "$primary_category" | sed 's/"/\\"/g')
    
    echo "{\"name\":\"$name\",\"exec\":\"$exec\",\"icon\":\"$icon\",\"category\":\"$primary_category\"}"
    
    # Reset variables for next iteration
    unset name exec icon categories primary_category
done
