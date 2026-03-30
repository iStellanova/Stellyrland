import Quickshell
import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "." as Components

Rectangle {
    id: root
    
    property var entry // QsMenuEntry
    signal triggered()

    property bool isSeparator: entry ? (entry.text === "" && !entry.icon && entry.text !== undefined) : false

    implicitWidth: 200
    implicitHeight: isSeparator ? 10 : 32
    radius: Services.Colors.radiusSmall
    color: (!isSeparator && hoverHandler.hovered && entry && (entry.enabled !== false)) ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: Services.Colors.spacingNormal
        visible: !root.isSeparator

        // Checkmark
        Components.ShadowText {
            text: (entry && entry.checked === true) ? "󰄬" : ""
            font.pixelSize: 14
            color: Services.Colors.primary
            visible: entry ? (entry.checkable === true) : false
            Layout.preferredWidth: 16
        }

        // Icon (if any)
        Image {
            source: Services.IconStore.getIconPath((entry && entry.icon) || "")
            width: 16; height: 16
            visible: source.toString() !== "" && status === Image.Ready
            Layout.alignment: Qt.AlignVCenter
            asynchronous: true
            sourceSize: Qt.size(32, 32)
        }

        // Generic icon fallback for menu (if icon name exists but failed to load)
        Components.ShadowText {
            text: "󰝚"
            font.pixelSize: 13
            color: Services.Colors.primary
            visible: (entry && entry.icon) && parent.children[1].status !== Image.Ready
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 16
        }

        // Text
        Components.ShadowText {
            text: entry ? entry.text : ""
            font.pixelSize: 13
            font.family: Services.Colors.fontFamily
            color: (entry && entry.enabled !== false) ? Services.Colors.mainText : Services.Colors.dim
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
    // Separator line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        height: 1
        color: Services.Colors.border
        visible: root.isSeparator
    }

    HoverHandler {
        id: hoverHandler
        enabled: !root.isSeparator
    }

    TapHandler {
        enabled: !root.isSeparator
        onTapped: {
            if (entry && (entry.enabled !== false)) {
                if (!entry.hasChildren) {
                    try {
                        entry.triggered();
                    } catch (e) {
                    }
                }
                root.triggered()
            }
        }
    }
}
