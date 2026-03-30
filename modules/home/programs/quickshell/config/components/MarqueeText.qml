import QtQuick
import QtQuick.Layouts
import "../services" as Services

/**
 * MarqueeText.qml
 * 
 * A specialized text component that scrolls automatically when the content 
 * exceeds the specified maxWidth.
 */
Item {
    id: root

    property string text: ""
    property real maxWidth: Infinity
    property color color: Services.Colors.mainText
    property int fontPixelSize: Services.Colors.fontSize
    property int fontWeight: Font.Normal
    
    // Animation controls
    property real waitBeforeScrolling: 2000
    property real scrollCycleDuration: Math.max(4000, root.text.length * 150)
    property real resettingDuration: 400

    implicitWidth: Math.min(maxWidth, contentWidth)
    implicitHeight: titleText.implicitHeight
    
    // Explicit sizing for anchor-based layouts (essential for Bar.qml)
    width: implicitWidth
    height: implicitHeight
    
    // Layout-based sizing (essential for MediaPlayer.qml)
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    readonly property real contentWidth: titleText.implicitWidth
    readonly property bool needsScroll: contentWidth > maxWidth

    onTextChanged: reset()
    onMaxWidthChanged: reset()

    function reset() {
        scrollState = MarqueeText.ScrollState.Idle
        scrollContainer.x = 0
        scrollTimer.restart()
    }

    Component.onCompleted: reset()

    clip: true

    enum ScrollState {
        Idle = 0,
        Scrolling = 1,
        Resetting = 2
    }

    property int scrollState: MarqueeText.ScrollState.Idle

    Timer {
        id: scrollTimer
        interval: root.waitBeforeScrolling
        running: root.needsScroll && root.scrollState === MarqueeText.ScrollState.Idle
        onTriggered: root.scrollState = MarqueeText.ScrollState.Scrolling
    }

    Row {
        id: scrollContainer
        height: parent.height
        spacing: 60 // Gap between original and loop text

        Text {
            id: titleText
            text: root.text
            color: root.color
            font.family: Services.Colors.fontFamily
            font.pixelSize: root.fontPixelSize
            font.weight: root.fontWeight
            verticalAlignment: Text.AlignVCenter
            width: implicitWidth
            height: parent.height
        }

        Text {
            id: loopingText
            visible: root.scrollState !== MarqueeText.ScrollState.Idle
            text: root.text
            color: root.color
            font.family: Services.Colors.fontFamily
            font.pixelSize: root.fontPixelSize
            font.weight: root.fontWeight
            verticalAlignment: Text.AlignVCenter
            width: implicitWidth
            height: parent.height
        }

        NumberAnimation on x {
            id: scrollAnim
            running: root.scrollState === MarqueeText.ScrollState.Scrolling
            from: 0
            to: -(titleText.width + scrollContainer.spacing)
            duration: root.scrollCycleDuration
            loops: Animation.Infinite
            easing.type: Easing.Linear
        }

        NumberAnimation on x {
            id: resetAnim
            running: root.scrollState === MarqueeText.ScrollState.Resetting
            to: 0
            duration: root.resettingDuration
            easing.type: Easing.OutQuart
            onFinished: root.scrollState = MarqueeText.ScrollState.Idle
        }
    }
}
