#!/bin/bash

# Configuration
bars_count=12
max_range=7
bar_chars="▁▂▃▄▅▆▇█"

# Create a temporary config for cava
config_file="/tmp/quickshell_cava_config"
echo "
[general]
bars = $bars_count

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = $max_range
" > "$config_file"

# Build transition dictionary for sed
# This is much faster than bash loops for high-frequency streaming
dict="s/;//g;"
for i in {0..7}; do
    dict="${dict}s/$i/${bar_chars:$i:1}/g;"
done

# Run cava and process output using sed for efficiency
cava -p "$config_file" | while read -r line; do
    echo "$line" | sed "$dict"
done
