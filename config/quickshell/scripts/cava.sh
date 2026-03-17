#!/bin/bash

# Configuration
bars_count=12
max_range=7

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

# Run cava directly (data_format = ascii outputs semicolon-separated numbers)
cava -p "$config_file"
