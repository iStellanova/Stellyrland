pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import QtQuick
import "."

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
    property int temperature: 0
    property bool hasFullscreen: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.hasFullscreen && (Hyprland.focusedWorkspace.monitor && Hyprland.focusedWorkspace.monitor.name === MonitorService.targetName)) || 
                                 (Hyprland.activeToplevel && Hyprland.activeToplevel.fullscreen && (Hyprland.activeToplevel.workspace && Hyprland.activeToplevel.workspace.monitor && Hyprland.activeToplevel.workspace.monitor.name === MonitorService.targetName)) || false
    
    // ── Network ──────────────────────────────────────────────
    property string netSsid: "Offline"

    // ── Toggle states ────────────────────────────────────────
    property bool wifiOn: false
    property bool btOn: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
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
    property var cavaData: []

    // ── Package updates ──────────────────────────────────────
    property string pacmanUpdates: ""
    property string aurUpdates: ""
    property var pacmanUpdateList: []
    property var aurUpdateList: []

    
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

    // ── System Stats (Consolidated Streaming) ────────────────
    Process {
        id: statsProc
        command: ["bash", root.scriptsDir + "/stats.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    let stats = JSON.parse(data)
                    root.cpuUsage = stats.cpu
                    root.ramPerc = stats.ram_perc
                    root.ramUsage = stats.ram_gb + "GB"
                    root.gpuUsage = stats.gpu
                    root.temperature = stats.temp

                    // Update Histories
                    let cpuH = root.cpuHistory.slice()
                    cpuH.push(stats.cpu)
                    if (cpuH.length > 60) cpuH.shift()
                    root.cpuHistory = cpuH

                    let ramH = root.ramHistory.slice()
                    ramH.push(stats.ram_perc)
                    if (ramH.length > 60) ramH.shift()
                    root.ramHistory = ramH

                    let tempH = root.tempHistory.slice()
                    tempH.push(stats.temp)
                    if (tempH.length > 60) tempH.shift()
                    root.tempHistory = tempH
                } catch (e) {
                    console.error("Failed to parse stats JSON:", data)
                }
            }
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
    // ── Uptime (Optimized Native Read) ──────────────────────
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
    }

    Timer {
        interval: 60000 // Update every minute
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let content = uptimeFile.text().trim().split(" ")[0]
            let seconds = parseFloat(content)
            if (!isNaN(seconds)) {
                let d = Math.floor(seconds / (24 * 3600))
                let s = seconds % (24 * 3600)
                let h = Math.floor(s / 3600)
                s %= 3600
                let m = Math.floor(s / 60)
                
                let res = ""
                if (d > 0) res += d + "d "
                if (h > 0) res += h + "h "
                if (m > 0 || res === "") res += m + "m"
                root.uptime = res.trim()
            }
        }
    }


    // ── Distro / User (Optimized Native / Single Fork) ──────
    FileView {
        id: osReleaseFile
        path: "/etc/os-release"
    }

    Timer {
        running: true
        repeat: false
        triggeredOnStart: true
        onTriggered: {
            let lines = osReleaseFile.text().split("\n")
            for (let line of lines) {
                if (line.startsWith("NAME=")) {
                    root.distroName = line.substring(5).replace(/"/g, "")
                    break
                }
            }
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


    // ── Update Service (Consolidated) ──────────────────────
    function refreshUpdateLists() {
        updateListProc.running = true
    }

    Process {
        id: updateListProc
        command: ["bash", root.scriptsDir + "/get_update_list.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = this.text.trim()
                let lines = raw.length > 0 ? raw.split("\n") : []
                let pacman = []
                let aur = []
                for (let line of lines) {
                    if (!line) continue
                    let parts = line.split("|")
                    if (parts.length < 3) continue
                    
                    if (parts[0] === "counts") {
                        root.pacmanUpdates = (parts[1] === "0") ? "" : parts[1]
                        root.aurUpdates = (parts[2] === "0") ? "" : parts[2]
                        continue
                    }
                    
                    if (parts.length < 4) continue
                    let item = {
                        name: parts[1],
                        old: parts[2],
                        new: parts[3]
                    }
                    if (parts[0] === "pacman") pacman.push(item)
                    else if (parts[0] === "aur") aur.push(item)
                }
                root.pacmanUpdateList = pacman
                root.aurUpdateList = aur
            }
        }
    }
    Timer { interval: 3600000; running: true; repeat: true; onTriggered: updateListProc.running = true }


    // ── Cava (Streaming) ───────────────────────────────────
    Process {
        id: cavaProc
        command: ["bash", root.scriptsDir + "/cava.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                let parts = data.split(";").filter(x => x.length > 0)
                root.cavaData = parts.map(x => parseInt(x))
            }
        }
    }

    // ── Dedicated Toggle Actions (Inlined) ─────────────────
    Process { id: wifiToggle; command: ["bash", "-c", "state=$(nmcli radio wifi); if [ \"$state\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"]; running: false }
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
        if (root.btOn) {
            if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = false
            _runOneShot(["rfkill", "block", "bluetooth"])
        } else {
            _runOneShot(["rfkill", "unblock", "bluetooth"])
            // Nudge the native service to enable it once unblocked
            if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = true
        }
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
