import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import Quickshell.Hyprland
import "." as Components

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-tray"

    property var menuHandle // QsMenuHandle
    property int xOffset: 0
    property bool open: menuHandle !== null
    property bool hasMouseEntered: false

    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        }
    }

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: root.visible && hasMouseEntered && !hover.hovered
        repeat: true
        onTriggered: root.menuHandle = null
    }

    HoverHandler {
        id: hover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    exclusiveZone: 0
    focusable: false

    HyprlandFocusGrab {
        id: focusGrab
        active: root.visible
        windows: [root]
    }

    Connections {
        target: focusGrab
        function onActiveChanged() {
            if (!focusGrab.active) root.menuHandle = null
        }
    }

    anchors {
        top: true
        left: true
    }

    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
    }

    margins.top: open ? Services.Colors.popupMargin : Services.Colors.popupHideOffset
    margins.left: xOffset

    color: "transparent"
    
    visible: open || contentRect.opacity > 0

    implicitWidth: contentRect.implicitWidth
    implicitHeight: contentRect.implicitHeight

    Rectangle {
        id: contentRect
        radius: Services.Colors.radiusNormal
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true
        
        opacity: root.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
        }

        implicitWidth: Math.max(200, contentCol.implicitWidth + 16)
        implicitHeight: contentCol.implicitHeight + 16

        QsMenuOpener {
            id: opener
            menu: root.menuHandle || null
        }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 8
            spacing: Services.Colors.spacingSmall

            Repeater {
                model: opener.children

                delegate: Components.TrayItem {
                    entry: modelData
                    Layout.fillWidth: true
                    onTriggered: root.menuHandle = null
                }
            }
        }
    }
    
    // Backup auto-close when clicking outside
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.menuHandle = null
    }
}
