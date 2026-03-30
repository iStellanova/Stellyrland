import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../services" as Services
import "." as Components

Rectangle {
    id: root
    property string icon: ""
    property string iconSource: ""
    property string value: ""
    property color textColor: Services.Colors.mainText
    property color bgColor: "transparent"
    property bool interactive: false
    property bool active: false
    signal clicked()

    implicitWidth: modRow.implicitWidth + 12
    implicitHeight: 26
    radius: Services.Colors.radiusSmall
    scale: (interactive && tapHandler.pressed) || active ? 0.95 : 1.0
    color: {
        if (active) return Services.Colors.alpha(Services.Colors.primary, 0.25)
        if (!interactive) return bgColor
        if (tapHandler.pressed) return Services.Colors.alpha(Services.Colors.primary, 0.2)
        if (hoverHandler.hovered) return Services.Colors.alpha(Services.Colors.primary, 0.1)
        return bgColor
    }

    Behavior on color { ColorAnimation { duration: Services.Colors.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveStandard } }
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveStandard } }

    HoverHandler {
        id: hoverHandler
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        enabled: root.interactive
        onTapped: root.clicked()
    }

    RowLayout {
        id: modRow
        anchors.centerIn: parent
        spacing: Services.Colors.spacingSmall

        Item {
            implicitWidth: iconSource !== "" ? 16 : 0
            implicitHeight: 16
            visible: iconSource !== ""
            
            Image {
                id: modIcon
                anchors.fill: parent
                source: iconSource
                sourceSize: Qt.size(32, 32)
                fillMode: Image.PreserveAspectFit
            }

            MultiEffect {
                anchors.fill: modIcon
                source: modIcon
                colorization: 1.0
                colorizationColor: active || (root.interactive && hoverHandler.hovered) ? Services.Colors.primary : root.textColor
            }
        }

        Components.ShadowText {
            text: root.icon
            font.pixelSize: Services.Colors.fontSize
            color: active || (root.interactive && hoverHandler.hovered) ? Services.Colors.primary : root.textColor
            visible: text.length > 0 && iconSource === ""
        }

        Components.ShadowText {
            text: root.value
            font.pixelSize: Services.Colors.fontSize
            color: root.interactive && hoverHandler.hovered ? Services.Colors.primary : root.textColor
            visible: text.length > 0
        }
    }
}
