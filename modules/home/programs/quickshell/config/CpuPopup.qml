import QtQuick
import QtQuick.Layouts
import "services" as Services
import "components" as Components

Components.BaseStatPopup {
    title: "CPU Usage"
    currentValue: Services.ShellData.cpuUsage + "%"
    historyData: Services.ShellData.cpuHistory
    showCircleStat: true
    statValue: Services.ShellData.cpuUsage / 100

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Services.Colors.spacingNormal

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
                font.pixelSize: Services.Colors.fontSize
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
            columns: 2
            columnSpacing: 16
            rowSpacing: 8
            Layout.fillWidth: true

            Repeater {
                model: Services.ShellData.cpuCoreUsages
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Components.ShadowText {
                        text: "Core " + index
                        font.pixelSize: 10
                        color: Services.Colors.mainText
                        opacity: 0.5
                        Layout.minimumWidth: 45
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Services.Colors.alpha(Services.Colors.mainText, 0.1)

                        Rectangle {
                            width: parent.width * (modelData / 100)
                            height: parent.height
                            radius: parent.radius
                            color: modelData > 80 ? Services.Colors.error : (modelData > 50 ? Services.Colors.warning : Services.Colors.primary)
                            
                            Behavior on width {
                                NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Components.ShadowText {
                        text: modelData + "%"
                        font.pixelSize: 10
                        font.bold: true
                        color: Services.Colors.mainText
                        opacity: 0.8
                        Layout.minimumWidth: 30
                    }
                }
            }
        }
    }
}
