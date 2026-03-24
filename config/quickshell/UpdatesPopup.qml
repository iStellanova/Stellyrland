import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "services" as Services
import "components" as Components

PanelWindow {
    id: updatesWindow

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    readonly property real windowWidth: 400 // Slightly wider to accommodate version strings
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-popups"

    property bool hasMouseEntered: false
    property bool pinned: false
    property var combinedModel: []
    function updateModel() {
        let combined = []
        for (let p of Services.ShellData.pacmanUpdateList) {
            combined.push({name: p.name, old: p.old, new: p.new, isAur: false})
        }
        for (let a of Services.ShellData.aurUpdateList) {
            combined.push({name: a.name, old: a.old, new: a.new, isAur: true})
        }
        combinedModel = combined
    }

    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        } else {
            updatesWindow.updateModel()
            Services.ShellData.refreshUpdateLists()
        }
    }

    Component.onCompleted: updateModel()
    
    Connections {
        target: Services.ShellData
        function onPacmanUpdateListChanged() { updatesWindow.updateModel() }
        function onAurUpdateListChanged() { updatesWindow.updateModel() }
    }
    
    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
    }
    
    margins.top: open ? 10 : -10
    visible: open || updatesContent.opacity > 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: updatesWindow.visible && hasMouseEntered && !updatesHover.hovered && !pinned
        repeat: true
        onTriggered: updatesWindow.closeRequested()
    }

    HoverHandler {
        id: updatesHover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    implicitWidth: windowWidth
    implicitHeight: Math.min(mainCol.implicitHeight + 32, 600)

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
        id: updatesContent
        anchors.fill: parent
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: updatesWindow.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: Services.Colors.spacingLarge

            RowLayout {
                Layout.fillWidth: true
                Components.ShadowText {
                    text: "Software Updates"
                    font.pixelSize: Services.Colors.fontSizeLarge
                    font.bold: true
                    color: Services.Colors.primary
                    Layout.alignment: Qt.AlignLeft
                }
                
                
                Item { Layout.fillWidth: true }
                
                Components.PinButton {
                    pinned: updatesWindow.pinned
                    onToggled: updatesWindow.pinned = !updatesWindow.pinned
                }

                Components.ShadowText {
                    text: (Services.ShellData.pacmanUpdateList.length + Services.ShellData.aurUpdateList.length) + " Pending"
                    color: Services.Colors.mainText
                    opacity: 0.6
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
                visible: Services.ShellData.pacmanUpdateList.length > 0 || Services.ShellData.aurUpdateList.length > 0

                // Combined List View
                ListView {
                    id: updatesList
                    Layout.fillWidth: true
                    implicitHeight: Math.min(contentHeight, 500)
                    clip: true
                    spacing: Services.Colors.spacingSmall
                    model: updatesWindow.combinedModel

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 38
                        radius: Services.Colors.radiusSmall
                        color: itemHover.hovered ? Qt.rgba(Services.Colors.surface.r, Services.Colors.surface.g, Services.Colors.surface.b, 0.5) : "transparent"
                        
                        HoverHandler { id: itemHover }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: Services.Colors.spacingNormal

                            Item {
                                implicitWidth: 16; implicitHeight: 16
                                Layout.alignment: Qt.AlignVCenter
                                
                                Components.ShadowText {
                                    anchors.fill: parent
                                    text: "󰮯"
                                    color: Services.Colors.mainText
                                    opacity: 0.7
                                    font.pixelSize: 14
                                    visible: !modelData.isAur
                                }

                                Image {
                                    id: aurLogo
                                    anchors.fill: parent
                                    source: Quickshell.shellDir + "/artixlinux-svgrepo-com.svg"
                                    sourceSize: Qt.size(32, 32)
                                    fillMode: Image.PreserveAspectFit
                                    visible: modelData.isAur
                                }

                                ColorOverlay {
                                    anchors.fill: aurLogo
                                    source: aurLogo
                                    color: Services.Colors.primary
                                    visible: aurLogo.visible
                                }
                            }

                            Components.ShadowText {
                                text: modelData.name
                                color: Services.Colors.mainText
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                font.bold: true
                            }

                            Components.ShadowText {
                                text: modelData.old + " 󰁔 " + modelData.new
                                color: Services.Colors.mainText
                                opacity: 0.5
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }

            // No updates indicator
            Components.ShadowText {
                text: "System is up to date"
                color: Services.Colors.mainText
                opacity: 0.6
                visible: Services.ShellData.pacmanUpdateList.length === 0 && Services.ShellData.aurUpdateList.length === 0
                Layout.alignment: Qt.AlignCenter
                Layout.margins: Services.Colors.spacingXLarge
            }
        }
    }
}
