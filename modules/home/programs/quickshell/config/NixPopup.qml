import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: window

    windowWidth: 350
    
    onVisibleChanged: {
        if (visible) {
            Services.ShellData.refreshNixStats()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Components.ShadowText {
            text: "Nix Monitor"
            font.pixelSize: Services.Colors.fontSizeLarge
            font.bold: true
            color: Services.Colors.primary
            Layout.alignment: Qt.AlignLeft
        }
        
        Item { Layout.fillWidth: true }
        
        Components.PinButton {
            pinned: window.pinned
            onToggled: window.pinned = !window.pinned
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Services.Colors.border
    }
    
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: Services.Colors.spacingNormal
        columnSpacing: Services.Colors.spacingLarge

        Components.ShadowText {
            text: "Generations:"
            color: Services.Colors.mainText
            opacity: 0.7
        }
        Components.ShadowText {
            text: Services.ShellData.nixGenerations + " (" + Services.ShellData.nixCurrentGen + ")"
            color: Services.Colors.mainText
            font.bold: true
            Layout.alignment: Qt.AlignRight
        }

        Components.ShadowText {
            text: "Store Size:"
            color: Services.Colors.mainText
            opacity: 0.7
        }
        Components.ShadowText {
            text: Services.ShellData.nixStoreSize
            color: Services.Colors.mainText
            font.bold: true
            Layout.alignment: Qt.AlignRight
        }

        Components.ShadowText {
            text: "Updates:"
            color: Services.Colors.mainText
            opacity: 0.7
        }
        Components.ShadowText {
            text: Services.ShellData.nixChecking ? "Checking..." : Services.ShellData.nixUpdates
            color: Services.ShellData.nixUpdates === "Available" ? Services.Colors.primary : Services.Colors.mainText
            font.bold: true
            Layout.alignment: Qt.AlignRight
        }

        Components.ShadowText {
            text: "Status:"
            color: Services.Colors.mainText
            opacity: 0.7
        }
        Components.ShadowText {
            text: Services.ShellData.nixStatus
            color: Services.Colors.mainText
            font.bold: true
            Layout.alignment: Qt.AlignRight
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Services.Colors.spacingNormal

        Components.ActionButton {
            implicitWidth: 38
            implicitHeight: 38
            icon: "󰑐"
            iconSize: 18
            iconColor: Services.ShellData.nixChecking ? Services.Colors.primary : Services.Colors.mainText
            onClicked: Services.ShellData.checkNixUpdates()
            
            baseColor: Services.Colors.alpha(Services.Colors.surface, 0.2)
            hoverColor: Services.Colors.alpha(Services.Colors.surface, 0.5)
            borderColor: Services.Colors.border
        }

        Components.ActionButton {
            Layout.fillWidth: true
            text: "Rebuild"
            icon: ""
            onClicked: {
                Services.ShellData.runCommand(["kitty", "--title", "Nix Rebuild", "-e", "bash", "-c", "nh os switch; read -p 'Press enter to continue'"])
                window.closeRequested()
            }
            
            baseColor: Services.Colors.alpha(Services.Colors.primary, 0.15)
            hoverColor: Services.Colors.alpha(Services.Colors.primary, 0.3)
            borderColor: Services.Colors.primary
            textColor: Services.Colors.primary
        }

        Components.ActionButton {
            Layout.fillWidth: true
            text: "GC"
            icon: ""
            onClicked: {
                Services.ShellData.runCommand(["kitty", "--title", "Nix GC", "-e", "bash", "-c", "nix-collect-garbage -d; read -p 'Press enter to continue'"])
                window.closeRequested()
                Services.ShellData.refreshNixStats()
            }
            
            baseColor: Services.Colors.alpha(Services.Colors.secondary, 0.15)
            hoverColor: Services.Colors.alpha(Services.Colors.secondary, 0.3)
            borderColor: Services.Colors.secondary
            textColor: Services.Colors.secondary
        }
    }
}
