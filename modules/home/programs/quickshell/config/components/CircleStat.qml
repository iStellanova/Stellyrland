import QtQuick
import QtQuick.Layouts
import "../services" as Services

/**
 * CircleStat.qml
 * Adapted from Noctalia's NCircleStat
 * 
 * A compact circular gauge for metric visualization (CPU, RAM, Battery).
 * uses Canvas with cooperative rendering for performance.
 */
Item {
    id: root

    property real value: 0.0 // 0.0 to 1.0
    property string icon: ""
    property string suffix: "%"
    property color color: Services.Colors.primary
    property real size: 60
    property real lineWidth: 6
    property bool showText: true

    implicitWidth: size
    implicitHeight: size

    // Smoothed value for animation
    property real animatedValue: value
    Behavior on animatedValue {
        NumberAnimation {
            duration: Services.Colors.animNormal
            easing.type: Easing.OutCubic
        }
    }

    onAnimatedValueChanged: gauge.requestPaint()
    onColorChanged: gauge.requestPaint()

    Canvas {
        id: gauge
        anchors.fill: parent
        
        renderStrategy: Canvas.Cooperative
        renderTarget: Canvas.FramebufferObject
        layer.enabled: true
        layer.smooth: true

        onPaint: {
            const ctx = getContext("2d");
            const w = width, h = height;
            const cx = w / 2, cy = h / 2;
            const r = (Math.min(w, h) - root.lineWidth) / 2;

            // Start at top (Math.PI * 1.5)
            const start = Math.PI * 1.5;
            const fullCircle = Math.PI * 2;

            ctx.reset();
            ctx.lineWidth = root.lineWidth;
            ctx.lineCap = "round";

            // Track (background)
            ctx.strokeStyle = Services.Colors.alpha(root.color, 0.1);
            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, fullCircle);
            ctx.stroke();

            // Value arc
            const v = Math.max(0.001, Math.min(0.999, root.animatedValue));
            ctx.strokeStyle = root.color;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + (fullCircle * v));
            ctx.stroke();
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: -2
        visible: root.showText

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Math.round(root.animatedValue * 100) + root.suffix
            font.pixelSize: root.size * 0.22
            font.bold: true
            color: Services.Colors.mainText
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.pixelSize: root.size * 0.25
            color: Services.Colors.alpha(Services.Colors.mainText, 0.6)
            visible: root.icon !== ""
        }
    }
}
