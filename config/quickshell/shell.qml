//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "components" as Components

// QuickShell entry point — orchestrates all windows
Scope {
    id: root

    // ── State ────────────────────────────────────────────────
    property bool ccVisible: false
    property bool ncVisible: false
    property bool alVisible: false
    property bool calVisible: false
    property bool wifiVisible: false
    property bool ramVisible: false
    property bool cpuVisible: false
    property bool tempVisible: false
    property bool mediaVisible: false
    
    property real ccX: 0
    property real ncX: 0
    property real calX: 0
    property real wifiX: 0
    property real ramX: 0
    property real cpuX: 0
    property real tempX: 0
    property real mediaX: 0

    function closeAllPopups() {
        root.ccVisible = false
        root.ncVisible = false
        root.alVisible = false
        root.calVisible = false
        root.wifiVisible = false
        root.ramVisible = false
        root.cpuVisible = false
        root.tempVisible = false
        root.mediaVisible = false
        trayMenu.menuHandle = null
    }

    // Close all popups when workspace changes
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.closeAllPopups()
        }
    }

    IpcHandler {
        target: "shell"
        function toggleLauncher() {
            let target = !root.alVisible
            root.closeAllPopups()
            root.alVisible = target
        }
    }

    // ── Top Bar ──────────────────────────────────────────────
    Bar {
        id: topBar
        trayMenu: trayMenu

        onToggleControlCenter: (x) => {
            let target = !root.ccVisible
            root.closeAllPopups()
            root.ccX = x
            root.ccVisible = target
        }

        onToggleNotificationCenter: (x) => {
            let target = !root.ncVisible
            root.closeAllPopups()
            root.ncX = x
            root.ncVisible = target
        }

        onToggleCalendar: (x) => {
            let target = !root.calVisible
            root.closeAllPopups()
            root.calX = x
            root.calVisible = target
        }

        onToggleWifiMenu: (x) => {
            let target = !root.wifiVisible
            root.closeAllPopups()
            root.wifiX = x
            root.wifiVisible = target
        }

        onToggleRamMenu: (x) => {
            let target = !root.ramVisible
            root.closeAllPopups()
            root.ramX = x
            root.ramVisible = target
        }

        onToggleCpuMenu: (x) => {
            let target = !root.cpuVisible
            root.closeAllPopups()
            root.cpuX = x
            root.cpuVisible = target
        }

        onToggleTempMenu: (x) => {
            let target = !root.tempVisible
            root.closeAllPopups()
            root.tempX = x
            root.tempVisible = target
        }

        onToggleMediaMenu: (x) => {
            let target = !root.mediaVisible
            root.closeAllPopups()
            root.mediaX = x
            root.mediaVisible = target
        }
    }

    // ── Control Center Popup ─────────────────────────────────
    ControlCenter {
        id: cc
        screen: topBar.screen
        visible: root.ccVisible
        onCloseRequested: root.ccVisible = false
    }

    // ── Notification Center Popup ────────────────────────────
    NotificationCenter {
        id: nc
        screen: topBar.screen
        visible: root.ncVisible
        onCloseRequested: root.ncVisible = false
    }

    // ── Calendar Popup ────────────────────────────
    CalendarPopup {
        id: cal
        screen: topBar.screen
        open: root.calVisible
        xOffset: root.calX
        onCloseRequested: root.calVisible = false
    }

    // ── Wifi Popup ────────────────────────────────
    WifiPopup {
        id: wifiMenu
        screen: topBar.screen
        open: root.wifiVisible
        xOffset: root.wifiX
        onCloseRequested: root.wifiVisible = false
    }

    // ── RAM Popup ─────────────────────────────────
    RamPopup {
        id: ramMenu
        screen: topBar.screen
        open: root.ramVisible
        xOffset: root.ramX
        onCloseRequested: root.ramVisible = false
    }

    // ── CPU Popup ─────────────────────────────────
    CpuPopup {
        id: cpuMenu
        screen: topBar.screen
        open: root.cpuVisible
        xOffset: root.cpuX
        onCloseRequested: root.cpuVisible = false
    }

    // ── Temp Popup ─────────────────────────────────
    TempPopup {
        id: tempMenu
        screen: topBar.screen
        open: root.tempVisible
        xOffset: root.tempX
        onCloseRequested: root.tempVisible = false
    }

    MediaPopup {
        id: mediaMenu
        screen: topBar.screen
        open: root.mediaVisible
        xOffset: root.mediaX
        onCloseRequested: root.mediaVisible = false
    }

    AppLauncher {
        id: al
        screen: topBar.screen
        visible: root.alVisible
        onCloseRequested: root.alVisible = false
    }

    NotificationPopup { 
        screen: topBar.screen
    }

    Components.TrayMenu {
        id: trayMenu
        visible: false
        menuHandle: null
    }
}
