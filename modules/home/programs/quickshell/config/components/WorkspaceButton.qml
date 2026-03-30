import QtQuick
import QtQuick.Layouts
import "../services" as Services

Rectangle {
    id: root

    required property int workspaceId
    required property bool isActive
    required property bool isFocused
    required property var onActivate

    implicitWidth: 32; implicitHeight: 26
    radius: Services.Colors.radiusSmall

    // Background color with fade-in/out for focus and hover states
    color: {
        if (mainMouse.pressed) return Services.Colors.alpha(Services.Colors.primary, 0.35)
        if (mainMouse.containsMouse) return Services.Colors.alpha(Services.Colors.primary, 0.25)
        if (root.isFocused) return Services.Colors.alpha(Services.Colors.primary, 0.10)
        return Qt.rgba(0, 0, 0, 0.15)
    }

    scale: isActive ? 1.08 : 1.0
    Behavior on scale { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutBack } }

    Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }

    ShadowText {
        anchors.centerIn: parent
        text: root.workspaceId
        font.pixelSize: 14
        font.weight: Font.Black
        font.family: Services.Colors.fontFamily
        color: Services.Colors.mainText
    }

    signal hoverStarted(int x, int y)
    signal hoverEnded()

    Timer {
        id: hoverTimer
        interval: Services.Colors.animExtraSlow
        repeat: false
        onTriggered: {
            // Map the center of the button to the bar coordinate system
            let pos = root.mapToItem(null, root.width / 2, root.height)
            root.hoverStarted(pos.x, pos.y)
        }
    }

    MouseArea {
        id: mainMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.onActivate()
        onContainsMouseChanged: {
            if (containsMouse) {
                hoverTimer.start()
            } else {
                hoverTimer.stop()
                root.hoverEnded()
            }
        }
    }
}
