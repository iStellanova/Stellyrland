#!/usr/bin/env bash

# CPU state
prev_total=0
prev_idle=0

get_cpu() {
  local line=$(grep 'cpu ' /proc/stat)
  local cpu_ticks=($line)
  
  # Standard /proc/stat line: cpu  user nice system idle iowait irq softirq steal guest guest_nice
  # Index 0 is "cpu", 1-10 are the values.
  
  local idle=${cpu_ticks[4]}
  local total=0
  for i in "${cpu_ticks[@]:1}"; do
    total=$((total + i))
  done
  
  if [ "$prev_total" -ne 0 ]; then
    local diff_idle=$((idle - prev_idle))
    local diff_total=$((total - prev_total))
    if [ "$diff_total" -eq 0 ]; then
      echo "0"
    else
      local usage=$((100 * (diff_total - diff_idle) / diff_total))
      echo "$usage"
    fi
  else
    echo "0"
  fi
  
  prev_total=$total
  prev_idle=$idle
}

get_ram_data() {
  # Returns: used_bytes total_bytes
  free -b | awk '/^Mem/ {print $3 " " $2}'
}

get_gpu() {
  if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n1
  elif [ -f /sys/class/drm/card0/device/gpu_busy_percent ]; then
    cat /sys/class/drm/card0/device/gpu_busy_percent | head -n1
  else
    echo 0
  fi
}

get_temp() {
  # Use the same path as original ShellData.qml
  if [ -f /sys/class/hwmon/hwmon5/temp1_input ]; then
    cat /sys/class/hwmon/hwmon5/temp1_input | awk '{print int($1/1000)}'
  else
    echo 0
  fi
}

# Initial sample for CPU
get_cpu > /dev/null

while true; do
  cpu=$(get_cpu)
  read ram_used ram_total < <(get_ram_data)
  gpu=$(get_gpu)
  temp=$(get_temp)
  
  # Calculate RAM percentage and GB
  if [ "$ram_total" -ne 0 ]; then
    ram_perc=$((100 * ram_used / ram_total))
    # Use awk for float division
    ram_gb=$(awk "BEGIN {printf \"%.2f\", $ram_used/1024/1024/1024}")
  else
    ram_perc=0
    ram_gb="0.00"
  fi
  
  echo "{\"cpu\": $cpu, \"ram_perc\": $ram_perc, \"ram_gb\": \"$ram_gb\", \"gpu\": $gpu, \"temp\": $temp}"
  
  sleep 5
done
