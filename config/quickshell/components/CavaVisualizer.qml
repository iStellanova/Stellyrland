import QtQuick
import QtQuick.Layouts
import "../services" as Services

Item {
    id: root
    implicitHeight: 60
    
    property color barColor: Services.Colors.primary
    property color color: barColor // Alias for easier overriding
    property real barOpacity: 0.12
    property var cavaValues: Services.ShellData.cavaData
    
    Row {
        id: row
        anchors.fill: parent
        spacing: Services.Colors.spacingSmall
        opacity: root.barOpacity

        Repeater {
            model: root.cavaValues
            delegate: Rectangle {
                width: root.cavaValues.length > 0 ? (row.width - (root.cavaValues.length - 1) * row.spacing) / root.cavaValues.length : 0
                height: Math.max(4, (modelData / 7.0) * row.height)
                anchors.bottom: parent.bottom
                radius: Services.Colors.radiusSmall // Rectangular with slightly rounded corners
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: root.color }
                }
                
                Behavior on height {
                    NumberAnimation {
                        duration: Services.Colors.animNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
