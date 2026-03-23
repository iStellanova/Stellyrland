//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQml
import "components" as Components
import "services" as Services

// QuickShell entry point — orchestrates all windows
Scope {
    id: root

    // ── State ────────────────────────────────────────────────
    // Visibility is managed directly via Services.ShellData
    
    property var popupOffsets: ({})

    property var pinnablePopups: [
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

    function closeAllPopups() {
        pinnablePopups.forEach(p => {
            if (!p.component.pinned) Services.ShellData[p.prop] = false
        })
        
        // Non-pinnable ones always close
        Services.ShellData.ccVisible = false
        Services.ShellData.ncVisible = false
        Services.ShellData.wallpaperVisible = false
        Services.ShellData.logoutVisible = false
        Services.ShellData.screenshotVisible = false
        Services.ShellData.settingsVisible = false
        Services.ShellData.shortcutsVisible = false
        Services.ShellData.overviewVisible = false

        trayMenu.menuHandle = null
    }


    function togglePopup(prop, x) {
        let target = !Services.ShellData[prop]
        closeAllPopups()
        if (x !== undefined) {
            let next = Object.assign({}, popupOffsets)
            next[prop] = x
            popupOffsets = next
        }
        Services.ShellData[prop] = target
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
        function toggleWallpaperSelector() {
            root.togglePopup("wallpaperVisible")
        }

        function toggleLogout() {
            root.togglePopup("logoutVisible")
        }
        
        function toggleScreenshot() {
            root.togglePopup("screenshotVisible")
        }

        function toggleShortcuts() {
            root.togglePopup("shortcutsVisible")
        }

        function toggleOverview() {
            root.togglePopup("overviewVisible")
        }

        function triggerDelayedScreenshot() {
            sm.triggerNoTimer()
        }
    }

    // ── Calendar Popup ────────────────────────────
    CalendarPopup {
        id: cal
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.calVisible
        xOffset: root.popupOffsets["calVisible"] ?? 0
        onCloseRequested: Services.ShellData.calVisible = false
    }

    // ── Traffic Popup ────────────────────────────────
    TrafficPopup {
        id: trafficMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.trafficVisible
        xOffset: root.popupOffsets["trafficVisible"] ?? 0
        onCloseRequested: Services.ShellData.trafficVisible = false
    }

    // ── RAM Popup ─────────────────────────────────
    RamPopup {
        id: ramMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.ramVisible
        xOffset: root.popupOffsets["ramVisible"] ?? 0
        onCloseRequested: Services.ShellData.ramVisible = false
    }

    // ── CPU Popup ─────────────────────────────────
    CpuPopup {
        id: cpuMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.cpuVisible
        xOffset: root.popupOffsets["cpuVisible"] ?? 0
        onCloseRequested: Services.ShellData.cpuVisible = false
    }

    // ── GPU Popup ─────────────────────────────────
    GpuPopup {
        id: gpuMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.gpuVisible
        xOffset: root.popupOffsets["gpuVisible"] ?? 0
        onCloseRequested: Services.ShellData.gpuVisible = false
    }

    // ── Temp Popup ─────────────────────────────────
    TempPopup {
        id: tempMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.tempVisible
        xOffset: root.popupOffsets["tempVisible"] ?? 0
        onCloseRequested: Services.ShellData.tempVisible = false
    }

    MediaPopup {
        id: mediaMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.mediaVisible
        xOffset: root.popupOffsets["mediaVisible"] ?? 0
        onCloseRequested: Services.ShellData.mediaVisible = false
    }

    UpdatesPopup {
        id: updatesMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.updatesVisible
        xOffset: root.popupOffsets["updatesVisible"] ?? 0
        onCloseRequested: Services.ShellData.updatesVisible = false
    }

    MicPopup {
        id: micMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.micVisible
        xOffset: root.popupOffsets["micVisible"] ?? 0
        onCloseRequested: Services.ShellData.micVisible = false
    }
    
    VolumePopup {
        id: volumeMenu
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.volumeVisible
        xOffset: root.popupOffsets["volumeVisible"] ?? 0
        onCloseRequested: Services.ShellData.volumeVisible = false
    }
    // ── Control Center Popup ─────────────────────────────────
    ControlCenter {
        id: cc
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.ccVisible
        onCloseRequested: Services.ShellData.ccVisible = false
    }

    // ── Notification Center Popup ────────────────────────────
    NotificationCenter {
        id: nc
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.ncVisible
        onCloseRequested: Services.ShellData.ncVisible = false
    }

    WallpaperPopup {
        id: wp
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.wallpaperVisible
        onCloseRequested: Services.ShellData.wallpaperVisible = false
    }

    SettingsPopup {
        id: sp
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.settingsVisible
        onCloseRequested: Services.ShellData.settingsVisible = false
    }

    Instantiator {
        id: wallInstantiator
        model: Quickshell.screens
        delegate: WallpaperBackground {
            screen: modelData
            onClicked: root.closeAllPopups()
        }
    }

    Connections {
        target: Services.WallpaperService
        function onWallpaperChanged(path, isVideo, framePath) {
            for (let i = 0; i < wallInstantiator.count; i++) {
                let obj = wallInstantiator.objectAt(i)
                if (obj) {
                    obj.transitionTo(path, isVideo, framePath)
                }
            }
        }
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
        menuHandle: null
    }

    ShortcutPopup {
        id: sp_cheat
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.shortcutsVisible
        onCloseRequested: Services.ShellData.shortcutsVisible = false
    }

    // ── Top Bar ──────────────────────────────────────────────
    // Defined AFTER popups so it stays on top on the same layer (Top)
    Bar {
        id: topBar
        screen: Services.MonitorService.primaryScreen
        trayMenu: trayMenu
        logoutVisible: lp.visible

        onToggleMicMenu: (x) => root.togglePopup("micVisible", x)
        onToggleControlCenter: () => root.togglePopup("ccVisible")
        onToggleNotificationCenter: () => root.togglePopup("ncVisible")
        onToggleCalendar: (x) => root.togglePopup("calVisible", x)
        onToggleWifiMenu: (x) => root.togglePopup("trafficVisible", x)
        onToggleRamMenu: (x) => root.togglePopup("ramVisible", x)
        onToggleCpuMenu: (x) => root.togglePopup("cpuVisible", x)
        onToggleGpuMenu: (x) => root.togglePopup("gpuVisible", x)
        onToggleTempMenu: (x) => root.togglePopup("tempVisible", x)
        onToggleMediaMenu: (x) => root.togglePopup("mediaVisible", x)
        onToggleUpdatesMenu: (x) => root.togglePopup("updatesVisible", x)
        onToggleVolumeMenu: (x) => root.togglePopup("volumeVisible", x)
    }

    // Defined LAST so it stays on top of everything
    LogoutPopup {
        id: lp
        screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.logoutVisible
        onCloseRequested: Services.ShellData.logoutVisible = false
    }

    Components.OverviewMenu {
        id: om
        open: Services.ShellData.overviewVisible
        onCloseRequested: Services.ShellData.overviewVisible = false
    }
}
