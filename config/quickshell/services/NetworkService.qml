pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import QtQuick
import "."

Singleton {
    id: root

    // ── Properties ──────────────────────────────────────────
    property string netSsid: "Offline"
    property bool wifiOn: false
    property bool btOn: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    property var btDevices: {
        let devs = []
        let vals = Bluetooth.devices.values
        for (let i = 0; i < vals.length; i++) {
            let d = vals[i]
            if (d.paired || d.connected) {
                devs.push({ connected: d.connected, address: d.address, name: d.name })
            }
        }
        return devs
    }
    property bool vpnOn: false


    
    property var wifiNetworks: []


    // ── Internal ──────────────────────────────────────────────
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

    // ── Network Monitoring (nmcli monitor) ─────────────────
    Process {
        id: networkMonitor
        command: ["bash", "-c", "nmcli monitor"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("connectivity is now") || data.includes(ConfigService.netInterface) || data.includes(ConfigService.vpnInterface)) {
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
                
                root.wifiOn = states.some(s => s.startsWith(ConfigService.netInterface + ":connected"))
                root.vpnOn = states.some(s => s.includes(ConfigService.vpnInterface) && s.includes(":connected"))
                
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
        runCommand(["nmcli", "dev", "wifi", "connect", ssid])
    }

    // ── Bluetooth ─────────────────────────────────────────




    function connectBt(address) {
        runCommand(["bluetoothctl", "connect", address])
    }

    function disconnectBt(address) {
        runCommand(["bluetoothctl", "disconnect", address])
    }



    // ── Toggles ───────────────────────────────────────────
    function toggleWifi() {
        root.wifiOn = !root.wifiOn
        runCommand(["bash", "-c", "state=$(nmcli radio wifi); if [ \"$state\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"])
        wifiRefreshTimer.restart()
        if (root.wifiOn) {
            refreshWifi()
        } else {
            root.wifiNetworks = []
        }
    }

    Timer {
        id: wifiRefreshTimer
        interval: 2000
        repeat: true
        property int count: 0
        onTriggered: {
            networkInit.running = true
            count++
            if (count >= 3) {
                stop()
                count = 0
            }
        }
    }

    function toggleBt() {
        if (!Bluetooth.defaultAdapter) return;
        
        if (Bluetooth.defaultAdapter.enabled) {
            Bluetooth.defaultAdapter.enabled = false;
            runCommand(["rfkill", "block", "bluetooth"]);
        } else {
            runCommand(["rfkill", "unblock", "bluetooth"]);
            Bluetooth.defaultAdapter.enabled = true;
        }
    }

    function toggleVpn() {
        root.vpnOn = !root.vpnOn
        runCommand(["bash", "-c", "if nmcli device show " + ConfigService.vpnInterface + " 2>/dev/null | grep -q 'STATE.*connected'; then " + ConfigService.vpnDisconnectCmd + "; else " + ConfigService.vpnConnectCmd + "; fi"])
        vpnRefreshTimer.restart()
    }

    Timer {
        id: vpnRefreshTimer
        interval: 3000
        repeat: true
        property int count: 0
        onTriggered: {
            networkInit.running = true
            count++
            if (count === 3) {
                interval = 6000
            } else if (count >= 4) {
                stop()
                count = 0
                interval = 3000
            }
        }
    }
}
