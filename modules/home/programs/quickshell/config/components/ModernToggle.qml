import QtQuick
import QtQuick.Layouts
import "../services" as Services

/**
 * ModernToggle.qml
 * Adapted from Noctalia's NToggle
 * 
 * A premium-styled animated switch component.
 */
Item {
    id: root

    property bool checked: false
    property string label: ""
    
    signal toggled(bool checked)

    implicitWidth: 44
    implicitHeight: 24

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Services.Colors.primary : Services.Colors.alpha(Services.Colors.mainText, 0.1)
        border.width: 1
        border.color: root.checked ? Services.Colors.primary : Services.Colors.alpha(Services.Colors.mainText, 0.15)

        Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
        Behavior on border.color { ColorAnimation { duration: Services.Colors.animFast } }

        Rectangle {
            id: thumb
            x: root.checked ? parent.width - width - 4 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - 8
            height: width
            radius: width / 2
            color: root.checked ? Services.Colors.bg : Services.Colors.mainText
            
            Behavior on x {
                NumberAnimation {
                    duration: Services.Colors.animFast
                    easing.type: Easing.OutBack
                }
            }
            
            Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }

            // Subtle inner glow when checked
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Services.Colors.primary
                opacity: root.checked ? 0.3 : 0
                visible: root.checked
                scale: 1.2
                z: -1
            }
        }
    }

    TapHandler {
        onTapped: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }

    HoverHandler {
        id: hh
        cursorShape: Qt.PointingHandCursor
    }
    
    // Optional scale feedback on hover/press
    scale: hh.hovered ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast } }
}
