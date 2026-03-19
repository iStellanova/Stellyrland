import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: screenshotWindow
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-popups"
    
    signal closeRequested()

    property bool open: false
    visible: open || contentRoot.opacity > 0
    
    property int delayIndex: 0 // 0 = 0s, 1 = 3s, 2 = 5s
    property var delayValues: [0, 3, 5]
    property var delayLabels: ["0s", "3s", "5s"]
    property bool isCapturing: false
    property bool noTimer: Services.ShellData.screenshotNoTimer

    function takeScreenshot(mode) {
        isCapturing = true
        let cmd = `sleep 0.3; hyprshot -m ${mode} -o ~/Pictures/Screenshots; kill -9 $(cat /tmp/qs_hyprpicker.pid) 2>/dev/null || killall hyprpicker 2>/dev/null`
        screenshotWindow.closeRequested()
        Services.ShellData._runOneShot(["bash", "-c", cmd])
    }

    function pickColor() {
        isCapturing = true
        let cmd = `sleep 0.3; hyprpicker -a; kill -9 $(cat /tmp/qs_hyprpicker.pid) 2>/dev/null || killall hyprpicker 2>/dev/null`
        screenshotWindow.closeRequested()
        Services.ShellData._runOneShot(["bash", "-c", cmd])
    }

    function startTimerSequence() {
        let currentDelay = delayValues[delayIndex]
        isCapturing = true
        let cmd = `kill -9 $(cat /tmp/qs_hyprpicker.pid) 2>/dev/null || killall hyprpicker 2>/dev/null; sleep ${currentDelay}; hyprpicker -r -z & echo $! > /tmp/qs_hyprpicker.pid; sleep 0.2; quickshell ipc call shell triggerDelayedScreenshot`
        screenshotWindow.closeRequested()
        Services.ShellData._runOneShot(["bash", "-c", cmd])
    }

    onOpenChanged: {
        if (open) {
            isCapturing = false;
            if (noTimer) delayIndex = 0;
            focusTimer.start();
        } else {
            focusTimer.stop();
            if (Services.ShellData.screenshotNoTimer) {
                Services.ShellData.screenshotNoTimer = false;
            }
            if (!isCapturing) {
                Services.ShellData._runOneShot(["bash", "-c", "kill -9 $(cat /tmp/qs_hyprpicker.pid) 2>/dev/null || killall hyprpicker 2>/dev/null"])
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: buttonsRow.forceActiveFocus()
    }

    anchors {
        top: true; bottom: true; left: true; right: true
    }
    color: "transparent"

    // Click outside handler
    Rectangle {
        id: outsideClickDim
        anchors.fill: parent
        color: "transparent"
        opacity: screenshotWindow.open ? 1 : 0
        
        Behavior on opacity { 
            NumberAnimation { duration: screenshotWindow.open ? 300 : 50; easing.type: Easing.OutCubic } 
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                if (screenshotWindow.noTimer || screenshotWindow.delayIndex === 0) {
                    takeScreenshot("region")
                } else {
                    screenshotWindow.closeRequested()
                }
            }
        }
    }

    FocusScope {
        id: contentRoot
        anchors.fill: parent
        focus: true
        opacity: 0
        
        state: screenshotWindow.open ? "open" : "closed"
        
        states: [
            State {
                name: "closed"
                PropertyChanges { target: contentRoot; opacity: 0 }
                PropertyChanges { target: menuContainer; anchors.bottomMargin: -100 }
            },
            State {
                name: "open"
                PropertyChanges { target: contentRoot; opacity: 1 }
                PropertyChanges { target: menuContainer; anchors.bottomMargin: 40 }
            }
        ]

        transitions: [
            Transition {
                from: "closed"; to: "open"
                SequentialAnimation {
                    PauseAnimation { duration: 150 }
                    ParallelAnimation {
                        NumberAnimation { target: contentRoot; property: "opacity"; duration: Services.Colors.animSlow; easing.type: Easing.OutCubic }
                        NumberAnimation { target: menuContainer; property: "anchors.bottomMargin"; duration: Services.Colors.animSlow; easing.type: Easing.OutBack }
                    }
                }
            },
            Transition {
                from: "open"; to: "closed"
                NumberAnimation { target: contentRoot; property: "opacity"; duration: Services.Colors.animFast }
                NumberAnimation { target: menuContainer; property: "anchors.bottomMargin"; duration: Services.Colors.animFast }
            }
        ]

        Rectangle {
            id: menuContainer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            width: buttonsRow.implicitWidth + 32
            height: buttonsRow.implicitHeight + 32
            radius: Services.Colors.radiusLarge
            color: Services.Colors.bg
            border.width: 1.5
            border.color: Services.Colors.border

            Behavior on width { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }

            RowLayout {
                id: buttonsRow
                anchors.centerIn: parent
                spacing: 16
                focus: true

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        screenshotWindow.closeRequested();
                        event.accepted = true;
                    }
                }

                // Delay Toggle Button
                Rectangle {
                    id: delayBtn
                    visible: !screenshotWindow.noTimer
                    implicitWidth: 80
                    implicitHeight: 80
                    radius: Services.Colors.radiusLarge
                    color: delayMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) : "transparent"
                    border.width: 1
                    border.color: delayMouse.containsMouse ? Services.Colors.primary : "transparent"
                    
                    scale: delayMouse.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Components.ShadowText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰔛"
                            font.pixelSize: 28
                            font.family: Services.Colors.fontFamily
                            color: Services.Colors.primary
                        }

                        ListView {
                            id: delayList
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 20
                            implicitHeight: 16
                            interactive: false
                            clip: true
                            currentIndex: screenshotWindow.delayIndex
                            model: screenshotWindow.delayLabels

                            Behavior on contentY { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }

                            delegate: Item {
                                width: delayList.width
                                height: delayList.height
                                Components.ShadowText {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 14
                                    font.family: Services.Colors.fontFamily
                                    font.weight: Font.DemiBold
                                    color: Services.Colors.mainText
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: delayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            screenshotWindow.delayIndex = (screenshotWindow.delayIndex + 1) % screenshotWindow.delayValues.length
                        }
                    }
                }

                // Separator
                Rectangle {
                    visible: !screenshotWindow.noTimer
                    implicitWidth: 1.5
                    Layout.fillHeight: true
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12
                    color: Services.Colors.border
                }

                // Camera Button (Only visible if delay > 0)
                ScreenshotButton {
                    visible: !screenshotWindow.noTimer && screenshotWindow.delayIndex > 0
                    icon: "󰄀"
                    label: "Start"
                    action: () => startTimerSequence()
                }

                // Window Button
                ScreenshotButton {
                    visible: screenshotWindow.noTimer || screenshotWindow.delayIndex === 0
                    icon: "󰖲"
                    label: "Window"
                    action: () => takeScreenshot("window")
                }

                // Region Button
                ScreenshotButton {
                    visible: screenshotWindow.noTimer || screenshotWindow.delayIndex === 0
                    icon: "󰆞"
                    label: "Region"
                    action: () => takeScreenshot("region")
                }

                // Screen Button
                ScreenshotButton {
                    visible: screenshotWindow.noTimer || screenshotWindow.delayIndex === 0
                    icon: "󰍹"
                    label: "Screen"
                    action: () => takeScreenshot("output")
                }

                // Color Picker Button
                ScreenshotButton {
                    visible: screenshotWindow.noTimer || screenshotWindow.delayIndex === 0
                    icon: "󰈊"
                    label: "Color"
                    action: () => pickColor()
                }
            }
        }
    }
}
