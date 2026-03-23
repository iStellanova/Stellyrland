import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import "../components" as Components

ColumnLayout {
    id: root
    
    Layout.fillWidth: true
    visible: Services.AppService.isCategorized && Services.AppService.recentApps.length > 0
    spacing: Services.Colors.spacingSmall

    signal appLaunched()

    Components.ShadowText {
        text: "Recent Apps"
        font.pixelSize: 13
        font.weight: Font.Bold
        color: Services.Colors.primary
        opacity: 0.8
        Layout.leftMargin: 8
    }

    ListView {
        id: recentGrid
        Layout.fillWidth: true
        Layout.preferredHeight: 90
        orientation: ListView.Horizontal
        spacing: Services.Colors.spacingLarge
        model: Services.AppService.recentApps
        clip: true
        interactive: contentWidth > width

        delegate: Item {
            width: 76
            height: 90
            
            property bool isRecentHovered: recentMouse.containsMouse

            function launch() {
                Services.AppService.launch(modelData.exec);
                root.appLaunched();
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: Services.Colors.radiusSmall
                color: isRecentHovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: Services.Colors.spacingSmall

                    AppIcon {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 44
                        radius: Services.Colors.radiusSmall
                        iconBgColor: Qt.rgba(1, 1, 1, 0.08)
                        fallbackBgColor: Qt.rgba(1, 1, 1, 0.08)
                        fallbackBorderWidth: 0
                        scale: isRecentHovered ? 1.1 : 1.0
                        iconName: modelData.icon
                        fallbackText: modelData.name
                        imageMargins: 6
                        
                        Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutBack } }
                    }

                    Text {
                        text: modelData.name
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 11
                        font.family: Services.Colors.fontFamily
                        font.weight: Font.DemiBold
                        color: isRecentHovered ? Services.Colors.primary : Services.Colors.mainText
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }
                    }
                }
            }

            MouseArea {
                id: recentMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: parent.launch()
            }
        }
    }
}
