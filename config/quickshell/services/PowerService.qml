pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    // ── Properties ──────────────────────────────────────────
    property int powerCountdown: 0
    property string powerActionType: "" // "shutdown" or "reboot"

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

    // ── Actions ───────────────────────────────────────────
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

    function lock() { root.powerCountdown = 0; runCommand([ConfigService.lockCmd]) }
    function logout() { root.powerCountdown = 0; runCommand(["hyprctl", "dispatch", "exit"]) }
    function suspend()  { root.powerCountdown = 0; runCommand(["loginctl", "suspend"]) }
    function reboot()   { runCommand(["loginctl", "reboot"]) }
    function shutdown() { runCommand(["loginctl", "poweroff"]) }
}
