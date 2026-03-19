#!/usr/bin/env bash

# CPU state (associative arrays for each core + total)
declare -A prev_total
declare -A prev_idle

get_cpu() {
  local core_counts=0
  local core_usages=()
  local total_usage=0

  while read -r line; do
    [[ $line =~ ^cpu[0-9]* ]] || continue
    
    local cpu_ticks=($line)
    local name=${cpu_ticks[0]}
    local idle=${cpu_ticks[4]}
    local total=0
    for i in "${cpu_ticks[@]:1}"; do
      total=$((total + i))
    done
    
    if [[ -n "${prev_total[$name]}" && "${prev_total[$name]}" -ne 0 ]]; then
      local diff_idle=$((idle - prev_idle[$name]))
      local diff_total=$((total - prev_total[$name]))
      if [ "$diff_total" -eq 0 ]; then
        usage=0
      else
        usage=$((100 * (diff_total - diff_idle) / diff_total))
      fi
    else
      usage=0
    fi

    if [[ "$name" == "cpu" ]]; then
      total_usage=$usage
    else
      core_usages+=("$usage")
    fi

    prev_total[$name]=$total
    prev_idle[$name]=$idle
  done < /proc/stat

  # Format core_usages as JSON array
  local cores_json=$(printf ", %s" "${core_usages[@]}")
  cores_json="[${cores_json:2}]"
  
  echo "\"cpu\": $total_usage, \"cpu_cores\": $cores_json"
}

get_cpu_speed() {
  local mhz=$(awk '/cpu MHz/ {sum+=$4; count++} END {print sum/count}' /proc/cpuinfo)
  local ghz=$(awk "BEGIN {printf \"%.2f\", $mhz/1000}")
  echo "\"cpu_speed\": \"$ghz GHz\""
}

get_ram_data() {
  # Returns: used_bytes total_bytes available_bytes free_bytes cached_bytes
  # free -b columns: total used free shared buff/cache available
  # Note: buff/cache is $6, available is $7
  free -b | awk '/^Mem/ {print $3 " " $2 " " $7 " " $4 " " $6}'
}

get_gpu_info() {
  local usage=0
  local temp=0
  local vram_used=0
  local vram_total=0

  if command -v nvidia-smi &> /dev/null; then
    local data=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits | head -n1)
    IFS=', ' read -r usage temp vram_used vram_total <<< "$data"
  else
    # Fallback to sysfs (AMD/Intel)
    if [ -r /sys/class/drm/card1/device/gpu_busy_percent ]; then
      read -r usage < /sys/class/drm/card1/device/gpu_busy_percent
    fi
    
    # Temperature
    local temp_path=$(ls /sys/class/drm/card1/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
    if [ -n "$temp_path" ]; then
      read -r raw_temp < "$temp_path"
      temp=$((raw_temp / 1000))
    fi

    # VRAM
    if [ -r /sys/class/drm/card1/device/mem_info_vram_used ]; then
      read -r vram_used < /sys/class/drm/card1/device/mem_info_vram_used
      read -r vram_total < /sys/class/drm/card1/device/mem_info_vram_total
      # Convert bytes to MiB for consistency with nvidia-smi if possible, or just GiB later
    fi
  fi

  local vram_used_gb=$(awk "BEGIN {printf \"%.2f\", $vram_used/1024/1024/1024}")
  local vram_total_gb=$(awk "BEGIN {printf \"%.2f\", $vram_total/1024/1024/1024}")

  echo "\"gpu\": $usage, \"gpu_temp\": $temp, \"gpu_vram_used\": \"$vram_used_gb\", \"gpu_vram_total\": \"$vram_total_gb\""
}

get_temp() {
  if [ -f /sys/class/hwmon/hwmon5/temp1_input ]; then
    cat /sys/class/hwmon/hwmon5/temp1_input | awk '{print int($1/1000)}'
  else
    echo 0
  fi
}

get_net() {
  local interface="wlan0"
  if [ ! -d "/sys/class/net/$interface" ]; then
    interface=$(ls /sys/class/net | grep -vE 'lo|tun|br|docker|vbox|proton' | head -n1)
  fi
  if [ -z "$interface" ]; then
    echo "0 0"
    return
  fi
  awk "\$1 ~ \"$interface\" {print \$2 \" \" \$10}" /proc/net/dev
}

# Initial sample
get_cpu > /dev/null
read -r rx_prev tx_prev < <(get_net)

while true; do
  cpu_info=$(get_cpu)
  cpu_speed=$(get_cpu_speed)
  read -r ram_used ram_total ram_avail ram_free ram_cached < <(get_ram_data)
  gpu_info=$(get_gpu_info)
  temp=$(get_temp)
  read -r rx_curr tx_curr < <(get_net)
  
  # RAM Formatting
  if [ "$ram_total" -ne 0 ]; then
    ram_perc=$((100 * ram_used / ram_total))
    ram_gb=$(awk "BEGIN {printf \"%.2f\", $ram_used/1024/1024/1024}")
    ram_avail_gb=$(awk "BEGIN {printf \"%.2f\", $ram_avail/1024/1024/1024}")
    ram_free_gb=$(awk "BEGIN {printf \"%.2f\", $ram_free/1024/1024/1024}")
    ram_cached_gb=$(awk "BEGIN {printf \"%.2f\", $ram_cached/1024/1024/1024}")
  else
    ram_perc=0
    ram_gb="0.00"
    ram_avail_gb="0.00"
    ram_free_gb="0.00"
    ram_cached_gb="0.00"
  fi

  # Network Rates
  rx_kbps=$(awk "BEGIN {printf \"%.1f\", ($rx_curr - $rx_prev) / 5 / 1024}")
  tx_kbps=$(awk "BEGIN {printf \"%.1f\", ($tx_curr - $tx_prev) / 5 / 1024}")
  
  echo "{$cpu_info, $cpu_speed, \"ram_perc\": $ram_perc, \"ram_gb\": \"$ram_gb\", \"ram_avail\": \"$ram_avail_gb\", \"ram_free\": \"$ram_free_gb\", \"ram_cached\": \"$ram_cached_gb\", $gpu_info, \"temp\": $temp, \"rx_kbps\": $rx_kbps, \"tx_kbps\": $tx_kbps}"
  
  rx_prev=$rx_curr
  tx_prev=$tx_curr
  sleep 5
done
