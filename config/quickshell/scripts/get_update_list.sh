#!/usr/bin/env bash

# Fetch Pacman updates
p_list=$(checkupdates 2>/dev/null)
p_count=$(echo "$p_list" | ( [ -z "$p_list" ] && echo 0 || wc -l ) )

# Fetch AUR updates
a_list=$(yay -Qua 2>/dev/null)
a_count=$(echo "$a_list" | ( [ -z "$a_list" ] && echo 0 || wc -l ) )

# Output counts first
echo "counts|$p_count|$a_count"

# Output detail list using a single awk call for efficiency
if [ "$p_count" -gt 0 ]; then
    echo "$p_list" | awk '{print "pacman|" $1 "|" $2 "|" $4}'
fi

if [ "$a_count" -gt 0 ]; then
    echo "$a_list" | awk '{print "aur|" $1 "|" $2 "|" $4}'
fi
