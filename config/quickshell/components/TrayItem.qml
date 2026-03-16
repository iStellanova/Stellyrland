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
    radius: 6
    color: (!isSeparator && entryMouse.containsMouse && entry && (entry.enabled !== false)) ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8
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
            source: (entry && entry.icon) || ""
            width: 16; height: 16
            visible: source.toString() !== ""
            Layout.alignment: Qt.AlignVCenter
            asynchronous: true
            sourceSize: Qt.size(32, 32)
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

    MouseArea {
        id: entryMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.isSeparator
        onClicked: {
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
