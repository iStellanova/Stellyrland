import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../services" as Services
import "." as Components

PanelWindow {
    id: window

    signal closeRequested()
    property bool open: false
    property real xOffset: 0
    property real windowWidth: 330
    property int _cr: 12

    property bool pinned: false
    property bool autoClose: true
    
    // Configurable styling
    property int contentMargin: 14
    property int contentSpacing: Services.Colors.spacingLarge
    property int bottomMargin: contentMargin

    default property alias content: mainCol.data
    property alias backgroundContent: backgroundContainer.data

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-popups"

    property bool hasMouseEntered: false
    onVisibleChanged: {
        if (!visible) {
            hasMouseEntered = false
        }
    }
    
    // ── Drawer-style liquid slide animation ──
    property real contentHeight: mainCol.implicitHeight + contentMargin + bottomMargin
    implicitHeight: 0 
    visible: implicitHeight > 1
    margins.top: 0

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: window.autoClose && window.visible && window.hasMouseEntered && !hover.hovered && !window.pinned
        repeat: true
        onTriggered: window.closeRequested()
    }

    HoverHandler {
        id: hover
        onHoveredChanged: if (hovered) window.hasMouseEntered = true
    }

    implicitWidth: windowWidth + _cr * 2
    exclusiveZone: 0

    anchors {
        top: true
        left: true
        right: false
        bottom: false
    }
    
    margins.left: xOffset - (windowWidth / 2) - _cr
    color: "transparent"

    Item {
        id: clipContainer
        anchors.fill: parent
        clip: true

        states: [
            State {
                name: "open"
                when: window.open
                PropertyChanges { 
                    target: window
                    implicitHeight: window.contentHeight
                }
            }
        ]

        transitions: [
            Transition {
                from: ""; to: "open"
                reversible: false
                NumberAnimation { 
                    property: "implicitHeight"
                    duration: Services.Colors.animNormal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Services.Colors.curveEmphasized
                }
            },
            Transition {
                from: "open"; to: ""
                reversible: false
                NumberAnimation { 
                    property: "implicitHeight"
                    duration: Services.Colors.animFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Services.Colors.curveEmphasizedAccel
                }
            }
        ]

        // Left ear
        Canvas {
            id: leftEar
            width: _cr + 2
            height: _cr + 2
            x: -1
            y: Math.min(-1, clipContainer.height - _cr * 2 - 1)
            z: 2
            property color fillColor: Services.Colors.bg
            property color strokeColor: Services.Colors.border
            onPaint: {
                let ctx = getContext("2d")
                let r = _cr
                let ox = 1
                let oy = 1
                ctx.reset()
                ctx.fillStyle = fillColor
                ctx.beginPath()
                ctx.moveTo(ox, oy)
                ctx.lineTo(ox + r, oy)
                ctx.lineTo(ox + r, oy + r)
                ctx.arc(ox, oy + r, r, 0, -Math.PI / 2, true)
                ctx.fill()
                
                ctx.strokeStyle = strokeColor
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.arc(ox, oy + r, r, 0, -Math.PI / 2, true)
                ctx.stroke()
            }
        }

        // Right ear
        Canvas {
            id: rightEar
            width: _cr + 2
            height: _cr + 2
            anchors.right: parent.right
            anchors.rightMargin: -1
            y: Math.min(-1, clipContainer.height - _cr * 2 - 1)
            z: 2
            property color fillColor: Services.Colors.bg
            property color strokeColor: Services.Colors.border
            onPaint: {
                let ctx = getContext("2d")
                let r = _cr
                let ox = 1
                let oy = 1
                ctx.reset()
                ctx.fillStyle = fillColor
                ctx.beginPath()
                ctx.moveTo(ox, oy + r) 
                ctx.lineTo(ox, oy) 
                ctx.lineTo(ox + r, oy)
                ctx.arc(ox + r, oy + r, r, -Math.PI / 2, -Math.PI, true)
                ctx.fill()
                
                ctx.strokeStyle = strokeColor
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.arc(ox + r, oy + r, r, -Math.PI / 2, -Math.PI, true)
                ctx.stroke()
            }
        }

        Item {
            id: sliderContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: contentHeight

            // Glass background layer (Isolated to avoid circular mask dependency)
            Item {
                id: glassContainer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: sliderContent.height + Services.Colors.radiusLarge
                anchors.leftMargin: _cr
                anchors.rightMargin: _cr
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blurMax: 32
                    blur: 1.0
                    maskEnabled: true
                    maskSource: maskRect
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Services.Colors.radiusLarge
                    color: Services.Colors.bg
                }
            }

            // External mask for the glass container
            Rectangle {
                id: maskRect
                anchors.fill: glassContainer
                radius: Services.Colors.radiusLarge
                color: "black"
                visible: false
                layer.enabled: true
            }

            // Glass inner highlight (Non-blurred)
            Rectangle {
                anchors.fill: glassContainer
                radius: Services.Colors.radiusLarge
                color: "transparent"
                border.width: 1
                border.color: Services.Colors.alpha(Services.Colors.mainText, 0.05)
            }

            // Outer border explicitly clipped dynamically so it stays attached to the moving ears
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.topMargin: Math.max(0, leftEar.y + _cr + 1)
                clip: true

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: sliderContent.height + Services.Colors.radiusLarge
                    anchors.leftMargin: _cr
                    anchors.rightMargin: _cr
                    radius: Services.Colors.radiusLarge
                    color: "transparent"
                    border.width: 1
                    border.color: Services.Colors.border
                }
            }
            
            Item {
                id: backgroundContainer
                anchors.fill: parent
                anchors.leftMargin: _cr
                anchors.rightMargin: _cr
            }

            ColumnLayout {
                id: mainCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: _cr + contentMargin
                anchors.rightMargin: _cr + contentMargin
                anchors.topMargin: contentMargin
                anchors.bottomMargin: bottomMargin
                spacing: contentSpacing

                // Entrance animation
                opacity: window.open ? 1.0 : 0.0
                property real _yOffset: window.open ? 0 : 15
                transform: Translate { y: mainCol._yOffset }
                
                Behavior on opacity { 
                    NumberAnimation { 
                        duration: Services.Colors.animNormal + 100
                        easing.type: Easing.OutCubic 
                    } 
                }
                Behavior on _yOffset { 
                    NumberAnimation { 
                        duration: Services.Colors.animNormal + 150
                        easing.type: Easing.OutCubic 
                    } 
                }
            }
        }
    }
}
