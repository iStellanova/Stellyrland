import QtQuick
import QtQuick.Layouts
import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "CPU Usage"
    currentValue: Services.ShellData.cpuUsage + "%"
    historyData: Services.ShellData.cpuHistory

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
                text: "Average Speed"
                font.pixelSize: Services.Colors.fontSizeSmall
                color: Services.Colors.mainText
                opacity: 0.6
            }
            Item { Layout.fillWidth: true }
            Components.ShadowText {
                text: Services.ShellData.cpuSpeed
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

        Components.ShadowText {
            text: "Individual Cores"
            font.pixelSize: Services.Colors.fontSizeSmall
            color: Services.Colors.mainText
            opacity: 0.6
            Layout.bottomMargin: 4
        }

        GridLayout {
            columns: 8
            columnSpacing: 4
            rowSpacing: 4
            Layout.fillWidth: true

            Repeater {
                model: Services.ShellData.cpuCoreUsages
                delegate: Rectangle {
                    width: 32
                    height: 18
                    radius: 3
                    color: Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.08)

                    Components.ShadowText {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 8
                        font.bold: true
                        color: modelData > 80 ? Services.Colors.error : (modelData > 50 ? Services.Colors.warning : Services.Colors.secondary)
                        opacity: modelData > 0 ? 0.9 : 0.3
                        z: 2
                    }

                    // Subtle background fill for usage
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 1
                        radius: 2
                        color: modelData > 80 ? Services.Colors.error : (modelData > 50 ? Services.Colors.warning : Services.Colors.primary)
                        opacity: 0.2
                        width: (parent.width - 2) * (modelData / 100)
                        visible: modelData > 0
                    }
                }
            }
        }
    }
}
