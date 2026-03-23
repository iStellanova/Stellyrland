#!/bin/bash
# GPU tuning script - RX 7900 XTX (0000:03:00.0)

CARD="/sys/class/drm/card1/device"
HWMON="$CARD/hwmon/$(ls $CARD/hwmon | head -1)"

echo "high" > "$CARD/power_dpm_force_performance_level"
echo "402000000" > "$HWMON/power1_cap"
echo "s 0 2900" > "$CARD/pp_od_clk_voltage"
echo "m 1 1357" > "$CARD/pp_od_clk_voltage"
echo "vo -30"   > "$CARD/pp_od_clk_voltage"
echo "c"        > "$CARD/pp_od_clk_voltage"