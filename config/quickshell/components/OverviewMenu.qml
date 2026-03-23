import Quickshell
import Quickshell.Io
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../services" as Services

PanelWindow {
    id: window

    property bool open: false
    signal closeRequested()

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-overview"
    WlrLayershell.exclusiveZone: -1

    anchors {
        top: true; bottom: true; left: true; right: true
    }
    
    color: Qt.rgba(1, 1, 1, 0.01)
    visible: open

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "transparent"
        z: -1
    }

    ListModel { id: windowsModel }
    property var monitorsData: []
    property var workspacesData: []

    Timer {
        id: syncTimer
        interval: 120
        repeat: true
        running: window.open
        onTriggered: if (!dataProc.running) dataProc.running = true
    }

    Process {
        id: dataProc
        command: ["bash", "-c", "echo \"{\\\"monitors\\\": $(hyprctl monitors -j), \\\"workspaces\\\": $(hyprctl workspaces -j), \\\"clients\\\": $(hyprctl clients -j)}\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (!this.text) return
                try {
                    let data = JSON.parse(this.text.trim())
                    if (data.monitors) window.monitorsData = data.monitors
                    if (data.workspaces) window.workspacesData = data.workspaces
                    if (data.clients) {
                        updateWindowsModel(data.clients.filter(w => w.mapped))
                    }
                } catch (e) {
                    console.error("Failed to parse hyprctl data in OverviewMenu:", e)
                }
            }
        }
    }

    function updateWindowsModel(clients) {
        let currentAddresses = {}
        for (let i = 0; i < clients.length; i++) {
            let c = clients[i]
            let addr = c.address.toString()
            currentAddresses[addr] = true
            
            let found = false
            for (let j = 0; j < windowsModel.count; j++) {
                if (windowsModel.get(j).address === addr) {
                    windowsModel.set(j, {
                        address: addr,
                        rectX: c.at[0] || 0,
                        rectY: c.at[1] || 0,
                        rectW: c.size[0] || 0,
                        rectH: c.size[1] || 0,
                        workspaceId: (c.workspace && c.workspace.id) || 0,
                        title: c.title || "",
                        class: c.class || ""
                    })
                    found = true
                    break
                }
            }
            
            if (!found) {
                windowsModel.append({
                    address: addr,
                    rectX: c.at[0] || 0,
                    rectY: c.at[1] || 0,
                    rectW: c.size[0] || 0,
                    rectH: c.size[1] || 0,
                    workspaceId: (c.workspace && c.workspace.id) || 0,
                    title: c.title || "",
                    class: c.class || ""
                })
            }
        }
        
        for (let i = windowsModel.count - 1; i >= 0; i--) {
            if (!currentAddresses[windowsModel.get(i).address]) {
                windowsModel.remove(i)
            }
        }
    }

    onOpenChanged: {
        if (open) {
            if (!dataProc.running) dataProc.running = true
        } else {
            windowsModel.clear()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Services.ShellData.overviewVisible = false
    }

    Item {
        id: contentContainer
        anchors.fill: parent

        opacity: window.open ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }

        scale: window.open ? 1.0 : 1.1
        Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }
        
        GridLayout {
            id: wsGrid
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.94, 1800)
            height: Math.min(parent.height * 0.85, 1000)
            
            readonly property int count: wsRepeater.count || 1
            
            columns: {
                let bestC = 1
                let maxDim = 0
                let n = count
                let w = width
                let h = height
                let gap = columnSpacing
                
                for (let c = 1; c <= n; c++) {
                    let r = Math.ceil(n / c)
                    let cw = (w - (gap * (c - 1))) / c
                    let ch = (h - (gap * (r - 1))) / r
                    let dim = Math.min(cw, ch)
                    if (dim > maxDim) {
                        maxDim = dim
                        bestC = c
                    }
                }
                return bestC
            }
            
            rows: Math.ceil(count / columns)
            
            columnSpacing: 48
            rowSpacing: 48

            readonly property real cellW: (width - (columnSpacing * (columns - 1))) / columns
            readonly property real cellH: (height - (rowSpacing * (rows - 1))) / rows
            readonly property real cellDim: Math.min(cellW, cellH, 600)

            Repeater {
                id: wsRepeater
                model: Hyprland.workspaces

                delegate: Item {
                    id: wsDelegate
                    required property HyprlandWorkspace modelData
                    
                    Layout.preferredWidth: wsGrid.cellDim
                    Layout.preferredHeight: wsGrid.cellDim
                    Layout.alignment: Qt.AlignCenter
                    
                    readonly property real monW: monMeta ? (monMeta.transform % 2 === 0 ? monMeta.width : monMeta.height) : Services.MonitorService.primaryScreen.width
                    readonly property real monH: monMeta ? (monMeta.transform % 2 === 0 ? monMeta.height : monMeta.width) : Services.MonitorService.primaryScreen.height

                    readonly property real maxInner: wsGrid.cellDim - 24
                    readonly property real innerW: monW >= monH ? maxInner : Math.round(maxInner * (monW / monH))
                    readonly property real innerH: monH > monW ? maxInner : Math.round(maxInner * (monH / monW))
                    
                    readonly property var wsMeta: {
                        for (let w of window.workspacesData) {
                            if (w.id === modelData.id) return w
                        }
                        return null
                    }
                    
                    readonly property var monMeta: {
                        if (!wsMeta || !wsMeta.monitor) return null
                        for (let m of window.monitorsData) {
                            if (m.name === wsMeta.monitor) return m
                        }
                        return null
                    }

                    visible: modelData.id > 0

                    Rectangle {
                        id: workspaceBox
                        anchors.centerIn: parent
                        width: innerW + 24
                        height: innerH + 24

                        radius: Services.Colors.radiusLarge
                        color: Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.6)
                        border.width: modelData.active ? 2 : 1
                        border.color: modelData.active ? Services.Colors.primary : Services.Colors.border

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.activate()
                                Services.ShellData.overviewVisible = false
                            }
                            onEntered: workspaceBox.color = Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.8)
                            onExited: workspaceBox.color = Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.6)
                        }

                        Repeater {
                            model: windowsModel

                            delegate: Rectangle {
                                visible: model.workspaceId === wsDelegate.modelData.id

                                readonly property real scaleX: innerW / (monW || 1)
                                readonly property real scaleY: innerH / (monH || 1)

                                x: 12 + (model.rectX - (monMeta ? monMeta.x : 0)) * scaleX
                                y: 12 + (model.rectY - (monMeta ? monMeta.y : 0)) * scaleY
                                width: Math.max(model.rectW * scaleX, 4)
                                height: Math.max(model.rectH * scaleY, 4)

                                Behavior on x { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                                Behavior on y { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                                Behavior on width { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                                Behavior on height { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }

                                radius: 8
                                color: {
                                    let base = !appIcon.isFallback 
                                        ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
                                        : Qt.rgba(1, 1, 1, 0.2)
                                    return windowMouseArea.containsMouse ? Qt.rgba(base.r, base.g, base.b, base.a + 0.1) : base
                                }
                                border.width: windowMouseArea.containsMouse ? 2 : 1
                                border.color: windowMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)

                                MouseArea {
                                    id: windowMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: {
                                        let addr = model.address.toString()
                                        if (addr.startsWith("0x")) addr = addr.substring(2)
                                        
                                        if (mouse.button === Qt.RightButton) {
                                            Services.ShellData.runCommand(["hyprctl", "dispatch", "closewindow", "address:0x" + addr])
                                            
                                            // Manual remove for instant feedback
                                            for (let i = 0; i < windowsModel.count; i++) {
                                                if (windowsModel.get(i).address === model.address) {
                                                    windowsModel.remove(i)
                                                    break
                                                }
                                            }
                                        } else {
                                            Services.ShellData.runCommand(["hyprctl", "dispatch", "focuswindow", "address:0x" + addr])
                                            Services.ShellData.overviewVisible = false
                                        }
                                    }
                                    onExited: {}
                                }

                                AppIcon {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: Math.min(parent.width * 0.6, 64)
                                    height: Math.min(parent.height * 0.6, 64)
                                    iconName: model.class
                                    fallbackText: model.class || "󰝚"
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
        }
    }


}
