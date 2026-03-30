import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: mediaWindow

    windowWidth: 330
    
    property var activePlayerButton: null

    backgroundContent: [
        Components.SpectrumVisualizer {
            anchors.fill: parent
            anchors.margins: Services.Colors.spacingLarge
            opacity: 0.3
            visible: Services.Music.player !== null
        }
    ]

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 32
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
                return p.playbackState === MprisPlaybackState.Playing ? "▶ " : "⏸ "
            }
            font.pixelSize: Services.Colors.fontSizeLarge
            color: Services.Colors.mainText
            opacity: 0.6
            Layout.preferredWidth: 32
            Layout.preferredHeight: 24
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
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

