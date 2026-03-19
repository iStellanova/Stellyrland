import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Rectangle {
    id: btnRoot
    property string icon: ""
    property string label: ""
    property var action: null
    
    implicitWidth: 80
    implicitHeight: 80
    radius: Services.Colors.radiusLarge
    
    color: mouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) : "transparent"
    border.width: 1
    border.color: mouse.containsMouse ? Services.Colors.primary : "transparent"
    
    scale: mouse.pressed ? 0.9 : 1.0
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4
        Components.ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: btnRoot.icon
            font.pixelSize: 28
            font.family: Services.Colors.fontFamily
            color: mouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
            Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
        }
        Components.ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: btnRoot.label
            font.pixelSize: 14
            font.family: Services.Colors.fontFamily
            font.weight: Font.DemiBold
            color: mouse.containsMouse ? Services.Colors.primary : Services.Colors.dim
            Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (btnRoot.action) btnRoot.action()
        }
    }
}
