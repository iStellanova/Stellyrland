import Quickshell
import QtQuick
import "../services" as Services

Item {
    id: root

    property string iconName: ""
    property string fallbackText: ""
    
    // Styling properties to allow overrides
    property real radius: Services.Colors.radiusSmall
    property color fallbackBgColor: Services.Colors.primaryContainer
    property color fallbackBorderColor: Services.Colors.primary
    property real fallbackBorderWidth: 1
    
    property color iconBgColor: "transparent"
    property color iconBorderColor: "transparent"
    property real iconBorderWidth: 0
    
    property real imageMargins: 4

    // Expose fallback state for parent styling if needed
    readonly property bool isFallback: bgRect.isFallback

    // Resolves the image source — respects IconStore theme indexing and overrides
    readonly property string resolvedSource: {
        let _ = Services.IconStore.iconMap // React to icon index updates
        if (!iconName) return ""
        
        return Services.IconStore.getIconPath(iconName)
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: root.radius
        
        readonly property bool isFallback: appIcon.status === Image.Error || appIcon.status === Image.Null || (appIcon.status === Image.Ready && appIcon.sourceSize.width === 0)
        
        color: isFallback ? root.fallbackBgColor : root.iconBgColor
        border.width: isFallback ? root.fallbackBorderWidth : root.iconBorderWidth
        border.color: isFallback ? root.fallbackBorderColor : root.iconBorderColor

        ShadowText {
            anchors.centerIn: parent
            text: root.fallbackText ? root.fallbackText.charAt(0).toUpperCase() : "󰝚"
            font.pixelSize: Math.max(8, Math.min(parent.height * 0.55, 32))
            font.weight: Font.Bold
            color: Services.Colors.primary
            visible: bgRect.isFallback
        }

        Image {
            id: appIcon
            anchors.fill: parent
            anchors.margins: root.imageMargins
            source: root.resolvedSource
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: false
            visible: status === Image.Ready && !bgRect.isFallback
        }
    }
}
