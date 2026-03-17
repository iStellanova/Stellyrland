import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services
import "." as Components

PanelWindow {
    id: window

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    readonly property real windowWidth: 330
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-popups"


    property string title: "Stat"
    property string currentValue: ""
    property var historyData: []
    property var yAxisLabels: ["100", "75", "50", "25", "0"]
    property real maxValue: 100
    property color accentColor: Services.Colors.primary
    
    // Optional additional text (like the % in RAM graph)
    property string subValue: "" 

    property bool hasMouseEntered: false
    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        }
    }
    
    Behavior on margins.top {
        NumberAnimation { duration: Services.Colors.animDuration; easing.type: Easing.OutCubic }
    }
    
    margins.top: open ? 10 : -10
    visible: open || content.opacity > 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: window.visible && hasMouseEntered && !hover.hovered
        repeat: true
        onTriggered: window.closeRequested()
    }

    HoverHandler {
        id: hover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    implicitWidth: windowWidth
    implicitHeight: mainCol.implicitHeight + 28

    exclusiveZone: 0

    anchors {
        top: true
        left: true
        right: false
        bottom: false
    }
    
    margins.left: xOffset - (windowWidth / 2)

    color: "transparent"

    Rectangle {
        id: content
        anchors.fill: parent
        radius: 20
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: window.open ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animDuration; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

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
                
                Components.ShadowText {
                    text: window.currentValue
                    font.pixelSize: Services.Colors.fontSizeLarge
                    color: Services.Colors.mainText
                    opacity: 0.8
                }
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
                    spacing: 0
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
                        ctx.strokeStyle = Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.05)
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
        }
    }
}
