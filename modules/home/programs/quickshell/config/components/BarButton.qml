import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../services" as Services
import "." as Components

Rectangle {
    id: root
    property alias text: btnText.text
    property string iconSource: ""
    property int fontSize: Services.Colors.fontSize
    property color textColor: Services.Colors.mainText
    property color bgColor: "transparent"
    property bool active: false
    property int buttonWidth: 36
    property int buttonHeight: 26
    property int bgRadius: Services.Colors.radiusSmall
    readonly property bool hovered: hoverHandler.hovered
    signal clicked()

    implicitWidth: buttonWidth; implicitHeight: buttonHeight
    radius: bgRadius
    scale: tapHandler.pressed ? 0.95 : 1.0
    color: {
        if (active) return Services.Colors.alpha(Services.Colors.primary, 0.45)
        if (tapHandler.pressed) return Services.Colors.alpha(Services.Colors.primary, 0.35)
        if (hoverHandler.hovered) return Services.Colors.alpha(Services.Colors.primary, 0.25)
        return bgColor
    }

    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveExpressiveSpatial } }

    Components.ShadowText {
        id: btnText
        anchors.centerIn: parent
        font.pixelSize: parent.fontSize
        color: parent.textColor
        visible: text.length > 0 && iconSource === ""
    }

    Image {
        id: btnIcon
        anchors.centerIn: parent
        source: iconSource
        width: 18; height: 18
        sourceSize: Qt.size(36, 36)
        visible: iconSource !== ""
        fillMode: Image.PreserveAspectFit
    }

    MultiEffect {
        anchors.fill: btnIcon
        source: btnIcon
        colorization: 1.0
        colorizationColor: active || hoverHandler.hovered ? Services.Colors.primary : root.textColor
        visible: btnIcon.visible
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        onTapped: parent.clicked()
    }
}
