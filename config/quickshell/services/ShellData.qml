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
    property var cpuCoreUsages: []
    property string cpuSpeed: "0.00 GHz"
    property string ramUsage: "0GiB"
    property int ramPerc: 0
    property string ramAvailable: "0GiB"
    property string ramFree: "0GiB"
    property string ramCached: "0GiB"
    property var ramHistory: []
    property int gpuUsage: 0
    property int gpuTemp: 0
    property string gpuVramUsed: "0GiB"
    property string gpuVramTotal: "0GiB"
    property var gpuHistory: []
    property var tempHistory: []
    property int temperature: 0
    property real rxRate: 0.0
    property var rxHistory: []
    property real txRate: 0.0
    property var txHistory: []
    property bool hasFullscreen: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.hasFullscreen && (Hyprland.focusedWorkspace.monitor && Hyprland.focusedWorkspace.monitor.name === MonitorService.targetName)) || 
                                 (Hyprland.activeToplevel && Hyprland.activeToplevel.fullscreen && (Hyprland.activeToplevel.workspace && Hyprland.activeToplevel.workspace.monitor && Hyprland.activeToplevel.workspace.monitor.name === MonitorService.targetName)) || false
    
    // ── Network ──────────────────────────────────────────────
    property string netSsid: "Offline"

    // ── Toggle states ────────────────────────────────────────
    property bool wifiOn: false
    property bool btOn: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    property bool dndOn: NotificationService.dndActive
    property bool vpnOn: false
    property bool idleOn: false
    property bool micBusy: false
    property var micApps: []
    property var wifiNetworks: []
    property var btDevices: []
    property alias appVolumesModel: appVolumesModel
    ListModel { id: appVolumesModel }
    property var _appVolBusyMap: ({}) 

    // ── System info ──────────────────────────────────────────
    property string uptime: "0m"
    property string distroName: "Linux"
    property string username: "user"

    readonly property string shellVersion: "0.2.1"
    readonly property string configTitle: "Stellyrland"
    readonly property string configVersion: "1.0"
    readonly property string shellAuthor: "stellanova"

    // ── Weather ──────────────────────────────────────────────
    property string weather: "..."


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
    property bool alVisible: false
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
    property bool screenshotNoTimer: false

    function closeAllPopups() {
        root.ccVisible = false
        root.ncVisible = false
        root.alVisible = false
        root.calVisible = false
        root.trafficVisible = false
        root.ramVisible = false
        root.cpuVisible = false
        root.gpuVisible = false
        root.tempVisible = false
        root.mediaVisible = false
        root.updatesVisible = false
        root.micVisible = false
        root.volumeVisible = false
        root.wallpaperVisible = false
        root.logoutVisible = false
        root.screenshotVisible = false
    }

    
    // ── Window Title (Native & Reactive) ────────────────────
    property string windowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
    
    // Volume and Microphone linked directly to Pipewire
    property alias volume: volumeWrapper.volume
    property alias muted: volumeWrapper.muted
    property alias micMuted: micWrapper.muted
    property bool micOn: !micMuted

    // ── Script / Cache Paths ─────────────────────────────────
    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"

    // ── Simple Volume Wrapper ────────────────────────────────
    QtObject {
        id: volumeWrapper
        property int volume: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
        property bool muted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio.muted : false
    }

    QtObject {
        id: micWrapper
        property bool muted: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio ? Pipewire.defaultAudioSource.audio.muted : true
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource, ...Pipewire.nodes.values]
    }

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
        command: ["bash", root.scriptsDir + "/stats.sh"]
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


    // ── Network Monitoring (Consolidated Reactive) ─────────
    Process {
        id: networkMonitor
        command: ["bash", "-c", "nmcli monitor"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("connectivity is now") || data.includes("wlan0") || data.includes("proton")) {
                    networkInit.running = true
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

    // ── Bluetooth Monitoring ──────────────────────────────
    Process {
        id: btDevicesProc
        command: ["bash", "-c", "all=$(bluetoothctl devices); connected=$(bluetoothctl devices Connected); if [ -z \"$all\" ]; then exit 0; fi; echo \"$all\" | while read -r line; do addr=$(echo \"$line\" | cut -d' ' -f2); name=$(echo \"$line\" | cut -d' ' -f3-); if echo \"$connected\" | grep -q \"$addr\"; then echo \"connected|$addr|$name\"; else echo \"paired|$addr|$name\"; fi; done"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n")
                let devices = []
                for (let line of lines) {
                    if (!line) continue
                    let parts = line.split("|")
                    if (parts.length < 3) continue
                    devices.push({
                        connected: parts[0] === "connected",
                        address: parts[1],
                        name: parts[2]
                    })
                }
                root.btDevices = devices
            }
        }
    }

    function refreshBt() {
        btDevicesProc.running = true
    }

    function connectBt(address) {
        _runOneShot(["bluetoothctl", "connect", address])
        // Refresh after a short delay to catch the state change
        refreshTimer.restart()
    }

    function disconnectBt(address) {
        _runOneShot(["bluetoothctl", "disconnect", address])
        refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 2000
        repeat: false
        onTriggered: refreshBt()
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
        // Using hardcoded coordinates for the weather API
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
                        let startIndex = times.findIndex(timeStr => {
                            let t = new Date(timeStr);
                            return t >= now || (t.getHours() === now.getHours() && t.getDate() === now.getDate());
                        });
                        if (startIndex === -1) startIndex = 0;


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
    // Toggles are now handled via _runOneShot for better robustness

    Process {
        id: idleInitCheck
        command: ["bash", "-c", "pgrep -x hypridle > /dev/null && echo true || echo false"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.idleOn = (this.text.trim() === "true")
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: idleInitCheck.running = true
    }

    // ── Microphone Usage Monitoring (Reactive) ─────────────
    Process {
        id: micBusyMonitor
        command: ["bash", "-c", "pactl subscribe | grep --line-buffered 'source-output'"]
        running: true
        stdout: SplitParser {
            onRead: data => micBusyCheck.running = true
        }
    }

    Process {
        id: micBusyCheck
        command: ["bash", "-c", "pactl list source-outputs | awk '/application.name =/ {print $3}' | tr -d '\"' | grep -v 'cava'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let apps = this.text.trim().split("\n").filter(x => x.length > 0)
                root.micApps = apps
                root.micBusy = apps.length > 0
            }
        }
    }
    // ── App Volume Monitoring (Stable ListModel) ────────
    Process {
        id: appVolumeProc
        command: ["bash", root.scriptsDir + "/get_app_volumes.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let newData = JSON.parse(this.text.trim())
                    let now = Date.now()
                    
                    // Synchronize ListModel
                    let pwNodes = Pipewire.nodes
                    let seenIds = {}
                    for (let newItem of newData) {
                        seenIds[newItem.id] = true
                        
                        // Find matching native node for smooth control
                        // Try matching by ID first (works with our new pw-dump fallback)
                        let nativeNode = root.getAppNode(newItem.id)
                        
                        if (!nativeNode || !nativeNode.audio) {
                            // Fallback to name matching (for pactl compatibility)
                            nativeNode = null
                            let targetName = newItem.name.toLowerCase().trim()
                            let nodes = pwNodes.values
                            for (let pwNode of nodes) {
                                if (!pwNode.audio) continue
                                let pwName = (pwNode.properties["node.name"] || pwNode.properties["application.name"] || "").toLowerCase().trim()
                                if (pwName === "") continue
                                if (pwName === targetName || (targetName !== "unknown" && (pwName.includes(targetName) || targetName.includes(pwName)))) {
                                    nativeNode = pwNode
                                    break
                                }
                            }
                        }
                        
                        let busySince = root._appVolBusyMap[newItem.id] || 0
                        let isBusy = (now - busySince < 3000)
                        
                        // Find existing index
                        let idx = -1
                        for (let i = 0; i < appVolumesModel.count; i++) {
                            if (appVolumesModel.get(i).id === newItem.id) {
                                idx = i; break
                            }
                        }
                        
                        if (idx !== -1) {
                            // Update existing
                            let props = {
                                name: newItem.name,
                                icon: newItem.icon,
                                pwId: nativeNode ? nativeNode.id : -1 // Store native node ID
                            }
                            if (!isBusy) {
                                props.volume = newItem.volume
                                props.muted = newItem.muted
                            }
                            appVolumesModel.set(idx, props)
                        } else {
                            // Add new
                            newItem.pwId = nativeNode ? nativeNode.id : -1
                            appVolumesModel.append(newItem)
                        }
                    }
                    
                    // Remove old
                    for (let i = appVolumesModel.count - 1; i >= 0; i--) {
                        if (!seenIds[appVolumesModel.get(i).id]) {
                            appVolumesModel.remove(i)
                        }
                    }
                } catch (e) {
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: appVolumeProc.running = true
    }

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

    function getAppNode(id) {
        if (id === -1) return null
        let nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
            if (nodes[i].id === id) return nodes[i]
        }
        return null
    }

    function setAppVolume(id, v) {
        // Mark as busy
        let map = root._appVolBusyMap
        map[id] = Date.now()
        root._appVolBusyMap = map
        
        let pwId = -1
        for (let i = 0; i < appVolumesModel.count; i++) {
            let item = appVolumesModel.get(i)
            if (item.id === id) {
                appVolumesModel.setProperty(i, "volume", v)
                pwId = item.pwId
                break
            }
        }
        
        // Find the native node from the ID
        let targetNode = null
        if (pwId !== -1) {
            let nodes = Pipewire.nodes.values
            for (let i = 0; i < nodes.length; i++) {
                if (nodes[i].id === pwId) {
                    targetNode = nodes[i]
                    break
                }
            }
        }

        // Use native control if available for zero-latency smoothness
        if (targetNode && targetNode.audio) {
            targetNode.audio.volume = v / 100
        } else {
            // Fallback to throttled pactl
            let updates = root._pendingAppVolUpdates
            updates[id] = v
            root._pendingAppVolUpdates = updates
            appVolUpdateTimer.restart()
        }
    }

    property var _pendingAppVolUpdates: ({})
    Timer {
        id: appVolUpdateTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            for (let id in _pendingAppVolUpdates) {
                _runOneShot(["pactl", "set-sink-input-volume", id.toString(), _pendingAppVolUpdates[id] + "%"])
            }
            root._pendingAppVolUpdates = {}
        }
    }

    function toggleAppMute(id) {
        let pwId = -1
        for (let i = 0; i < appVolumesModel.count; i++) {
            let item = appVolumesModel.get(i)
            if (item.id === id) {
                pwId = item.pwId
                break
            }
        }
        
        let targetNode = null
        if (pwId !== -1) {
            let nodes = Pipewire.nodes.values
            for (let i = 0; i < nodes.length; i++) {
                if (nodes[i].id === pwId) {
                    targetNode = nodes[i]
                    break
                }
            }
        }
        
        if (targetNode && targetNode.audio) {
            targetNode.audio.muted = !targetNode.audio.muted
        } else {
            _runOneShot(["pactl", "set-sink-input-mute", id.toString(), "toggle"])
        }
        appVolumeProc.running = true
    }

    function toggleWifi() {
        root.wifiOn = !root.wifiOn
        _runOneShot(["bash", "-c", "state=$(nmcli radio wifi); if [ \"$state\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"])
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
            root.btDevices = []
        } else {
            _runOneShot(["rfkill", "unblock", "bluetooth"])
            // Nudge the native service to enable it once unblocked
            if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = true
            refreshBt()
        }
    }

    function toggleDnd() {
        NotificationService.dndActive = !NotificationService.dndActive
    }

    function toggleIdle() {
        if (root.idleOn) {
            _runOneShot(["killall", "hypridle"])
            root.idleOn = false
        } else {
            _runOneShot(["hyprctl", "dispatch", "exec", "hypridle"])
            root.idleOn = true
        }
    }

    function toggleMic() {
        if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio) {
            Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted
        }
    }

    function toggleVpn() {
        root.vpnOn = !root.vpnOn // Optimistic update
        _runOneShot(["bash", "-c", "if nmcli device show proton0 2>/dev/null | grep -q 'STATE.*connected'; then protonvpn disconnect; else protonvpn connect; fi"])
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
