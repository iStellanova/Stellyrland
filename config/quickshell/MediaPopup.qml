import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: mediaWindow

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    readonly property real windowWidth: 330
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-popups"

    property bool hasMouseEntered: false
    property bool pinned: false
    property var activePlayerButton: null
    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        }
    }
    
    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
    }
    
    margins.top: open ? 10 : -10
    visible: open || mediaContent.opacity > 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: mediaWindow.visible && hasMouseEntered && !mediaHover.hovered && !pinned
        repeat: true
        onTriggered: mediaWindow.closeRequested()
    }

    HoverHandler {
        id: mediaHover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    implicitWidth: windowWidth
    implicitHeight: heightWrapper.height + 28

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
        id: mediaContent
        anchors.fill: parent
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: mediaWindow.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
        }

        Components.CavaVisualizer {
            anchors.fill: parent
            anchors.margins: 10
            visible: Services.Music.player !== null
        }

        Item {
            id: heightWrapper
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            height: mainCol.implicitHeight
            clip: true

            Behavior on height {
                NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id: mainCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Services.Colors.spacingLarge

                Item {
                    id: selectorContainer
                    width: selectorRow.implicitWidth
                    Layout.preferredWidth: width
                    Layout.preferredHeight: visible ? 26 : 0
                    visible: Services.Music.players.length > 1
                    clip: true

                    Behavior on width {
                        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        id: playerSelectionBox
                        anchors.verticalCenter: parent.verticalCenter
                        height: 26
                        radius: Services.Colors.radiusSmall
                        color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12)
                        border.width: 1
                        border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.05)

                        property var targetButton: mediaWindow.activePlayerButton
                        
                        opacity: targetButton ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                        
                        x: targetButton ? selectorRow.x + targetButton.x : 0
                        width: targetButton ? targetButton.width : 0

                        Behavior on x { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                        Behavior on width { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                    }

                    RowLayout {
                        id: selectorRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Services.Colors.spacingSmall
                        
                        Repeater {
                            model: Services.Music.players
                            
                            Rectangle {
                                id: playerBtn
                                required property var modelData
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 26
                                radius: Services.Colors.radiusSmall
                                
                                readonly property bool isSelected: Services.Music.player === modelData
                                
                                color: {
                                    if (btnMouse.pressed) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.3)
                                    if (btnMouse.containsMouse) return Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.1)
                                    return "transparent"
                                }
                                
                                scale: btnMouse.pressed ? 0.95 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                                Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                                function updateSelected() {
                                    if (isSelected) {
                                        mediaWindow.activePlayerButton = playerBtn
                                    } else if (mediaWindow.activePlayerButton === playerBtn) {
                                        mediaWindow.activePlayerButton = null
                                    }
                                }

                                onIsSelectedChanged: updateSelected()
                                Component.onCompleted: updateSelected()
                                Component.onDestruction: if (mediaWindow.activePlayerButton === playerBtn) mediaWindow.activePlayerButton = null
                                
                                Components.ShadowText {
                                    anchors.centerIn: parent
                                    text: {
                                        if (!modelData || !modelData.identity) return "󰝚"
                                        let id = modelData.identity.toLowerCase()
                                        if (id.includes("spotify")) return ""
                                        if (id.includes("firefox") || id.includes("chrome") || id.includes("browser")) return "󰈹"
                                        if (id.includes("vlc")) return "󰕼"
                                        if (id.includes("mpv")) return ""
                                        return "󰝚"
                                    }
                                    font.pixelSize: 14
                                    color: isSelected ? Services.Colors.primary : Services.Colors.mainText
                                }
                                
                                MouseArea {
                                    id: btnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Services.Music.manualPlayer = modelData
                                }
                                
                                Components.ShadowText {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: -1
                                    text: "."
                                    visible: modelData.playbackState === MprisPlaybackState.Playing
                                    color: isSelected ? Services.Colors.primary : Services.Colors.mainText
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Components.ShadowText {
                        text: {
                            let p = Services.Music.player
                            return (p && p.identity) ? p.identity : "Media Player"
                        }
                        font.pixelSize: Services.Colors.fontSizeLarge
                        font.bold: true
                        color: Services.Colors.primary
                        Layout.alignment: Qt.AlignLeft
                    }
                    
                    
                    Item { Layout.fillWidth: true }
                    
                    Components.PinButton {
                        pinned: mediaWindow.pinned
                        onToggled: mediaWindow.pinned = !mediaWindow.pinned
                    }

                    Components.ShadowText {
                        text: {
                            let p = Services.Music.player
                            if (!p) return ""
                            return p.playbackState === MprisPlaybackState.Playing ? "▶" : "⏸"
                        }
                        font.pixelSize: Services.Colors.fontSizeLarge
                        color: Services.Colors.mainText
                        opacity: 0.6
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Services.Colors.border
                }
                
                Components.MediaPlayer {
                    framed: false
                    Layout.fillWidth: true
                    visible: Services.Music.player !== null
                }

                Components.ShadowText {
                    text: "No media player active"
                    color: Services.Colors.dim
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: Services.Colors.spacingXLarge
                    visible: Services.Music.player === null
                }
            }
        }
    }
}
