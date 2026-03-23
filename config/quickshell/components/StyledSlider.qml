import QtQuick
import QtQuick.Controls
import "../services" as Services

Slider {
    id: root

    property color accentColor: Services.Colors.primary
    property real backgroundHeight: 14
    property real handleSize: 14

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: root.backgroundHeight
        width: root.availableWidth
        height: implicitHeight
        radius: height / 2
        color: Services.Colors.border

        Rectangle {
            width: root.visualPosition * (root.availableWidth - root.handle.width) + root.handle.width / 2
            height: parent.height
            radius: parent.radius
            color: root.accentColor
            opacity: root.enabled ? 1.0 : 0.5
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: root.handleSize
        implicitHeight: root.handleSize
        radius: width / 2
        color: "white"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.1)

        scale: root.pressed ? 0.9 : (hover.hovered ? 1.1 : 1.0)
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        
        HoverHandler { id: hover }
    }
}
