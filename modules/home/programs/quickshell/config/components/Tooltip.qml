import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import "../services" as Services

/**
 * Tooltip.qml
 * 
 * A stylish, animated tooltip window.
 */
PanelWindow {
    id: window

    property string text: ""
    property bool open: false
    property real xPos: 0
    property real yPos: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-tooltips"
    
    // Position at cursor/target
    anchors {
        top: true
        left: true
    }
    
    margins.top: yPos - height - 10
    margins.left: xPos - (width / 2)
    
    color: "transparent"
    visible: open || opacity > 0.01

    opacity: open ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: Services.Colors.animFast } }
    
    scale: open ? 1.0 : 0.8
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutBack } }

    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 10

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.alpha(Services.Colors.primary, 0.3)

        RowLayout {
            id: layout
            anchors.centerIn: parent
            
            Text {
                text: window.text
                color: Services.Colors.mainText
                font.pixelSize: Services.Colors.fontSizeSmall
                font.bold: true
            }
        }
    }
}
