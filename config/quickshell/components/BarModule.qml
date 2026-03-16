import QtQuick 2.15
import QtQuick.Layouts
import "../services"
import "." as Components

Rectangle {
    id: root
    property string icon: ""
    property string value: ""
    property color textColor: Colors.mainText
    property color bgColor: "transparent"
    property bool interactive: false
    signal clicked()

    implicitWidth: modRow.implicitWidth + 12
    implicitHeight: 26
    radius: 8
    scale: interactive && mouseArea.pressed ? 0.95 : 1.0
    color: {
        if (!interactive) return bgColor
        if (mouseArea.pressed) return Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.2)
        if (mouseArea.containsMouse) return Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.1)
        return bgColor
    }

    Behavior on color { ColorAnimation { duration: 80 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        id: modRow
        anchors.centerIn: parent
        spacing: 4

        Components.ShadowText {
            text: root.icon
            font.pixelSize: Colors.fontSize
            color: root.interactive && mouseArea.containsMouse ? Colors.primary : root.textColor
            visible: text.length > 0
        }

        Components.ShadowText {
            text: root.value
            font.pixelSize: Colors.fontSize
            color: root.interactive && mouseArea.containsMouse ? Colors.primary : root.textColor
            visible: text.length > 0
        }
    }
}
