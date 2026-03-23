#!/sbin/openrc-run

description="CoolerControl cooling device daemon"
command="/usr/bin/coolercontrold"
command_background=true
pidfile="/run/coolercontrold.pid"

depend() {
    need localmount
    after udev
}