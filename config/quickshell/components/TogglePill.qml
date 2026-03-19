import QtQuick
import QtQuick.Layouts
import "../services" as Services

Rectangle {
    id: root

    required property string label
    required property string icon
    property color accent: Services.Colors.primary
    required property bool active
    required property var onToggle

    implicitWidth: 80
    implicitHeight: 70
    radius: Services.Colors.radiusNormal
    color: {
        if (mouseArea.containsMouse) {
            return active ? Qt.rgba(accent.r, accent.g, accent.b, 0.18)
                          : Qt.rgba(1, 1, 1, 0.04)
        }
        return active ? Qt.rgba(accent.r, accent.g, accent.b, 0.12)
                      : "transparent"
    }

    border.width: 1
    border.color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.35)
                         : Services.Colors.border

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Services.Colors.spacingSmall

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.pixelSize: 18
            font.family: Services.Colors.fontFamily
            color: root.active ? accent : Services.Colors.dim
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            font.pixelSize: 10
            font.family: Services.Colors.fontFamily
            font.weight: Font.DemiBold
            color: root.active ? accent : Services.Colors.dim
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.onToggle()
    }

    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
}
