import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "." as Components

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    
    // Default styling (can be overridden)
    property color baseColor: Services.Colors.primaryContainer
    property color hoverColor: Services.Colors.alpha(Services.Colors.primary, 0.2)
    property color pressedColor: Services.Colors.alpha(Services.Colors.primary, 0.3)
    
    property color borderColor: Services.Colors.primary
    property color borderHoverColor: Qt.lighter(borderColor, 1.2)
    property color textColor: Services.Colors.mainText
    property color iconColor: Services.Colors.primary
    
    property int fontPixelSize: 13
    property int iconSize: 15
    
    signal clicked()
    property alias isHovered: bgHover.hovered

    implicitHeight: 38
    implicitWidth: contentRow.implicitWidth + 32
    Layout.alignment: Qt.AlignHCenter
    
    radius: Services.Colors.radiusNormal
    color: tapHandler.pressed ? pressedColor : (bgHover.hovered ? hoverColor : baseColor)
    border.width: 1
    border.color: tapHandler.pressed || bgHover.hovered ? borderHoverColor : borderColor
    
    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
    Behavior on border.color { ColorAnimation { duration: Services.Colors.animFast } }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Services.Colors.spacingNormal

        Components.ShadowText {
            text: root.icon
            visible: root.icon !== ""
            font.pixelSize: root.iconSize
            font.family: Services.Colors.fontFamily
            color: root.iconColor
        }

        Components.ShadowText {
            text: root.text
            visible: root.text !== ""
            font.pixelSize: root.fontPixelSize
            font.family: Services.Colors.fontFamily
            font.weight: Font.DemiBold
            color: root.textColor
        }
    }

    HoverHandler {
        id: bgHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tapHandler
        onTapped: root.clicked()
    }
}
