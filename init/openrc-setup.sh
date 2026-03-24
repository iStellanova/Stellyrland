#!/bin/bash
# openrc-setup.sh - run once after decman sync

services=(
    bluetooth
    coolercontrold
    gpu-tune
    grub-btrfsd
    iwd
    NetworkManager
    sddm
)

for svc in "${services[@]}"; do
  rc-update add "$svc" default
done

# Timers → cron (add to /etc/cron.d/)
echo "0 0 1 * * root /usr/bin/btrfs scrub start /" >/etc/cron.d/btrfs-scrub
echo "0 3 * * * root paccache -r" >/etc/cron.d/paccache
echo "0 * * * * root /usr/bin/snapper -c root create --cleanup-type timeline" >/etc/cron.d/snapper-timeline
echo "0 4 * * * root /usr/bin/snapper -c root cleanup timeline" >/etc/cron.d/snapper-cleanup
echo "0 6 * * 1 root reflector --save /etc/pacman.d/mirrorlist --protocol https --latest 10 --sort rate" >/etc/cron.d/reflector
