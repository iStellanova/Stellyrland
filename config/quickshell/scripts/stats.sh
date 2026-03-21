#!/usr/bin/env bash

# CPU state (associative arrays for each core + total)
declare -A prev_total
declare -A prev_idle

# Configuration
INTERVAL="${1:-5}"
NET_INTERFACE="${NET_INTERFACE:-}"

# Initial sensor detection and path caching
GPU_CARD=""
GPU_TEMP_PATH=""
GPU_VRAM_USED_PATH=""
GPU_VRAM_TOTAL_PATH=""
CPU_TEMP_PATH=""
CPU_FREQ_PATH="/sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq"

# Detect GPU
if ! command -v nvidia-smi &> /dev/null; then
  max_vram=0
  for card in /sys/class/drm/card[0-9]*; do
    if [ -r "$card/device/gpu_busy_percent" ]; then
      current_vram=$(cat "$card/device/mem_info_vram_total" 2>/dev/null || echo 0)
      if [ "$current_vram" -gt "$max_vram" ]; then
        max_vram=$current_vram
        GPU_CARD="$card"
      fi
    fi
  done
  [ -z "$GPU_CARD" ] && [ -r /sys/class/drm/card0/device/gpu_busy_percent ] && GPU_CARD="/sys/class/drm/card0"
  
  if [ -n "$GPU_CARD" ]; then
    GPU_TEMP_PATH=$(ls "$GPU_CARD"/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
    GPU_VRAM_USED_PATH="$GPU_CARD/device/mem_info_vram_used"
    GPU_VRAM_TOTAL_PATH="$GPU_CARD/device/mem_info_vram_total"
  fi
fi

# Detect CPU Temperature sensor
for hwmon in /sys/class/hwmon/hwmon*; do
  if [ -f "$hwmon/name" ]; then
    name=$(cat "$hwmon/name")
    if [[ "$name" == "k10temp" || "$name" == "coretemp" ]]; then
      [ -f "$hwmon/temp1_input" ] && CPU_TEMP_PATH="$hwmon/temp1_input"
      break
    fi
  fi
done

get_cpu() {
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

  local cores_json=$(printf ", %s" "${core_usages[@]}")
  cores_json="[${cores_json:2}]"
  echo "\"cpu\": $total_usage, \"cpu_cores\": $cores_json"
}

get_cpu_speed() {
  local mhz=0
  mhz=$(awk '{sum+=$1; n++} END {if(n>0) print sum/n; else print 0}' /sys/devices/system/cpu/cpufreq/policy*/scaling_cur_freq 2>/dev/null)
  
  if [ "$mhz" = "0" ]; then
    mhz=$(awk '/cpu MHz/ {sum+=$4; count++} END {if (count>0) print sum/count; else print 0}' /proc/cpuinfo)
    # /proc/cpuinfo provides actual MHz, scaling_cur_freq provides kHz
    mhz=$((mhz * 1000))
  fi
  
  local ghz=$(awk "BEGIN {printf \"%.2f\", $mhz/1000000}")
  echo "\"cpu_speed\": \"$ghz GHz\""
}

get_ram_data() {
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
    # Convert MiB to Bytes for consistency if needed, but the GB calculation expects bytes
    vram_used=$((vram_used * 1024 * 1024))
    vram_total=$((vram_total * 1024 * 1024))
  elif [ -n "$GPU_CARD" ]; then
    [ -r "$GPU_CARD/device/gpu_busy_percent" ] && read -r usage < "$GPU_CARD/device/gpu_busy_percent"
    [ -n "$GPU_TEMP_PATH" ] && read -r raw_temp < "$GPU_TEMP_PATH" && temp=$((raw_temp / 1000))
    [ -r "$GPU_VRAM_USED_PATH" ] && read -r vram_used < "$GPU_VRAM_USED_PATH"
    [ -r "$GPU_VRAM_TOTAL_PATH" ] && read -r vram_total < "$GPU_VRAM_TOTAL_PATH"
  fi

  local vram_used_gb=$(awk "BEGIN {printf \"%.2f\", $vram_used/1024/1024/1024}")
  local vram_total_gb=$(awk "BEGIN {printf \"%.2f\", $vram_total/1024/1024/1024}")

  echo "\"gpu\": $usage, \"gpu_temp\": $temp, \"gpu_vram_used\": \"$vram_used_gb\", \"gpu_vram_total\": \"$vram_total_gb\""
}

get_temp() {
  if [ -n "$CPU_TEMP_PATH" ]; then
    read -r raw_temp < "$CPU_TEMP_PATH"
    echo $((raw_temp / 1000))
  else
    echo 0
  fi
}

get_net() {
  local interface="$NET_INTERFACE"
  if [ ! -d "/sys/class/net/$interface" ]; then
    interface=$(ls /sys/class/net | grep -vE 'lo|tun|br|docker|vbox|proton' | head -n1)
  fi
  [ -z "$interface" ] && echo "0 0" && return
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
  
  if [ "$ram_total" -ne 0 ]; then
    ram_perc=$((100 * ram_used / ram_total))
    ram_gb=$(awk "BEGIN {printf \"%.2f\", $ram_used/1024/1024/1024}")
    ram_avail_gb=$(awk "BEGIN {printf \"%.2f\", $ram_avail/1024/1024/1024}")
    ram_free_gb=$(awk "BEGIN {printf \"%.2f\", $ram_free/1024/1024/1024}")
    ram_cached_gb=$(awk "BEGIN {printf \"%.2f\", $ram_cached/1024/1024/1024}")
  else
    ram_perc=0; ram_gb="0.00"; ram_avail_gb="0.00"; ram_free_gb="0.00"; ram_cached_gb="0.00"
  fi

  rx_kbps=$(awk "BEGIN {printf \"%.1f\", ($rx_curr - $rx_prev) / $INTERVAL / 1024}")
  tx_kbps=$(awk "BEGIN {printf \"%.1f\", ($tx_curr - $tx_prev) / $INTERVAL / 1024}")
  
  echo "{$cpu_info, $cpu_speed, \"ram_perc\": $ram_perc, \"ram_gb\": \"$ram_gb\", \"ram_avail\": \"$ram_avail_gb\", \"ram_free\": \"$ram_free_gb\", \"ram_cached\": \"$ram_cached_gb\", $gpu_info, \"temp\": $temp, \"rx_kbps\": $rx_kbps, \"tx_kbps\": $tx_kbps}"
  
  rx_prev=$rx_curr
  tx_prev=$tx_curr
  sleep "$INTERVAL"
done
