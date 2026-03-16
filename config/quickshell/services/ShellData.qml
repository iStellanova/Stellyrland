pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    // ── System stats (polled via /proc reads) ────────────────
    property int cpuUsage: 0
    property var cpuHistory: []
    property string ramUsage: "0GiB"
    property int ramPerc: 0
    property var ramHistory: []
    property int gpuUsage: 0
    property var tempHistory: []

    // ── Network ──────────────────────────────────────────────
    property string netSsid: "Offline"

    // ── Toggle states ────────────────────────────────────────
    property bool wifiOn: false
    property bool btOn: false
    property bool dndOn: NotificationService.dndActive
    property bool vpnOn: false
    property var wifiNetworks: []

    // ── System info ──────────────────────────────────────────
    property string uptime: "0m"
    property string distroName: "Linux"
    property string username: "user"

    // ── Weather ──────────────────────────────────────────────
    property string weather: "..."


    // ── Cava ─────────────────────────────────────────────────
    property string cavaOutput: ""

    // ── Package updates ──────────────────────────────────────
    property string pacmanUpdates: ""
    property string aurUpdates: ""

    // ── Temperature / Global State ───────────────────────────
    property int temperature: 0
    
    // ── Window Title (Native & Reactive) ────────────────────
    property string windowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
    
    // Volume is now linked directly to Pipewire
    property alias volume: volumeWrapper.volume
    property alias muted: volumeWrapper.muted

    // ── Script / Cache Paths ─────────────────────────────────
    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"

    // ── Simple Volume Wrapper ────────────────────────────────
    QtObject {
        id: volumeWrapper
        property int volume: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
        property bool muted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio.muted : false
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // ── CPU Polling (Inlined) ───────────────────────────────
    Process {
        id: cpuProc
        command: ["bash", "-c", "grep 'cpu ' /proc/stat | awk '{idle=$5; total=$2+$3+$4+$5+$6+$7+$8; print int(100 - idle*100/total)}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let v = parseInt(this.text.trim())
                let perc = isNaN(v) ? 0 : v
                root.cpuUsage = perc
                
                // Maintain a history of 60 points
                let history = root.cpuHistory.slice()
                history.push(perc)
                if (history.length > 60) history.shift()
                root.cpuHistory = history
            }
        }
    }

    // ── RAM Polling (Inlined) ───────────────────────────────
    Process {
        id: ramProc
        command: ["bash", "-c", "free -b | awk '/^Mem/ { printf \"%s\\n%.0f\", $3/1024/1024/1024, $3/$2 * 100 }'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split("\n")
                if (parts.length >= 1) root.ramUsage = parseFloat(parts[0]).toFixed(2) + "GB"
                if (parts.length >= 2) {
                    let perc = parseInt(parts[1])
                    root.ramPerc = perc
                    
                    // Maintain a history of 60 points (5 minutes at 5s)
                    let history = root.ramHistory.slice() 
                    history.push(perc)
                    if (history.length > 60) history.shift()
                    root.ramHistory = history
                }
            }
        }
    }

    // ── GPU Polling (Inlined) ───────────────────────────────
    Process {
        id: gpuProc
        command: ["bash", "-c", "if command -v nvidia-smi &> /dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}'; elif ls /sys/class/drm/card*/device/gpu_busy_percent &> /dev/null; then cat /sys/class/drm/card*/device/gpu_busy_percent | head -n1; else echo 0; fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let v = parseInt(this.text.trim())
                root.gpuUsage = isNaN(v) ? 0 : v
            }
        }
    }

    // ── Temperature (Inlined) ──────────────────────────────
    Process {
        id: tempProc
        command: ["bash", "-c", "cat /sys/class/hwmon/hwmon5/temp1_input 2>/dev/null | awk '{printf \"%d\", $1/1000}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let v = parseInt(this.text.trim())
                let temp = isNaN(v) ? 0 : v
                root.temperature = temp
                
                // Maintain a history of 60 points
                let history = root.tempHistory.slice()
                history.push(temp)
                if (history.length > 60) history.shift()
                root.tempHistory = history
            }
        }
    }
    
    // ── Consolidate 5s Polling ─────────────────────────────
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            gpuProc.running = true
            tempProc.running = true
        }
    }

    // ── Network Monitoring (Consolidated Reactive) ─────────
    Process {
        id: networkMonitor
        command: ["bash", "-c", "nmcli monitor"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                // Connection SSID tracking
                if (data.includes("connectivity is now 'full'")) {
                    networkInit.running = true // Refresh SSID
                }
                
                // Device state tracking
                if (data.includes("wlan0")) {
                    if (data.includes("connected") && !data.includes("disconnected")) root.wifiOn = true
                    else if (data.includes("disconnected") || data.includes("unavailable")) root.wifiOn = false
                    networkInit.running = true // Refresh SSID
                }
                
                if (data.includes("proton")) {
                    if (data.includes("connected") && !data.includes("disconnected")) root.vpnOn = true
                    else if (data.includes("disconnected") || data.includes("unavailable")) root.vpnOn = false
                }
            }
        }
    }

    Process {
        id: networkInit
        command: ["bash", "-c", "nmcli -t -f DEVICE,STATE dev; echo '---'; nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split("---")
                let states = parts[0].trim().split("\n")
                
                root.wifiOn = states.some(s => s.startsWith("wlan0:connected"))
                root.vpnOn = states.some(s => s.includes("proton") && s.includes(":connected"))
                
                if (parts.length > 1) {
                    let ssid = parts[1].trim()
                    root.netSsid = ssid.length > 0 ? ssid : "Offline"
                } else {
                    root.netSsid = "Offline"
                }
            }
        }
    }

    Process {
        id: wifiScanProc
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n")
                let networks = []
                let seen = new Set()
                for (let line of lines) {
                    if (!line) continue
                    
                    // Match everything up to the last two colons
                    // NMCLI format: SSID:SIGNAL:SECURITY
                    let match = line.match(/^(.*?):([^:]*):([^:]*)$/)
                    if (!match) continue
                    
                    let ssid = match[1].replace(/\\:/g, ":").replace(/\\\\/g, "\\")
                    let signal = parseInt(match[2])
                    let security = match[3]
                    
                    if (ssid === "" || seen.has(ssid)) continue
                    seen.add(ssid)
                    
                    networks.push({
                        ssid: ssid,
                        signal: isNaN(signal) ? 0 : signal,
                        security: security
                    })
                }
                root.wifiNetworks = networks
            }
        }
    }

    function refreshWifi() {
        wifiScanProc.running = true
    }

    function connectWifi(ssid) {
        // Run a simple connect command; this assumes the connection is known or open,
        // or relies on the desktop environment's polkit agent for passwords if needed.
        _runOneShot(["nmcli", "dev", "wifi", "connect", ssid])
    }

    // ── Bluetooth status (Inlined) ──────────────────────────
    Process {
        id: btProc
        command: ["bash", "-c", "state=$(rfkill list bluetooth | grep -c 'yes'); if [ \"$state\" -gt 0 ]; then echo false; else echo true; fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.btOn = this.text.trim() === "true"
        }
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: btProc.running = true }



    // ── Uptime (Inlined) ────────────────────────────────────
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p | sed 's/^up //; s/ years\\?/y/g; s/ weeks\\?/w/g; s/ days\\?/d/g; s/ hours\\?/h/g; s/ minutes\\?/m/g'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.uptime = this.text.trim()
        }
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: uptimeProc.running = true }

    // ── Distro / User (Fast internal commands) ──────────────
    Process {
        id: distroProc
        command: ["bash", "-c", "grep '^NAME' /etc/os-release | cut -d= -f2 | tr -d '\"'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.distroName = this.text.trim()
        }
    }

    Process {
        id: userProc
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.username = this.text.trim()
        }
    }

    // ── Weather (Open-Meteo) ──────────────────────────────
    property var hourlyWeather: []

    function getWeatherIcon(code) {
        // WMO Weather interpretation codes (WW)
        // https://open-meteo.com/en/docs
        switch(code) {
            case 0: return "󰖙"; // Clear sky
            case 1: case 2: case 3: return "󰖕"; // Mainly clear, partly cloudy, and overcast
            case 45: case 48: return "󰖑"; // Fog
            case 51: case 53: case 55: return "󰖗"; // Drizzle
            case 61: case 63: case 65: return "󰖖"; // Rain
            case 66: case 67: return "󰖖"; // Freezing Rain
            case 71: case 73: case 75: return "󰖘"; // Snow fall
            case 77: return "󰖘"; // Snow grains
            case 80: case 81: case 82: return "󰖖"; // Rain showers
            case 85: case 86: return "󰖘"; // Snow showers
            case 95: return "󰖓"; // Thunderstorm
            case 96: case 99: return "󰖓"; // Thunderstorm with hail
            default: return "󰖐"; // Default: Cloud
        }
    }

    property string highTemp: "--"
    property string lowTemp: "--"

    Process {
        id: weatherProc
        command: ["bash", "-c", "curl -sm 5 'https://api.open-meteo.com/v1/forecast?latitude=41.08&longitude=-85.14&current_weather=true&hourly=temperature_2m,weathercode&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&forecast_days=2'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                if (text === "" || text === "N/A") {
                    root.weather = "N/A";
                    return;
                }
                
                try {
                    let data = JSON.parse(text);
                    if (!data.current_weather) {
                        root.weather = "N/A";
                        return;
                    }

                    // Current weather
                    let current = data.current_weather;
                    let temp = Math.round(current.temperature);
                    let code = current.weathercode;
                    root.weather = temp + "° " + root.getWeatherIcon(code);

                    // Daily High/Low
                    if (data.daily && data.daily.temperature_2m_max && data.daily.temperature_2m_max.length > 0) {
                        root.highTemp = Math.round(data.daily.temperature_2m_max[0]) + "°";
                        root.lowTemp = Math.round(data.daily.temperature_2m_min[0]) + "°";
                    }

                    // Hourly forecast
                    if (data.hourly && data.hourly.time) {
                        let now = new Date();
                        let hourlyData = [];
                        let times = data.hourly.time;
                        let temps = data.hourly.temperature_2m;
                        let codes = data.hourly.weathercode;

                        // Find the index of the current or next hour
                        let startIndex = 0;
                        for (let i = 0; i < times.length; i++) {
                            let t = new Date(times[i]);
                            if (t >= now || (t.getHours() === now.getHours() && t.getDate() === now.getDate())) {
                                startIndex = i;
                                break;
                            }
                        }

                        // Take next 24 hours
                        for (let i = startIndex; i < Math.min(startIndex + 24, times.length); i++) {
                            let t = new Date(times[i]);
                            let hours = t.getHours();
                            let ampm = hours >= 12 ? "PM" : "AM";
                            let displayHour = hours % 12;
                            if (displayHour === 0) displayHour = 12;
                            
                            hourlyData.push({
                                time: displayHour + ampm,
                                temp: Math.round(temps[i]) + "°",
                                icon: root.getWeatherIcon(codes[i])
                            });
                        }
                        root.hourlyWeather = hourlyData;
                    }
                } catch (e) {
                    console.error("Error parsing weather data:", e);
                    root.weather = "Error";
                }
            }
        }
    }
    Timer { interval: 900000; running: true; repeat: true; onTriggered: weatherProc.running = true }


    // ── Update Counters (Inlined) ──────────────────────────
    Process {
        id: pacmanProc
        command: ["bash", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let t = this.text.trim()
                root.pacmanUpdates = (t === "0") ? "" : t
            }
        }
    }
    Timer { interval: 3600000; running: true; repeat: true; onTriggered: pacmanProc.running = true }

    Process {
        id: aurProc
        command: ["bash", "-c", "yay -Qua 2>/dev/null | wc -l"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let t = this.text.trim()
                root.aurUpdates = (t === "0") ? "" : t
            }
        }
    }
    Timer { interval: 3600000; running: true; repeat: true; onTriggered: aurProc.running = true }

    // ── Cava (Streaming) ───────────────────────────────────
    Process {
        id: cavaProc
        command: ["bash", root.scriptsDir + "/cava.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => root.cavaOutput = data
        }
    }

    // ── Dedicated Toggle Actions (Inlined) ─────────────────
    Process { id: wifiToggle; command: ["bash", "-c", "state=$(nmcli radio wifi); if [ \"$state\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"]; running: false }
    Process { id: btToggle; command: ["bash", "-c", "state=$(rfkill list bluetooth | grep -c 'yes'); if [ \"$state\" -gt 0 ]; then rfkill unblock bluetooth; else rfkill block bluetooth; fi"]; running: false }
    Process { id: dndToggle; command: ["true"]; running: false }
    Process { id: vpnToggle; command: ["bash", "-c", "if nmcli device show proton0 2>/dev/null | grep -q 'STATE.*connected'; then protonvpn disconnect; else protonvpn connect; fi"]; running: false }


    // ── Volume Actions (Native) ───────────────────────────
    function setVolume(v) {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.volume = v / 100
        }
    }

    function toggleMute() {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
        }
    }

    function toggleWifi() {
        root.wifiOn = !root.wifiOn
        wifiToggle.running = true
        if (root.wifiOn) {
            refreshWifi()
        } else {
            root.wifiNetworks = []
        }
    }

    function toggleBt() {
        root.btOn = !root.btOn
        btToggle.running = true
    }

    function toggleDnd() {
        NotificationService.dndActive = !NotificationService.dndActive
    }

    function toggleVpn() {
        root.vpnOn = !root.vpnOn // Optimistic update
        vpnToggle.running = true
        // No verifyTimer needed as nmcli monitor will pick up the change reactively
    }

    // ── Notifications (Native Reactive) ─────────────────────
    property var notifications: NotificationService.history

    function clearNotifications() {
        NotificationService.clearHistory()
    }

    property int powerCountdown: 0
    property string powerActionType: "" // "shutdown" or "reboot"

    Timer {
        id: powerActionTimer
        interval: 1000
        running: root.powerCountdown > 0
        repeat: true
        onTriggered: {
            root.powerCountdown--
            if (root.powerCountdown === 0) {
                if (root.powerActionType === "shutdown") root.shutdown()
                else if (root.powerActionType === "reboot") root.reboot()
            }
        }
    }

    function togglePowerAction(type) {
        if (root.powerCountdown > 0 && root.powerActionType === type) {
            root.powerCountdown = 0
            root.powerActionType = ""
        } else {
            root.powerCountdown = 10
            root.powerActionType = type
        }
    }

    function lock() { root.powerCountdown = 0; _runOneShot(["hyprlock"]) }
    function logout() { root.powerCountdown = 0; _runOneShot(["hyprctl", "dispatch", "exit"]) }
    function suspend() { root.powerCountdown = 0; _runOneShot(["systemctl", "suspend"]) }
    function reboot() { _runOneShot(["systemctl", "reboot"]) }
    function shutdown() { _runOneShot(["systemctl", "poweroff"]) }

    function refreshWeather() {
        weatherProc.running = true
    }

    function _runOneShot(cmd) {
        oneshotProc.command = cmd
        oneshotProc.running = true
    }

    Process {
        id: oneshotProc
        command: ["true"]
        running: false
    }
}
