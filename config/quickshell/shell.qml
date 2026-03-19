//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import "components" as Components
import "services" as Services

// QuickShell entry point — orchestrates all windows
Scope {
    id: root

    // ── State ────────────────────────────────────────────────
    // Visibility is managed directly via Services.ShellData
    
    property real calX: 0
    property real trafficX: 0
    property real ramX: 0
    property real cpuX: 0
    property real gpuX: 0
    property real tempX: 0
    property real mediaX: 0
    property real updatesX: 0
    property real micX: 0
    property real volumeX: 0

    function closeAllPopups() {
        // List of pinnable popups and their visibility property names in ShellData
        let pinnable = [
            { component: cal, prop: "calVisible" },
            { component: trafficMenu, prop: "trafficVisible" },
            { component: ramMenu, prop: "ramVisible" },
            { component: cpuMenu, prop: "cpuVisible" },
            { component: gpuMenu, prop: "gpuVisible" },
            { component: tempMenu, prop: "tempVisible" },
            { component: mediaMenu, prop: "mediaVisible" },
            { component: updatesMenu, prop: "updatesVisible" },
            { component: micMenu, prop: "micVisible" },
            { component: volumeMenu, prop: "volumeVisible" }
        ]

        pinnable.forEach(p => {
            if (!p.component.pinned) Services.ShellData[p.prop] = false
        })
        
        // Non-pinnable ones always close
        Services.ShellData.ccVisible = false
        Services.ShellData.ncVisible = false
        Services.ShellData.alVisible = false
        Services.ShellData.wallpaperVisible = false
        Services.ShellData.logoutVisible = false
        Services.ShellData.screenshotVisible = false

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
            let target = !Services.ShellData.alVisible
            root.closeAllPopups()
            Services.ShellData.alVisible = target
        }

        function toggleWallpaperSelector() {
            let target = !Services.ShellData.wallpaperVisible
            root.closeAllPopups()
            Services.ShellData.wallpaperVisible = target
        }

        function toggleLogout() {
            let target = !Services.ShellData.logoutVisible
            root.closeAllPopups()
            Services.ShellData.logoutVisible = target
        }
        
        function toggleScreenshot() {
            let target = !Services.ShellData.screenshotVisible
            root.closeAllPopups()
            Services.ShellData.screenshotVisible = target
        }

        function triggerDelayedScreenshot() {
            Services.ShellData.screenshotNoTimer = true
            Services.ShellData.screenshotVisible = true
        }
    }

    // ── Calendar Popup ────────────────────────────
    CalendarPopup {
        id: cal
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.calVisible
        xOffset: root.calX
        onCloseRequested: Services.ShellData.calVisible = false
    }

    // ── Traffic Popup ────────────────────────────────
    TrafficPopup {
        id: trafficMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.trafficVisible
        xOffset: root.trafficX
        onCloseRequested: Services.ShellData.trafficVisible = false
    }

    // ── RAM Popup ─────────────────────────────────
    RamPopup {
        id: ramMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.ramVisible
        xOffset: root.ramX
        onCloseRequested: Services.ShellData.ramVisible = false
    }

    // ── CPU Popup ─────────────────────────────────
    CpuPopup {
        id: cpuMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.cpuVisible
        xOffset: root.cpuX
        onCloseRequested: Services.ShellData.cpuVisible = false
    }

    // ── GPU Popup ─────────────────────────────────
    GpuPopup {
        id: gpuMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.gpuVisible
        xOffset: root.gpuX
        onCloseRequested: Services.ShellData.gpuVisible = false
    }

    // ── Temp Popup ─────────────────────────────────
    TempPopup {
        id: tempMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.tempVisible
        xOffset: root.tempX
        onCloseRequested: Services.ShellData.tempVisible = false
    }

    MediaPopup {
        id: mediaMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.mediaVisible
        xOffset: root.mediaX
        onCloseRequested: Services.ShellData.mediaVisible = false
    }

    UpdatesPopup {
        id: updatesMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.updatesVisible
        xOffset: root.updatesX
        onCloseRequested: Services.ShellData.updatesVisible = false
    }

    MicPopup {
        id: micMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.micVisible
        xOffset: root.micX
        onCloseRequested: Services.ShellData.micVisible = false
    }
    
    VolumePopup {
        id: volumeMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.volumeVisible
        xOffset: root.volumeX
        onCloseRequested: Services.ShellData.volumeVisible = false
    }

    // ── Control Center Popup ─────────────────────────────────
    ControlCenter {
        id: cc
        screen: Services.MonitorService.primaryScreen
        visible: Services.ShellData.ccVisible
        onCloseRequested: Services.ShellData.ccVisible = false
    }

    // ── Notification Center Popup ────────────────────────────
    NotificationCenter {
        id: nc
        screen: Services.MonitorService.primaryScreen
        visible: Services.ShellData.ncVisible
        onCloseRequested: Services.ShellData.ncVisible = false
    }


    AppLauncher {
        id: al
        screen: Services.MonitorService.primaryScreen
        visible: Services.ShellData.alVisible
        onCloseRequested: Services.ShellData.alVisible = false
    }

    WallpaperPopup {
        id: wp
        screen: Services.MonitorService.primaryScreen
        visible: Services.ShellData.wallpaperVisible
        onCloseRequested: Services.ShellData.wallpaperVisible = false
    }

    NotificationPopup { 
        screen: Services.MonitorService.primaryScreen
    }

    ScreenshotMenu {
        id: sm
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.screenshotVisible
        onCloseRequested: Services.ShellData.screenshotVisible = false
    }

    Components.TrayMenu {
        id: trayMenu
        visible: false
        menuHandle: null
    }

    // ── Top Bar ──────────────────────────────────────────────
    // Defined AFTER popups so it stays on top on the same layer (Top)
    Bar {
        id: topBar
        screen: Services.MonitorService.primaryScreen
        trayMenu: trayMenu
        logoutVisible: lp.visible

        onToggleMicMenu: (x) => {
            let target = !Services.ShellData.micVisible
            root.closeAllPopups()
            root.micX = x
            Services.ShellData.micVisible = target
        }

        onToggleControlCenter: () => {
            let target = !Services.ShellData.ccVisible
            root.closeAllPopups()
            Services.ShellData.ccVisible = target
        }

        onToggleNotificationCenter: () => {
            let target = !Services.ShellData.ncVisible
            root.closeAllPopups()
            Services.ShellData.ncVisible = target
        }

        onToggleCalendar: (x) => {
            let target = !Services.ShellData.calVisible
            root.closeAllPopups()
            root.calX = x
            Services.ShellData.calVisible = target
        }

        onToggleWifiMenu: (x) => {
            let target = !Services.ShellData.trafficVisible
            root.closeAllPopups()
            root.trafficX = x
            Services.ShellData.trafficVisible = target
        }

        onToggleRamMenu: (x) => {
            let target = !Services.ShellData.ramVisible
            root.closeAllPopups()
            root.ramX = x
            Services.ShellData.ramVisible = target
        }

        onToggleCpuMenu: (x) => {
            let target = !Services.ShellData.cpuVisible
            root.closeAllPopups()
            root.cpuX = x
            Services.ShellData.cpuVisible = target
        }

        onToggleGpuMenu: (x) => {
            let target = !Services.ShellData.gpuVisible
            root.closeAllPopups()
            root.gpuX = x
            Services.ShellData.gpuVisible = target
        }

        onToggleTempMenu: (x) => {
            let target = !Services.ShellData.tempVisible
            root.closeAllPopups()
            root.tempX = x
            Services.ShellData.tempVisible = target
        }

        onToggleMediaMenu: (x) => {
            let target = !Services.ShellData.mediaVisible
            root.closeAllPopups()
            root.mediaX = x
            Services.ShellData.mediaVisible = target
        }

        onToggleUpdatesMenu: (x) => {
            let target = !Services.ShellData.updatesVisible
            root.closeAllPopups()
            root.updatesX = x
            Services.ShellData.updatesVisible = target
        }

        onToggleVolumeMenu: (x) => {
            let target = !Services.ShellData.volumeVisible
            root.closeAllPopups()
            root.volumeX = x
            Services.ShellData.volumeVisible = target
        }
    }

    // Defined LAST so it stays on top of everything
    LogoutPopup {
        id: lp
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.logoutVisible
        onCloseRequested: Services.ShellData.logoutVisible = false
    }
}
