import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: wifiWindow

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    readonly property real windowWidth: 330
    
    WlrLayershell.namespace: "quickshell-popups"


    property bool hasMouseEntered: false
    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        } else {
            Services.ShellData.refreshWifi()
        }
    }
    
    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animDuration; easing.type: Easing.OutCubic }
    }
    
    margins.top: open ? Services.Colors.popupMargin : Services.Colors.popupHideOffset
    visible: open || wifiContent.opacity > 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: wifiWindow.visible && hasMouseEntered && !wifiHover.hovered
        repeat: true
        onTriggered: wifiWindow.closeRequested()
    }

    HoverHandler {
        id: wifiHover
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
        id: wifiContent
        anchors.fill: parent
        radius: 20
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: wifiWindow.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animDuration; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Components.ShadowText {
                    text: "Wi-Fi Networks"
                    font.pixelSize: Services.Colors.fontSizeLarge
                    font.bold: true
                    color: Services.Colors.primary
                    Layout.alignment: Qt.AlignLeft
                }
                
                Item { Layout.fillWidth: true }
                
                Components.BarButton {
                    text: Services.ShellData.wifiOn ? "󰤨" : "󰤭"
                    textColor: Services.Colors.mainText
                    bgColor: Qt.rgba(Services.Colors.surface.r, Services.Colors.surface.g, Services.Colors.surface.b, 0.5)
                    onClicked: Services.ShellData.toggleWifi()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Services.Colors.border
            }
            
            // Loading indicator
            Components.ShadowText {
                text: "Scanning networks..."
                color: Services.Colors.mainText
                opacity: 0.6
                visible: Services.ShellData.wifiOn && Services.ShellData.wifiNetworks.length === 0
                Layout.alignment: Qt.AlignCenter
                Layout.margins: 16
            }
            
            // Off indicator
            Components.ShadowText {
                text: "Wi-Fi is turned off"
                color: Services.Colors.mainText
                opacity: 0.6
                visible: !Services.ShellData.wifiOn
                Layout.alignment: Qt.AlignCenter
                Layout.margins: 16
            }

            ListView {
                id: wifiList
                Layout.fillWidth: true
                implicitHeight: contentHeight > 300 ? 300 : contentHeight
                clip: true
                spacing: 4
                model: Services.ShellData.wifiOn ? Services.ShellData.wifiNetworks : []

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 44
                    radius: 10
                    color: netMouse.containsMouse ? Qt.rgba(Services.Colors.surface.r, Services.Colors.surface.g, Services.Colors.surface.b, 0.5) : "transparent"
                    border.width: 1
                    border.color: netMouse.containsMouse ? Services.Colors.border : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }
                    Behavior on border.color { ColorAnimation { duration: 100 } }

                    property bool isActive: Services.ShellData.netSsid === modelData.ssid

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12

                        Components.ShadowText {
                            text: {
                                if (modelData.signal > 80) return "󰤨"
                                if (modelData.signal > 60) return "󰤥"
                                if (modelData.signal > 40) return "󰤢"
                                if (modelData.signal > 20) return "󰤟"
                                return "󰤯"
                            }
                            font.pixelSize: Services.Colors.fontSizeLarge
                            color: isActive ? Services.Colors.primary : Services.Colors.mainText
                        }

                        Components.ShadowText {
                            text: modelData.ssid
                            color: isActive ? Services.Colors.primary : Services.Colors.mainText
                            font.bold: isActive
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Components.ShadowText {
                            text: modelData.security && modelData.security !== "--" ? "" : ""
                            font.pixelSize: Services.Colors.fontSizeSmall
                            color: Services.Colors.mainText
                            opacity: 0.5
                            visible: text !== ""
                        }
                    }

                    MouseArea {
                        id: netMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!isActive) {
                                Services.ShellData.connectWifi(modelData.ssid)
                            }
                        }
                    }
                }
            }
        }
    }
}
