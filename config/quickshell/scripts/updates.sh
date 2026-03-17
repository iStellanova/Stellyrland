#!/usr/bin/env bash

p_count=$(checkupdates 2>/dev/null | wc -l)
a_count=$(yay -Qua 2>/dev/null | wc -l)

echo "$p_count $a_count"
