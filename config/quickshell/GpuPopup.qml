import QtQuick
import QtQuick.Layouts
import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "GPU Usage"
    currentValue: Services.ShellData.gpuUsage + "%"
    historyData: Services.ShellData.gpuHistory

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Services.Colors.spacingMedium

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Services.Colors.border
            opacity: 0.5
        }

        RowLayout {
            Layout.fillWidth: true
            Components.ShadowText {
                text: "Temperature"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Item { Layout.fillWidth: true }
            Components.ShadowText {
                text: Services.ShellData.gpuTemp + "°C"
                font.pixelSize: Services.Colors.fontSizeMedium
                font.bold: true
                color: Services.Colors.primary
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Services.Colors.border
            opacity: 0.3
        }

        RowLayout {
            Layout.fillWidth: true
            Components.ShadowText {
                text: "VRAM Usage"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Item { Layout.fillWidth: true }
            Components.ShadowText {
                text: Services.ShellData.gpuVramUsed + " / " + Services.ShellData.gpuVramTotal
                font.pixelSize: Services.Colors.fontSizeMedium
                font.bold: true
                color: Services.Colors.secondary
            }
        }
    }
}
