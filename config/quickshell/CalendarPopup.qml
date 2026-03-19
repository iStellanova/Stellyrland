import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: calWindow

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    readonly property real windowWidth: 330
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-popups"


    property bool hasMouseEntered: false
    property bool pinned: false
    onVisibleChanged: if (!visible) {
        hasMouseEntered = false
    }
    
    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
    }
    
    margins.top: open ? 10 : -10
    visible: open || calContent.opacity > 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: calWindow.visible && hasMouseEntered && !calHover.hovered && !pinned
        repeat: true
        onTriggered: calWindow.closeRequested()
    }

    HoverHandler {
        id: calHover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    implicitWidth: windowWidth
    implicitHeight: mainCol.implicitHeight + 32

    exclusiveZone: 0

    anchors {
        top: true
        left: true
        right: false
        bottom: false
    }
    
    margins.left: xOffset - (windowWidth / 2)

    color: "transparent"

    Rectangle {
        id: calContent
        anchors.fill: parent
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: calWindow.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: Services.Colors.spacingLarge

            RowLayout {
                Layout.fillWidth: true
                Components.ShadowText {
                    text: "Calendar"
                    font.pixelSize: 13
                    font.bold: true
                    color: Services.Colors.primary
                }
                Item { Layout.fillWidth: true }
                Components.PinButton {
                    pinned: calWindow.pinned
                    onToggled: calWindow.pinned = !calWindow.pinned
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Services.Colors.border
            }

            Components.CalendarWidget {
                id: calendarLayout
                Layout.fillWidth: true
            }
        }
    }
}
