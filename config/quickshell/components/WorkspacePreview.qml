import Quickshell
import Quickshell.Io
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import "../services" as Services

PanelWindow {
    id: window

    property int workspaceId: -1
    property real xOffset: 0
    property bool open: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-popups"
    
    // Position under the workspace button
    anchors {
        top: true
        left: true
    }
    
    margins.top: 8 // Match other popups
    margins.left: Math.max(12, Math.min(xOffset - (windowWidth / 2), Services.MonitorService.primaryScreen.width - windowWidth - 12))

    readonly property real windowWidth: 320
    readonly property real aspectRatio: currentMonitor.height / currentMonitor.width || Services.MonitorService.primaryScreen.height / Services.MonitorService.primaryScreen.width

    implicitWidth: windowWidth
    implicitHeight: Math.round((windowWidth - 24) * aspectRatio + 24)
    
    visible: open || content.opacity > 0
    color: "transparent"

    property var windows: []
    property var monitors: []
    property var workspaces: []

    readonly property var currentWorkspace: {
        for (let ws of workspaces) {
            if (ws.id === workspaceId) return ws
        }
        return ({})
    }

    readonly property var currentMonitor: {
        let monName = currentWorkspace.monitor
        if (!monName) return ({})
        for (let mon of monitors) {
            if (mon.name === monName) return mon
        }
        return ({})
    }

    Process {
        id: dataProc
        command: ["bash", "-c", "echo \"{\\\"monitors\\\": $(hyprctl monitors -j), \\\"workspaces\\\": $(hyprctl workspaces -j), \\\"clients\\\": $(hyprctl clients -j)}\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(this.text.trim())
                    window.monitors = data.monitors
                    window.workspaces = data.workspaces
                    window.windows = data.clients.filter(w => w.workspace.id === window.workspaceId && w.mapped)
                } catch (e) {
                    console.error("Failed to parse hyprctl data:", e)
                }
            }
        }
    }

    onWorkspaceIdChanged: if (open && workspaceId !== -1) dataProc.running = true
    onOpenChanged: {
        if (open && workspaceId !== -1) {
            dataProc.running = true
        } else if (!open) {
            window.windows = []
        }
    }

    // Robust Icon Resolution
    function getIconName(className) {
        if (!className) return ""
        let lower = className.toLowerCase()
        
        // Handle common overrides
        if (lower === "zen") return "zen-browser"
        if (lower === "spotify") return "spotify-client"
        if (lower.includes("firefox")) return "firefox"
        if (lower.includes("librewolf")) return "librewolf"
        if (lower === "discord") return "discord"
        
        // Default to the original class name to preserve case sensitivity
        return className
    }

    Rectangle {
        id: content
        anchors.fill: parent
        radius: Services.Colors.radiusNormal
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: window.open ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal } }

        // The Mini-Map
        Rectangle {
            id: miniMap
            anchors.top: parent.top
            anchors.topMargin: 12 // Even 12px padding on all sides
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 24
            
            readonly property var reserved: window.currentMonitor.reserved || [0, 0, 0, 0]
            readonly property real usableW: window.currentMonitor.width ? (window.currentMonitor.width - reserved[0] - reserved[2]) : Services.MonitorService.primaryScreen.width
            readonly property real usableH: window.currentMonitor.height ? (window.currentMonitor.height - reserved[1] - reserved[3]) : Services.MonitorService.primaryScreen.height
            
            height: width * (usableH / usableW)
            
            radius: 4
            color: "transparent" // Remove ghostly background
            border.width: 1
            border.color: Qt.rgba(Services.Colors.border.r, Services.Colors.border.g, Services.Colors.border.b, 0.1)
            clip: true
            visible: window.windows.length > 0
            
            opacity: window.windows.length > 0 ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal } }

            Repeater {
                model: window.windows
                delegate: Rectangle {
                    readonly property real monX: window.currentMonitor.x || 0
                    readonly property real monY: window.currentMonitor.y || 0
                    readonly property real resX: miniMap.reserved[0] || 0
                    readonly property real resY: miniMap.reserved[1] || 0
                    
                    readonly property real scaleX: miniMap.width / miniMap.usableW
                    readonly property real scaleY: miniMap.height / miniMap.usableH
                    
                    x: (modelData.at[0] - monX - resX) * scaleX
                    y: (modelData.at[1] - monY - resY) * scaleY
                    width: Math.max(modelData.size[0] * scaleX, 4)
                    height: Math.max(modelData.size[1] * scaleY, 4)
                    
                    radius: 3
                    color: Services.Colors.primaryContainer
                    border.width: 1
                    border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.4)

                    // Fallback letter (Volume Mixer style)
                    ShadowText {
                        anchors.centerIn: parent
                        text: modelData.class ? modelData.class.charAt(0).toUpperCase() : "󰝚"
                        font.pixelSize: Math.min(parent.height * 0.5, 12)
                        font.weight: Font.Bold
                        color: Services.Colors.primary
                        opacity: 0.8
                        visible: appIcon.status !== Image.Ready
                    }

                    Image {
                        id: appIcon
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.7, 24)
                        height: Math.min(parent.height * 0.7, 24)
                        source: modelData.class ? "image://icon/" + window.getIconName(modelData.class) : ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        opacity: 0.9
                        visible: status === Image.Ready
                        
                        onStatusChanged: {
                            if (status === Image.Ready) {
                                parent.color = Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
                            }
                        }
                    }
                }
            }
        }
    }
}
