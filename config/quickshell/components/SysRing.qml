import QtQuick
import QtQuick.Layouts
import "../services" as Services

Item {
    id: root

    required property string label
    required property int value
    required property color accent

    implicitWidth: 70
    implicitHeight: 80

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5

        // Circular progress ring
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 46
            implicitHeight: 46

            // Background ring
            Canvas {
                id: bgRing
                anchors.fill: parent
                onPaint: {
                    let ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15)
                    ctx.lineWidth = 4
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, (width - 4) / 2, 0, 2 * Math.PI)
                    ctx.stroke()
                }
            }

            // Value ring
            Canvas {
                id: valueRing
                anchors.fill: parent
                property int animatedValue: root.value

                Behavior on animatedValue { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                onAnimatedValueChanged: requestPaint()
                onPaint: {
                    let ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = root.accent
                    ctx.lineWidth = 4
                    ctx.lineCap = "round"
                    let startAngle = -Math.PI / 2
                    let endAngle = startAngle + (2 * Math.PI * animatedValue / 100)
                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, (width - 4) / 2, startAngle, endAngle)
                    ctx.stroke()
                }
            }
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.value + "%"
            font.pixelSize: 10
            font.family: Services.Colors.fontFamily
            font.weight: Font.DemiBold
            color: Services.Colors.mainText
        }

        ShadowText {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            font.pixelSize: 9
            font.family: Services.Colors.fontFamily
            font.weight: Font.DemiBold
            color: Services.Colors.dim
        }
    }
}
