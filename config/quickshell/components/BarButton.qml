import QtQuick 2.15
import QtQuick.Layouts
import "../services"
import "." as Components

Rectangle {
    id: root
    property alias text: btnText.text
    property int fontSize: Colors.fontSize
    property color textColor: Colors.mainText
    property color bgColor: "transparent"
    signal clicked()

    implicitWidth: 36; implicitHeight: 26
    radius: 8
    scale: btnMouse.pressed ? 0.95 : 1.0
    color: {
        if (btnMouse.pressed) return Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.35)
        if (btnMouse.containsMouse) return Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.25)
        return bgColor
    }

    Behavior on color { ColorAnimation { duration: 80 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

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
