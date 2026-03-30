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
    

    // ── Popup Registry & Meta ───────────────────────────────
    property var popupInstances: ({})
    function registerPopup(name, instance) {
        let p = popupInstances
        p[name] = instance
        popupInstances = p
    }
    readonly property var popupMeta: ({
        nix:      { width: 350, clamp: "both" },
        cal:      { width: 330, clamp: "right" },
        traffic:  { width: 400, clamp: "right" },
        ram:      { width: 330, clamp: "none" },
        cpu:      { width: 330, clamp: "none" },
        gpu:      { width: 330, clamp: "none" },
        temp:     { width: 330, clamp: "none" },
        media:    { width: 330, clamp: "none" },
        mic:      { width: 330, clamp: "none" },
        volume:   { width: 330, clamp: "none" },
        cc:       { width: 330, clamp: "left" },
        nc:       { width: 340, clamp: "right" }
    })

    function closeAllPopups(except) {
        let changes = {}
        // Close registered (pinnable) popups
        for (let name in popupInstances) {
            if (name === except) continue
            let inst = popupInstances[name]
            if (inst && inst.pinned) continue
            changes[name] = false
        }
        
        // Close others
        const others = ["wallpaper", "logout", "screenshot", "settings", "shortcuts", "overview"]
        others.forEach(name => {
            if (name !== except) changes[name] = false
        })

        Services.ShellData.updatePopups(changes)
        trayMenu.menuHandle = null
    }

    function togglePopup(name, x) {
        let target = !Services.ShellData.isPopupVisible(name)
        closeAllPopups(name)
        
        if (x !== undefined) {
            let finalX = x
            let meta = popupMeta[name]
            if (meta) {
                let screen = Services.MonitorService.primaryScreen
                let sw = (screen && screen.geometry) ? screen.geometry.width : (screen ? screen.width : 1920)
                let halfW = meta.width / 2 + 12 // Using 12 as default radius
                
                if (meta.clamp === "left") finalX = Math.max(32 + halfW, finalX)
                else if (meta.clamp === "right") finalX = Math.min(sw - 40 - halfW, finalX)
                else if (meta.clamp === "both") finalX = Math.max(40 + halfW, Math.min(sw - 40 - halfW, finalX))
            }
            Services.ShellData.setPopupOffset(name, Math.round(finalX))
        }
        Services.ShellData.setPopupVisible(name, target)
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
        function toggleWallpaperSelector() { root.togglePopup("wallpaper") }
        function toggleLogout()            { root.togglePopup("logout") }
        function toggleScreenshot()        { root.togglePopup("screenshot") }
        function toggleShortcuts()         { root.togglePopup("shortcuts") }
        function toggleOverview()          { root.togglePopup("overview") }
        function triggerDelayedScreenshot(){ sm.triggerNoTimer() }
    }

    // ── Bar-Aligned Popups ────────────────────────────
    CalendarPopup {
        id: cal; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("cal")
        xOffset: Services.ShellData.getPopupOffset("cal")
        onCloseRequested: Services.ShellData.setPopupVisible("cal", false)
        Component.onCompleted: root.registerPopup("cal", this)
    }

    TrafficPopup {
        id: trafficMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("traffic")
        xOffset: Services.ShellData.getPopupOffset("traffic")
        onCloseRequested: Services.ShellData.setPopupVisible("traffic", false)
        Component.onCompleted: root.registerPopup("traffic", this)
    }

    RamPopup {
        id: ramMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("ram")
        xOffset: Services.ShellData.getPopupOffset("ram")
        onCloseRequested: Services.ShellData.setPopupVisible("ram", false)
        Component.onCompleted: root.registerPopup("ram", this)
    }

    CpuPopup {
        id: cpuMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("cpu")
        xOffset: Services.ShellData.getPopupOffset("cpu")
        onCloseRequested: Services.ShellData.setPopupVisible("cpu", false)
        Component.onCompleted: root.registerPopup("cpu", this)
    }

    GpuPopup {
        id: gpuMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("gpu")
        xOffset: Services.ShellData.getPopupOffset("gpu")
        onCloseRequested: Services.ShellData.setPopupVisible("gpu", false)
        Component.onCompleted: root.registerPopup("gpu", this)
    }

    TempPopup {
        id: tempMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("temp")
        xOffset: Services.ShellData.getPopupOffset("temp")
        onCloseRequested: Services.ShellData.setPopupVisible("temp", false)
        Component.onCompleted: root.registerPopup("temp", this)
    }

    MediaPopup {
        id: mediaMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("media")
        xOffset: Services.ShellData.getPopupOffset("media")
        onCloseRequested: Services.ShellData.setPopupVisible("media", false)
        Component.onCompleted: root.registerPopup("media", this)
    }

    NixPopup {
        id: nixMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("nix")
        xOffset: Services.ShellData.getPopupOffset("nix")
        onCloseRequested: Services.ShellData.setPopupVisible("nix", false)
        Component.onCompleted: root.registerPopup("nix", this)
    }

    MicPopup {
        id: micMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("mic")
        xOffset: Services.ShellData.getPopupOffset("mic")
        onCloseRequested: Services.ShellData.setPopupVisible("mic", false)
        Component.onCompleted: root.registerPopup("mic", this)
    }
    
    VolumePopup {
        id: volumeMenu; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("volume")
        xOffset: Services.ShellData.getPopupOffset("volume")
        onCloseRequested: Services.ShellData.setPopupVisible("volume", false)
        Component.onCompleted: root.registerPopup("volume", this)
    }

    ControlCenter {
        id: cc; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("cc")
        xOffset: Services.ShellData.getPopupOffset("cc")
        onCloseRequested: Services.ShellData.setPopupVisible("cc", false)
        Component.onCompleted: root.registerPopup("cc", this)
    }

    NotificationCenter {
        id: nc; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("nc")
        xOffset: Services.ShellData.getPopupOffset("nc")
        onCloseRequested: Services.ShellData.setPopupVisible("nc", false)
        Component.onCompleted: root.registerPopup("nc", this)
    }

    WallpaperPopup {
        id: wp; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("wallpaper")
        onCloseRequested: Services.ShellData.setPopupVisible("wallpaper", false)
    }

    SettingsPopup {
        id: sp; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("settings")
        onCloseRequested: Services.ShellData.setPopupVisible("settings", false)
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
        id: sm; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("screenshot")
        onCloseRequested: Services.ShellData.setPopupVisible("screenshot", false)
    }

    Components.TrayMenu {
        id: trayMenu
        menuHandle: null
    }

    ShortcutPopup {
        id: sp_cheat; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("shortcuts")
        onCloseRequested: Services.ShellData.setPopupVisible("shortcuts", false)
    }

    // ── Top Bar ──────────────────────────────────────────────
    // Defined AFTER popups so it stays on top on the same layer (Top)
    Bar {
        id: topBar
        screen: Services.MonitorService.primaryScreen
        trayMenu: trayMenu
        logoutVisible: lp.visible

        onTogglePopup: (name, x) => root.togglePopup(name, x)
    }

    // Defined LAST so it stays on top of everything
    LogoutPopup {
        id: lp; screen: Services.MonitorService.primaryScreen
        open: Services.ShellData.isPopupVisible("logout")
        onCloseRequested: Services.ShellData.setPopupVisible("logout", false)
    }

    Components.OverviewMenu {
        id: om
        open: Services.ShellData.isPopupVisible("overview")
        onCloseRequested: Services.ShellData.setPopupVisible("overview", false)
    }
}
