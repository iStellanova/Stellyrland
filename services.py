# ==========================================
# OPENRC SERVICES
# ==========================================
openrc_services = {
    "agetty.tty1": "boot",          # TTY1 Console.
    "agetty.tty2": "boot",          # TTY2 Console.
    "agetty.tty3": "boot",          # TTY3 Console.
    "agetty.tty4": "boot",          # TTY4 Console.
    "agetty.tty5": "boot",          # TTY5 Console.
    "elogind": "boot",              # Login Manager.
    "dbus": "default",              # System Message Bus.
    "NetworkManager": "default",    # Network Connection.
    "netmount": "default",          # Network Mounts.
    "bluetoothd": "default",        # Bluetooth Daemon.
    "coolercontrold": "default",    # Hardware Control.
    "sddm": "default",              # Display Manager.
    "cronie": "default",            # Cron Jobs.
    "docker": "default",            # Docker Daemon.
    "libvirtd": "default",          # Virtualization.
    "local": "default",             # Local Startup.
    "zramen": "default",            # Zram Management.
    "lactd": "default",             # GPU Control.
}
