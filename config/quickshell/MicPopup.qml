import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: window

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    readonly property real windowWidth: 200
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-popups"

    property bool hasMouseEntered: false
    property bool pinned: false
    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        }
    }
    
    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
    }
    
    margins.top: open ? 10 : -10
    visible: open || content.opacity > 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: window.visible && hasMouseEntered && !hover.hovered && !pinned
        repeat: true
        onTriggered: window.closeRequested()
    }

    HoverHandler {
        id: hover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    implicitWidth: windowWidth
    implicitHeight: mainCol.implicitHeight + 28

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
        id: content
        anchors.fill: parent
        radius: Services.Colors.radiusNormal
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: window.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: Services.Colors.spacingNormal

            RowLayout {
                Layout.fillWidth: true
                Components.ShadowText {
                    text: "Mic Usage"
                    font.pixelSize: 13
                    font.bold: true
                    color: Services.Colors.primary
                }
                
                
                Item { Layout.fillWidth: true }
                
                Components.PinButton {
                    pinned: window.pinned
                    onToggled: window.pinned = !window.pinned
                }

                Components.ShadowText {
                    text: Services.ShellData.micApps.length
                    font.pixelSize: 11
                    color: Services.Colors.dim
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Services.Colors.border
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Colors.spacingSmall
                
                Repeater {
                    model: Services.ShellData.micApps
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: Services.Colors.spacingNormal
                        
                        Components.ShadowText {
                            text: "󰍬"
                            font.pixelSize: 12
                            color: Services.Colors.primary
                        }
                        
                        Components.ShadowText {
                            text: modelData
                            font.pixelSize: 11
                            color: Services.Colors.mainText
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }
                
                Components.ShadowText {
                    text: "No applications active"
                    visible: Services.ShellData.micApps.length === 0
                    font.pixelSize: 11
                    color: Services.Colors.dim
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: Services.Colors.spacingNormal
                }
            }
        }
    }
}
