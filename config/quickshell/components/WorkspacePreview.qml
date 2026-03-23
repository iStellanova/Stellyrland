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
    margins.left: Math.max(12, Math.min(xOffset - (window.implicitWidth / 2), Services.MonitorService.primaryScreen.width - window.implicitWidth - 12))

    readonly property real maxDimension: 300
    
    // Calculate dimensions so the inner workspace representation fits within a 300px bounding box
    // while maintaining a tight 12px padding on all sides.
    readonly property real innerW: aspectRatio <= 1.0 ? (maxDimension - 24) : Math.round((maxDimension - 24) / aspectRatio)
    readonly property real innerH: Math.round(innerW * aspectRatio)
    
    implicitWidth: innerW + 24
    implicitHeight: innerH + 24
    
    // Scale the minimap to fill the available space
    readonly property real previewWidth: innerW
    
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
    
    readonly property real monitorW: currentMonitor.width ? (currentMonitor.transform % 2 === 0 ? currentMonitor.width : currentMonitor.height) : Services.MonitorService.primaryScreen.width
    readonly property real monitorH: currentMonitor.height ? (currentMonitor.transform % 2 === 0 ? currentMonitor.height : currentMonitor.width) : Services.MonitorService.primaryScreen.height
    readonly property real aspectRatio: monitorH / monitorW

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
            readonly property real usableW: window.monitorW - reserved[0] - reserved[2]
            readonly property real usableH: window.monitorH - reserved[1] - reserved[3]
            
            height: width * (usableH / usableW)
            
            radius: 4
            color: "transparent"
            border.width: 0 // Remove redundant inner border
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
                    
                    radius: 8
                    color: !appIcon.isFallback 
                        ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
                        : Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    AppIcon {
                        id: appIcon
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.6, 28)
                        height: Math.min(parent.height * 0.6, 28)
                        iconName: modelData["class"]
                        fallbackText: modelData["class"] || modelData.title || "󰝚"
                        iconBgColor: "transparent"
                        fallbackBgColor: "transparent"
                        fallbackBorderWidth: 0
                        iconBorderWidth: 0
                        opacity: 0.9
                    }
                }
            }
        }
    }
}
