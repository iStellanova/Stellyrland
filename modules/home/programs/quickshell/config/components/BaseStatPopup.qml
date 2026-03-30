import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import "." as Components

Components.DrawerPopup {
    id: window

    property string title: "Stat"
    property string currentValue: ""
    property var historyData: []
    property var yAxisLabels: ["100", "75", "50", "25", "0"]
    property real maxValue: 100
    property color accentColor: Services.Colors.primary
    
    // Optional additional text (like the % in RAM graph)
    property string subValue: "" 
    property bool showCircleStat: false
    property real statValue: 0.0 // 0.0 to 1.0 for the circle stat
    default property alias extraContent: extraContentContainer.data
    
    RowLayout {
        Layout.fillWidth: true
        Components.ShadowText {
            text: window.title
            font.pixelSize: Services.Colors.fontSizeLarge
            font.bold: true
            color: window.accentColor
            Layout.alignment: Qt.AlignLeft
        }
        
        Item { Layout.fillWidth: true }
        
        Components.PinButton {
            pinned: window.pinned
            onToggled: window.pinned = !window.pinned
        }

        Components.CircleStat {
            size: 38
            lineWidth: 3.5
            value: window.statValue
            color: window.accentColor
            visible: window.showCircleStat
            Layout.rightMargin: 4
        }

        // Removed ShadowText for currentValue to avoid duplication with the dial
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Services.Colors.border
    }

    // Graph Area
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 170
        
        // Y-axis labels
        ColumnLayout {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 30
            spacing: Services.Colors.spacingSmall
            z: 2
            
            Repeater {
                model: window.yAxisLabels
                delegate: Components.ShadowText {
                    text: modelData
                    font.pixelSize: 8
                    color: Services.Colors.mainText
                    opacity: 0.4
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Canvas {
            id: graphCanvas
            anchors.fill: parent
            anchors.leftMargin: 35 // Space for labels
            anchors.rightMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            
            onPaint: {
                let ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if (window.historyData.length < 2) return

                // Draw Grid
                ctx.strokeStyle = Services.Colors.alpha(Services.Colors.mainText, 0.05)
                ctx.lineWidth = 1
                for (let i = 0; i <= 4; i++) {
                    let y = height * (i / 4)
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }

                // Gradient for the area
                let gradient = ctx.createLinearGradient(0, 0, 0, height)
                gradient.addColorStop(0, Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.3))
                gradient.addColorStop(1, Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.0))

                let stepX = width / 59 // 60 points total
                
                // Path for area
                ctx.beginPath()
                ctx.moveTo(width - (window.historyData.length - 1) * stepX, height)
                for (let i = 0; i < window.historyData.length; i++) {
                    let x = width - (window.historyData.length - 1 - i) * stepX
                    let h = (window.historyData[i] / window.maxValue) * height
                    ctx.lineTo(x, height - h)
                }
                ctx.lineTo(width, height)
                ctx.closePath()
                ctx.fillStyle = gradient
                ctx.fill()

                // Path for line
                ctx.beginPath()
                ctx.strokeStyle = window.accentColor
                ctx.lineWidth = 2
                ctx.lineJoin = "round"
                for (let i = 0; i < window.historyData.length; i++) {
                    let x = width - (window.historyData.length - 1 - i) * stepX
                    let h = (window.historyData[i] / window.maxValue) * height
                    if (i === 0) ctx.moveTo(x, height - h)
                    else ctx.lineTo(x, height - h)
                }
                ctx.stroke()
            }
            
            Connections {
                target: window
                function onHistoryDataChanged() { graphCanvas.requestPaint() }
            }
        }

        Components.ShadowText {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 4
            anchors.rightMargin: 10
            text: window.subValue
            color: window.accentColor
            visible: window.subValue !== ""
            font.bold: true
            font.pixelSize: 10
        }
    }

    // Extra Content Section
    ColumnLayout {
        id: extraContentContainer
        Layout.fillWidth: true
        spacing: Services.Colors.spacingSmall
        visible: extraContentContainer.children.length > 0
    }
}
