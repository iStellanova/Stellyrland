pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var settings: ({})
    property bool _shouldReload: false

    FileView {
        id: configFile
        path: Quickshell.shellDir + "/config.json"
        watchChanges: true
        onFileChanged: {
            this.reload()
            reloadTimer.restart()
        }
        onLoadedChanged: {
            if (loaded) root.parseConfig()
        }
    }



    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: root.parseConfig()
    }

    function parseConfig() {
        try {
            let raw = configFile.text()
            if (raw && raw.length > 0) {
                root.settings = JSON.parse(raw)
            }
        } catch (e) {
            console.warn("Failed to parse config.json: " + e)
        }
    }

    function save(newSettings, reloadAtEnd = false) {
        try {
            _shouldReload = reloadAtEnd
            let content = JSON.stringify(newSettings, null, 4)
            configFile.setText(content)
            root.settings = newSettings // Optimistic update
            
            if (_shouldReload) {
                _shouldReload = false
                Quickshell.reload(false)
            }
        } catch (e) {
            console.error("Failed to save config.json: " + e)
        }
    }

    Component.onCompleted: root.parseConfig()

    function get(section, key, fallback) {
        return (settings[section] ?? {})[key] ?? fallback
    }

    // --- Wallpaper ---
    readonly property string wallpaperStartup: get("wallpaper", "startup_mode", "random")
    readonly property int wallpaperRotateMinutes: get("wallpaper", "rotation_interval_minutes", 30)
    readonly property string wallpaperDir: get("wallpaper", "directory", Quickshell.env("HOME") + "/Pictures/wallpapers")

    // --- Network ---
    readonly property string netInterface: get("network", "interface", "")

    // --- VPN ---
    readonly property string vpnInterface: get("vpn", "interface", "proton0")
    readonly property string vpnConnectCmd: get("vpn", "connect_command", "protonvpn connect")
    readonly property string vpnDisconnectCmd: get("vpn", "disconnect_command", "protonvpn disconnect")

    // --- Notifications ---
    readonly property int notifMaxHistory: get("notifications", "max_history", 20)
    readonly property int notifToastLimit: get("notifications", "toast_limit", 5)
    readonly property bool notifShowTimer: get("notifications", "show_timer", true)

    // --- Weather ---
    readonly property real weatherLat: get("weather", "latitude", 0.0)
    readonly property real weatherLon: get("weather", "longitude", 0.0)
    readonly property bool weatherCelsius: get("weather", "celsius", false)
    readonly property bool weatherHour24: get("weather", "hour24", false)
    readonly property int pollWeather: get("weather", "polling_interval_ms", 900000)

    // --- Polling ---
    readonly property int pollUpdates: get("polling", "updates_interval_ms", 3600000)
    readonly property int pollUptime: get("polling", "uptime_interval_ms", 60000)
    readonly property int pollIdle: get("polling", "idle_check_interval_ms", 2000)
    readonly property int pollStats: get("polling", "stats_interval_s", 5)

    // --- Shell ---
    readonly property string lockCmd: get("shell", "lock_command", "hyprlock")
    readonly property string shellAvatar: get("shell", "avatar_path", "face.png")
    readonly property string shellFont: get("shell", "font_family", "JetBrains Mono Nerd Font Propo")

    // --- Animations ---
    readonly property int animFast: get("animation", "fast", 100)
    readonly property int animNormal: get("animation", "normal", 150)
    readonly property int animSlow: get("animation", "slow", 250)
    readonly property int animExtraSlow: get("animation", "extra_slow", 500)

    // --- Colors ---
    readonly property bool useHardcodedColors: get("colors", "use_hardcoded", false)
    readonly property var hardcodedColors: get("colors", "hardcoded", {})
}
