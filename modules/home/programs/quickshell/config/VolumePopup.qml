import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: window

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
            text: Services.AudioService.appVolumesModel.count + " apps"
            font.pixelSize: 11
            color: Services.Colors.dim
            visible: Services.AudioService.appVolumesModel.count > 0
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
    }

    Components.SliderRow {
        Layout.fillWidth: true
        value: Services.AudioService.volume
        muted: Services.AudioService.muted
        onValueMoved: v => Services.AudioService.setVolume(v)
        onIconClicked: Services.AudioService.toggleMute()
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Services.Colors.border
        visible: Services.AudioService.appVolumesModel.count > 0
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Services.Colors.spacingLarge
        visible: Services.AudioService.appVolumesModel.count > 0

        Repeater {
            model: Services.AudioService.appVolumesModel
            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Colors.spacingSmall

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Services.Colors.spacingNormal

                    // Application Icon
                    Components.AppIcon {
                        implicitWidth: 18; implicitHeight: 18
                        radius: 4
                        fallbackBgColor: Services.Colors.primaryContainer
                        fallbackBorderColor: Services.Colors.primary
                        fallbackBorderWidth: 1
                        iconBgColor: "transparent"
                        iconName: model.icon
                        fallbackText: model.name || "󰝚"
                        imageMargins: 1
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
                    return Services.AudioService.getAppNode(model.pwId)
                }

                Components.SliderRow {
                    Layout.fillWidth: true
                    value: appNode && appNode.audio ? appNode.audio.volume * 100 : model.volume
                    muted: appNode && appNode.audio ? appNode.audio.muted : model.muted
                    onValueMoved: v => {
                        if (appNode && appNode.audio) appNode.audio.volume = v / 100
                        else Services.AudioService.setAppVolume(model.id, v)
                    }
                    onIconClicked: {
                        if (appNode && appNode.audio) appNode.audio.muted = !appNode.audio.muted
                        else Services.AudioService.toggleAppMute(model.id)
                    }
                }
            }
        }
    }
    
    Components.ShadowText {
        text: "No applications playing audio"
        visible: Services.AudioService.appVolumesModel.count === 0
        font.pixelSize: 11
        color: Services.Colors.dim
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: Services.Colors.spacingNormal
    }
}
