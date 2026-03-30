import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: window

    windowWidth: 200

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
            text: Services.AudioService.micApps.length
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
            model: Services.AudioService.micApps
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
            visible: Services.AudioService.micApps.length === 0
            font.pixelSize: 11
            color: Services.Colors.dim
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Services.Colors.spacingNormal
        }
    }
}
