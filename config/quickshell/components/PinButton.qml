import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "." as Components

Item {
    id: root
    
    property bool pinned: false
    signal toggled()

    implicitWidth: 26
    implicitHeight: 26

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6
        color: hover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        
        Behavior on color { ColorAnimation { duration: 150 } }

        HoverHandler {
            id: hover
        }

        Components.ShadowText {
            anchors.centerIn: parent
            text: root.pinned ? "󰐃" : "󰐄"
            font.pixelSize: 14
            color: root.pinned ? Services.Colors.primary : Services.Colors.mainText
            
            // Opacity: 0.0 by default, 1.0 when hovered or pinned
            opacity: (root.pinned || hover.hovered) ? 1.0 : 0.0
            
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        TapHandler {
            onTapped: root.toggled()
        }
    }
}
