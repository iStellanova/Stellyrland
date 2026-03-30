import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: trafficWindow

    windowWidth: 400

    property real maxValue: {
        let max = 100
        let rx = Services.ShellData.rxHistory
        let tx = Services.ShellData.txHistory
        for (let i = 0; i < rx.length; i++) if (rx[i] > max) max = rx[i]
        for (let i = 0; i < tx.length; i++) if (tx[i] > max) max = tx[i]
        return max * 1.1 // 10% padding
    }

    function formatValue(v) {
        if (v >= 1048576) return (v / 1048576).toFixed(1) + "G"
        if (v >= 1024) return (v / 1024).toFixed(1) + "M"
        return Math.round(v) + "K"
    }

    property var yAxisLabels: [
        formatValue(maxValue),
        formatValue(maxValue * 0.75),
        formatValue(maxValue * 0.5),
        formatValue(maxValue * 0.25),
        "0"
    ]

    RowLayout {
        Layout.fillWidth: true
        Components.ShadowText {
            text: "Network Traffic"
            font.pixelSize: Services.Colors.fontSizeLarge
            font.bold: true
            color: Services.Colors.primary
            Layout.alignment: Qt.AlignLeft
        }
        
        Item { Layout.fillWidth: true }
        
        Components.PinButton {
            pinned: trafficWindow.pinned
            onToggled: trafficWindow.pinned = !trafficWindow.pinned
        }

        RowLayout {
            spacing: 12
            ColumnLayout {
                spacing: -2
                Components.ShadowText {
                    text: "Down"
                    font.pixelSize: 8
                    color: Services.Colors.dim
                    Layout.alignment: Qt.AlignRight
                }
                Components.ShadowText {
                    text: Services.ShellData.rxRate >= 1024 
                        ? (Services.ShellData.rxRate / 1024).toFixed(1) + " MB/s"
                        : Services.ShellData.rxRate.toFixed(0) + " KB/s"
                    font.pixelSize: 12
                    color: Services.Colors.mainText
                    font.bold: true
                }
            }
            ColumnLayout {
                spacing: -2
                Components.ShadowText {
                    text: "Up"
                    font.pixelSize: 8
                    color: Services.Colors.dim
                    Layout.alignment: Qt.AlignRight
                }
                Components.ShadowText {
                    text: Services.ShellData.txRate >= 1024
                        ? (Services.ShellData.txRate / 1024).toFixed(1) + " MB/s"
                        : Services.ShellData.txRate.toFixed(0) + " KB/s"
                    font.pixelSize: 12
                    color: Services.Colors.mainText
                    font.bold: true
                    opacity: 0.8
                }
            }
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
            spacing: Services.Colors.spacingSmall
            z: 2
            
            Repeater {
                model: trafficWindow.yAxisLabels
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
            anchors.leftMargin: 35
            anchors.rightMargin: 5
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            
            onPaint: {
                let ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                let rxData = Services.ShellData.rxHistory
                let txData = Services.ShellData.txHistory
                
                if (rxData.length < 2) return

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

                let stepX = width / 59
                let maxVal = trafficWindow.maxValue

                // 1. Download Area (Solid + Gradient)
                let gradient = ctx.createLinearGradient(0, 0, 0, height)
                gradient.addColorStop(0, Services.Colors.alpha(Services.Colors.primary, 0.3))
                gradient.addColorStop(1, Services.Colors.alpha(Services.Colors.primary, 0.0))

                ctx.beginPath()
                ctx.moveTo(width - (rxData.length - 1) * stepX, height)
                for (let i = 0; i < rxData.length; i++) {
                    let x = width - (rxData.length - 1 - i) * stepX
                    let h = (rxData[i] / maxVal) * height
                    ctx.lineTo(x, height - h)
                }
                ctx.lineTo(width, height)
                ctx.closePath()
                ctx.fillStyle = gradient
                ctx.fill()

                // 2. Download Line (Solid)
                ctx.beginPath()
                ctx.strokeStyle = Services.Colors.primary
                ctx.lineWidth = 2
                ctx.lineJoin = "round"
                for (let i = 0; i < rxData.length; i++) {
                    let x = width - (rxData.length - 1 - i) * stepX
                    let h = (rxData[i] / maxVal) * height
                    if (i === 0) ctx.moveTo(x, height - h)
                    else ctx.lineTo(x, height - h)
                }
                ctx.stroke()

                // 3. Upload Line (Dotted)
                if (txData.length >= 2) {
                    ctx.beginPath()
                    ctx.strokeStyle = Services.Colors.primary
                    ctx.setLineDash([4, 4])
                    ctx.lineWidth = 1.5
                    ctx.lineJoin = "round"
                    ctx.globalAlpha = 0.7
                    for (let i = 0; i < txData.length; i++) {
                        let x = width - (txData.length - 1 - i) * stepX
                        let h = (txData[i] / maxVal) * height
                        if (i === 0) ctx.moveTo(x, height - h)
                        else ctx.lineTo(x, height - h)
                    }
                    ctx.stroke()
                    ctx.setLineDash([]) // Reset
                    ctx.globalAlpha = 1.0
                }
            }
            
            Connections {
                target: Services.ShellData
                function onRxHistoryChanged() { graphCanvas.requestPaint() }
                function onTxHistoryChanged() { graphCanvas.requestPaint() }
            }
        }
    }
}

