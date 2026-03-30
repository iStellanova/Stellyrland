import QtQuick
import QtQuick.Layouts
import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "Memory Usage"
    currentValue: Services.ShellData.ramPerc + "%"
    historyData: Services.ShellData.ramHistory
    showCircleStat: true
    statValue: Services.ShellData.ramPerc / 100

    accentColor: Services.Colors.secondary

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Services.Colors.spacingNormal

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Services.Colors.border
            opacity: 0.5
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: Services.Colors.spacingLarge
            rowSpacing: Services.Colors.spacingSmall

            // Total Used
            Components.ShadowText {
                text: "Total Used"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Components.ShadowText {
                text: Services.ShellData.ramUsage
                font.pixelSize: Services.Colors.fontSizeSmall
                font.bold: true
                color: Services.Colors.primary
                Layout.alignment: Qt.AlignRight
            }

            // Available
            Components.ShadowText {
                text: "Available"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Components.ShadowText {
                text: Services.ShellData.ramAvailable
                font.pixelSize: Services.Colors.fontSizeSmall
                font.bold: true
                color: Services.Colors.secondary
                Layout.alignment: Qt.AlignRight
            }

            // Free
            Components.ShadowText {
                text: "Free"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Components.ShadowText {
                text: Services.ShellData.ramFree
                font.pixelSize: Services.Colors.fontSizeSmall
                font.bold: true
                color: Services.Colors.alpha(Services.Colors.secondary, 0.8)
                Layout.alignment: Qt.AlignRight
            }

            // Cached
            Components.ShadowText {
                text: "Cached"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Components.ShadowText {
                text: Services.ShellData.ramCached
                font.pixelSize: Services.Colors.fontSizeSmall
                font.bold: true
                color: Services.Colors.warning
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
