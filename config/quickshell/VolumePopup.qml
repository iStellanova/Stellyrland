import Quickshell
import Quickshell.Services.Pipewire
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
    readonly property real windowWidth: 330
    
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
            spacing: Services.Colors.spacingLarge

            // ── Header ───────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Components.ShadowText {
                    text: "Volume Control"
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
                    text: Services.ShellData.appVolumesModel.count + " apps"
                    font.pixelSize: 11
                    color: Services.Colors.dim
                    visible: Services.ShellData.appVolumesModel.count > 0
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Services.Colors.border
            }

            // ── Master Volume ────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Colors.spacingSmall

                Components.ShadowText {
                    text: "Master"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: Services.Colors.mainText
                }

                Components.SliderRow {
                    Layout.fillWidth: true
                    value: Services.ShellData.volume
                    muted: Services.ShellData.muted
                    onValueMoved: v => Services.ShellData.setVolume(v)
                    onIconClicked: Services.ShellData.toggleMute()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Services.Colors.border
                visible: Services.ShellData.appVolumesModel.count > 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Colors.spacingLarge
                visible: Services.ShellData.appVolumesModel.count > 0

                Repeater {
                    model: Services.ShellData.appVolumesModel
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Services.Colors.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Services.Colors.spacingNormal

                            // Application Icon
                            Rectangle {
                                implicitWidth: 18; implicitHeight: 18
                                color: Services.Colors.primaryContainer
                                border.width: 1
                                border.color: Services.Colors.primary
                                radius: 4
                                
                                Components.ShadowText {
                                    anchors.centerIn: parent
                                    text: model.name ? model.name.charAt(0).toUpperCase() : "󰝚"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: Services.Colors.primary
                                    // This is the baseline, always there but covered if icon is ready
                                }

                                Image {
                                    id: appIcon
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: model.icon ? "image://icon/" + model.icon : ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    visible: status === Image.Ready
                                    
                                    // Make sure it covers the background color if it has its own
                                    onStatusChanged: {
                                        if (status === Image.Ready) {
                                            parent.color = "transparent"
                                            parent.border.width = 0
                                        } else if (status === Image.Error) {
                                            // Ensure it stays hidden on error so the letter fallback shows
                                            visible = false
                                        }
                                    }
                                }
                            }

                            Components.ShadowText {
                                text: model.name
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: Services.Colors.mainText
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        property var appNode: {
                            let _ = Pipewire.nodes.values
                            return Services.ShellData.getAppNode(model.pwId)
                        }

                        Components.SliderRow {
                            Layout.fillWidth: true
                            value: appNode && appNode.audio ? appNode.audio.volume * 100 : model.volume
                            muted: appNode && appNode.audio ? appNode.audio.muted : model.muted
                            onValueMoved: v => {
                                if (appNode && appNode.audio) appNode.audio.volume = v / 100
                                else Services.ShellData.setAppVolume(model.id, v)
                            }
                            onIconClicked: {
                                if (appNode && appNode.audio) appNode.audio.muted = !appNode.audio.muted
                                else Services.ShellData.toggleAppMute(model.id)
                            }
                        }
                    }
                }
            }
            
            Components.ShadowText {
                text: "No applications playing audio"
                visible: Services.ShellData.appVolumesModel.count === 0
                font.pixelSize: 11
                color: Services.Colors.dim
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Services.Colors.spacingNormal
            }
        }
    }
}
