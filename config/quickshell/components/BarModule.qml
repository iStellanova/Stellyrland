import QtQuick 2.15
import QtQuick.Layouts
import "../services" as Services
import "." as Components

Rectangle {
    id: root
    property string icon: ""
    property string value: ""
    property color textColor: Services.Colors.mainText
    property color bgColor: "transparent"
    property bool interactive: false
    property bool active: false
    signal clicked()

    implicitWidth: modRow.implicitWidth + 12
    implicitHeight: 26
    radius: Services.Colors.radiusSmall
    scale: (interactive && mouseArea.pressed) || active ? 0.95 : 1.0
    color: {
        if (active) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
        if (!interactive) return bgColor
        if (mouseArea.pressed) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2)
        if (mouseArea.containsMouse) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.1)
        return bgColor
    }

    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

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
        spacing: Services.Colors.spacingSmall

        Components.ShadowText {
            text: root.icon
            font.pixelSize: Services.Colors.fontSize
            color: active || (root.interactive && mouseArea.containsMouse) ? Services.Colors.primary : root.textColor
            visible: text.length > 0
        }

        Components.ShadowText {
            text: root.value
            font.pixelSize: Services.Colors.fontSize
            color: root.interactive && mouseArea.containsMouse ? Services.Colors.primary : root.textColor
            visible: text.length > 0
        }
    }
}
