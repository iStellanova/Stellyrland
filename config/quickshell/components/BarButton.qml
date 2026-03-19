import QtQuick 2.15
import QtQuick.Layouts
import "../services" as Services
import "." as Components

Rectangle {
    id: root
    property alias text: btnText.text
    property int fontSize: Services.Colors.fontSize
    property color textColor: Services.Colors.mainText
    property color bgColor: "transparent"
    property bool active: false
    signal clicked()

    implicitWidth: 36; implicitHeight: 26
    radius: Services.Colors.radiusSmall
    scale: active || btnMouse.pressed ? 0.95 : 1.0
    color: {
        if (active) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.45)
        if (btnMouse.pressed) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35)
        if (btnMouse.containsMouse) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
        return bgColor
    }

    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

    Components.ShadowText {
        id: btnText
        anchors.centerIn: parent
        font.pixelSize: parent.fontSize
        color: parent.textColor
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: parent.clicked()
    }
}
