import QtQuick
import QtQuick.Layouts
import "../services" as Services

/**
 * SpectrumVisualizer.qml
 * Adapted from Noctalia's NLinearSpectrum
 * 
 * A high-performance audio visualizer component that uses CAVA data.
 */
Item {
    id: root

    property color color: Services.Colors.mainText
    property var values: Services.ShellData.cavaData
    property bool mirrored: true
    property int bars: root.values.length > 0 ? (root.mirrored ? root.values.length * 2 : root.values.length) : 0
    property real spacing: {
        let defaultSpacing = 2
        if (root.width <= 0 || bars <= 1) return defaultSpacing
        // If (bars * (minBarWidth + spacing) - spacing) > width, reduce spacing
        let minBarWidth = 3
        let totalSpacingNeeded = (bars - 1) * defaultSpacing
        if (bars * minBarWidth + totalSpacingNeeded > root.width) {
            return Math.max(1, (root.width - (bars * minBarWidth)) / (bars - 1))
        }
        return defaultSpacing
    }
    property real barWidth: root.bars > 0 ? Math.max(1, (root.width - (root.bars - 1) * root.spacing) / root.bars) : 0
    property real maxHeight: 60

    implicitWidth: mirrored ? (values.length * 2 * (15 + spacing)) : (values.length * (15 + spacing))
    implicitHeight: maxHeight

    Row {
        id: row
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.spacing
        height: parent.height
        
        Repeater {
            model: root.mirrored ? (root.values.length * 2) : root.values.length
            delegate: Rectangle {
                // Determine value index for mirroring: [5,4,3,2,1,0,0,1,2,3,4,5]
                readonly property int valueIndex: {
                    if (!root.mirrored) return index
                    return index < root.values.length 
                           ? root.values.length - 1 - index 
                           : index - root.values.length
                }
                
                readonly property real value: (root.values && root.values[valueIndex] !== undefined) 
                                              ? root.values[valueIndex] / 7.0 
                                              : 0
                
                width: root.barWidth
                height: Math.max(4, value * row.height)
                radius: Services.Colors.radiusSmall
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: root.color }
                }
                
                opacity: 0.12 + (value * 0.4)
                anchors.bottom: parent.bottom
            }
        }
    }
}
