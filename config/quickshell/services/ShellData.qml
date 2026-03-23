pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "."

Singleton {
    id: root

    // ── System stats (polled via /proc reads) ────────────────
    property int cpuUsage: 0
    property var cpuHistory: [0]
    property var cpuCoreUsages: []
    property string cpuSpeed: "0.00 GHz"
    property string ramUsage: "0GiB"
    property int ramPerc: 0
    property string ramAvailable: "0GiB"
    property string ramFree: "0GiB"
    property string ramCached: "0GiB"
    property var ramHistory: [0]
    property int gpuUsage: 0
    property int gpuTemp: 0
    property string gpuVramUsed: "0GiB"
    property string gpuVramTotal: "0GiB"
    property var gpuHistory: [0]
    property var tempHistory: [0]
    property int temperature: 0
    property real rxRate: 0.0
    property var rxHistory: [0]
    property real txRate: 0.0
    property var txHistory: [0]
    property bool hasFullscreen: {
        let fw = Hyprland.focusedWorkspace
        if (fw && fw.hasFullscreen && fw.monitor && fw.monitor.name === MonitorService.targetName) return true
        let at = Hyprland.activeToplevel
        if (at && at.fullscreen && at.workspace && at.workspace.monitor && at.workspace.monitor.name === MonitorService.targetName) return true
        return false
    }
    
    // ── System info ──────────────────────────────────────────
    property string uptime: "0m"
    property string distroName: "Linux"
    property string username: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"

    property string shellVersion: "..."
    readonly property string configTitle: "Stellyrland"
    readonly property string configVersion: "1.0.5"
    readonly property string shellAuthor: "stellanova"
    // ── Version Detection ─────────────────────────────────────
    Process {
        id: versionProc
        command: ["quickshell", "--version"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let line = this.text.split("\n")[0]
                let parts = line.split(" ")
                if (parts.length > 1) {
                    root.shellVersion = parts[1].replace(",", "").trim()
                }
            }
        }
    }


    // ── Weather ──────────────────────────────────────────────
    property real latitude: ConfigService.weatherLat
    property real longitude: ConfigService.weatherLon
    property real detectedLat: 0.0
    property real detectedLon: 0.0
    property bool locationDetected: false
    
    // Final coordinates used for fetching
    readonly property real currentLat: (latitude !== 0.0) ? latitude : detectedLat
    readonly property real currentLon: (longitude !== 0.0) ? longitude : detectedLon
    
    property string weather: "..."
    
    // Detection logic
    Process {
        id: locationProc
        // Using ipapi.co over HTTPS which is more reliable than HTTP ip-api.com
        command: ["curl", "-sm", "5", "https://ipapi.co/json/"]
        running: latitude === 0.0 && longitude === 0.0
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                if (text === "") {
                    console.warn("Location detection returned empty response");
                    return;
                }
                
                try {
                    let data = JSON.parse(text)
                    if (data.latitude && data.longitude) {
                        root.detectedLat = data.latitude
                        root.detectedLon = data.longitude
                        root.locationDetected = true
                        console.log("Detected location: " + root.detectedLat + ", " + root.detectedLon)
                    } else {
                        console.warn("Location detection failed: " + text)
                    }
                } catch (e) {
                    console.error("Failed to parse location response: " + e + "\nResponse: " + text)
                }
            }
        }
    }

    onCurrentLatChanged: weatherTriggerTimer.restart()
    onCurrentLonChanged: weatherTriggerTimer.restart()

    Connections {
        target: ConfigService
        function onWeatherCelsiusChanged() { weatherTriggerTimer.restart() }
    }

    Timer {
        id: weatherTriggerTimer
        interval: 100
        onTriggered: if (currentLat !== 0.0 && currentLon !== 0.0) weatherProc.running = true
    }


    // ── Toggles ──────────────────────────────────────────────
    property bool dndOn: NotificationService.dndActive
    property bool idleOn: false

    // ── Cava ─────────────────────────────────────────────────
    property var cavaData: []

    // ── Package updates ──────────────────────────────────────
    property string pacmanUpdates: ""
    property string aurUpdates: ""
    property var pacmanUpdateList: []
    property var aurUpdateList: []
    
    // ── Popup Visibility States ──────────────────────────────
    property bool ccVisible: false
    property bool ncVisible: false
    property bool calVisible: false
    property bool trafficVisible: false
    property bool ramVisible: false
    property bool cpuVisible: false
    property bool gpuVisible: false
    property bool tempVisible: false
    property bool mediaVisible: false
    property bool updatesVisible: false
    property bool micVisible: false
    property bool volumeVisible: false
    property bool wallpaperVisible: false
    property bool logoutVisible: false
    property bool screenshotVisible: false
    property bool settingsVisible: false
    property bool shortcutsVisible: false
    property bool overviewVisible: false


    
    // ── Window Title (Native & Reactive) ────────────────────
    property string windowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
    


    // ── Script / Cache Paths ─────────────────────────────────
    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"



    // ── Helper: Update History List ──────────────────────────
    function _updateHistory(history, newValue, maxLen = 60) {
        let h = history.slice()
        h.push(newValue)
        if (h.length > maxLen) h.shift()
        return h
    }

    // ── System Stats (Consolidated Streaming) ────────────────
    Process {
        id: statsProc
        command: ["bash", root.scriptsDir + "/stats.sh", ConfigService.pollStats.toString()]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    let stats = JSON.parse(data)
                    root.cpuUsage = stats.cpu
                    root.cpuCoreUsages = stats.cpu_cores
                    root.cpuSpeed = stats.cpu_speed
                    root.ramPerc = stats.ram_perc
                    root.ramUsage = stats.ram_gb + "GB"
                    root.ramAvailable = stats.ram_avail + "GB"
                    root.ramFree = stats.ram_free + "GB"
                    root.ramCached = stats.ram_cached + "GB"
                    root.gpuUsage = stats.gpu
                    root.gpuTemp = stats.gpu_temp
                    root.gpuVramUsed = stats.gpu_vram_used + "GB"
                    root.gpuVramTotal = stats.gpu_vram_total + "GB"
                    root.temperature = stats.temp
                    root.rxRate = stats.rx_kbps
                    root.txRate = stats.tx_kbps

                    // Update Histories via helper
                    root.cpuHistory = _updateHistory(root.cpuHistory, stats.cpu)
                    root.ramHistory = _updateHistory(root.ramHistory, stats.ram_perc)
                    root.tempHistory = _updateHistory(root.tempHistory, stats.temp)
                    root.gpuHistory = _updateHistory(root.gpuHistory, stats.gpu)
                    root.rxHistory = _updateHistory(root.rxHistory, stats.rx_kbps)
                    root.txHistory = _updateHistory(root.txHistory, stats.tx_kbps)
                } catch (e) {
                    console.error("Failed to parse stats JSON:", data)
                }
            }
        }
    }

    // ── Hyprland Keybinds ─────────────────────────────────────
    property var hyprlandBinds: []
    Process {
        id: hyprBindsProc
        command: ["python3", root.scriptsDir + "/get_hyprland_binds.py"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.hyprlandBinds = JSON.parse(this.text.trim())
                } catch (e) {
                    console.error("Failed to parse hyprland binds:", e)
                }
            }
        }
    }

    function refreshHyprBinds() {
        hyprBindsProc.running = false
        hyprBindsProc.running = true
    }

    // Refresh binds when shortcuts are shown
    onShortcutsVisibleChanged: if (shortcutsVisible) refreshHyprBinds()


    // ── Uptime (Optimized Native Read) ──────────────────────
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onTextChanged: {
            let content = text().trim().split(" ")[0]
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

    Timer {
        interval: ConfigService.pollUptime
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeFile.reload()
    }


    // ── Distro / User (Optimized Native / Single Fork) ──────
    FileView {
        id: osReleaseFile
        path: "/etc/os-release"
        onTextChanged: {
            if (!text()) return
            let lines = text().split("\n")
            for (let line of lines) {
                if (line.startsWith("NAME=")) {
                    root.distroName = line.substring(5).replace(/"/g, "")
                    break
                }
            }
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
        // Using configurable coordinates for the weather API
        command: [
            "curl", "-sm", "5", "-G",
            "https://api.open-meteo.com/v1/forecast",
            "-d", "latitude=" + root.currentLat,
            "-d", "longitude=" + root.currentLon,
            "-d", "current_weather=true",
            "-d", "hourly=temperature_2m,weathercode",
            "-d", "daily=temperature_2m_max,temperature_2m_min",
            "-d", "temperature_unit=" + (ConfigService.weatherCelsius ? "celsius" : "fahrenheit"),
            "-d", "forecast_days=2"
        ]
        running: (root.currentLat !== 0.0 && root.currentLon !== 0.0)
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
                        let startIndex = times.findIndex(timeStr => {
                            let t = new Date(timeStr);
                            return t >= now || (t.getHours() === now.getHours() && t.getDate() === now.getDate());
                        });
                        if (startIndex === -1) startIndex = 0;


                        // Take next 24 hours
                        for (let i = startIndex; i < Math.min(startIndex + 24, times.length); i++) {
                            let t = new Date(times[i]);
                            let hours = t.getHours();
                            let timeStr = "";
                            
                            if (ConfigService.weatherHour24) {
                                timeStr = hours.toString().padStart(2, '0') + ":00";
                            } else {
                                let ampm = hours >= 12 ? "PM" : "AM";
                                let displayHour = hours % 12;
                                if (displayHour === 0) displayHour = 12;
                                timeStr = displayHour + ampm;
                            }
                            
                            hourlyData.push({
                                time: timeStr,
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
    Timer { interval: ConfigService.pollWeather; running: true; repeat: true; onTriggered: weatherProc.running = true }


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
    Timer { interval: ConfigService.pollUpdates; running: true; repeat: true; onTriggered: updateListProc.running = true }


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

    // Toggles are now handled via runCommand for better robustness
    function restartStats() {
        statsProc.running = false
        statsProc.running = true
    }

    function toggleDnd() {
        NotificationService.dndActive = !NotificationService.dndActive
    }

    Process {
        id: idleCheckProc
        command: ["pgrep", "-x", "hypridle"]
        running: true
        onExited: (code) => {
            root.idleOn = (code === 0)
        }
    }
    Timer { interval: ConfigService.pollIdle; running: true; repeat: true; onTriggered: idleCheckProc.running = true }

    function toggleIdle() {
        if (root.idleOn) {
            runCommand(["killall", "hypridle"])
        } else {
            runCommand(["hyprctl", "dispatch", "exec", "hypridle"])
        }
        
        // Small delay then re-check
        Qt.callLater(() => { idleCheckProc.running = true })
    }
    // ── Notifications (Native Reactive) ─────────────────────
    property var notifications: NotificationService.history

    function clearNotifications() {
        NotificationService.clearHistory()
    }
    function refreshWeather() {
        weatherProc.running = true
    }

    function runCommand(cmd) {
        let proc = oneshotFactory.createObject(root, { command: cmd });
        proc.running = true;
    }

    Component {
        id: oneshotFactory
        Process {
            onRunningChanged: if (!running) this.destroy()
        }
    }
}
