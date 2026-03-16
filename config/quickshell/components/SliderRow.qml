import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services

RowLayout {
    id: root

    property string icon: "󰕾"
    required property real value
    property bool muted: false
    signal valueMoved(real value)
    signal iconClicked()

    spacing: 10

    Rectangle {
        implicitWidth: 24; implicitHeight: 24
        color: "transparent"
        radius: 4

        ShadowText {
            anchors.centerIn: parent
            text: {
                if (root.muted) return "󰝟"
                if (root.value === 0) return "󰕿"
                if (root.value < 34) return "󰕿"
                if (root.value < 67) return "󰖀"
                return "󰕾"
            }
            font.pixelSize: 15
            font.family: Services.Colors.fontFamily
            font.weight: Font.DemiBold
            color: root.muted ? Services.Colors.dim : Services.Colors.primary
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        from: 0; to: 100
        stepSize: 1
        opacity: root.muted ? 0.5 : 1.0

        Binding on value {
            value: root.value
            when: !slider.pressed
        }

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200; implicitHeight: 14
            width: slider.availableWidth; height: implicitHeight
            radius: 99
            color: Services.Colors.border

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 99
                color: Services.Colors.primary
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 14; implicitHeight: 14
            radius: 99
            color: "white"
        }

        onMoved: root.valueMoved(slider.value)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel) => {
                let step = wheel.angleDelta.y > 0 ? 5 : -5
                let newVal = Math.max(0, Math.min(100, slider.value + step))
                root.valueMoved(newVal)
            }
        }
    }

    ShadowText {
        text: (root.muted ? "Muted" : Math.round(root.value) + "%")
        font.pixelSize: 10
        font.family: Services.Colors.fontFamily
        font.weight: Font.DemiBold
        color: Services.Colors.dim
        Layout.minimumWidth: 36
        horizontalAlignment: Text.AlignRight
    }
}
