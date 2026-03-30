import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: logoutWindow
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-popups"
    
    signal closeRequested()

    // Visibility is controlled by shell.qml (via open property)
    property bool open: false
    visible: open || contentRoot.opacity > 0
    
    onOpenChanged: {
        if (open) {
            currentIndex = 0;
            focusTimer.start();
        } else {
            focusTimer.stop();
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: grid.forceActiveFocus()
    }

    // Centered transition
    anchors {
        top: true; bottom: true; left: true; right: true
    }

    color: "transparent"

    property int currentIndex: 0
    property var actions: [
        { icon: "󰐥", label: "Shutdown", action: () => Services.PowerService.togglePowerAction("shutdown"), color: Services.Colors.red,     closeOnAction: false },
        { icon: "󰜉", label: "Reboot",   action: () => Services.PowerService.togglePowerAction("reboot"),   color: Services.Colors.primary, closeOnAction: false },
        { icon: "󰗽", label: "Logout",   action: () => Services.PowerService.logout(),                color: Services.Colors.primary, closeOnAction: true },
        { icon: "󰒲", label: "Suspend",  action: () => Services.PowerService.suspend(),               color: Services.Colors.primary, closeOnAction: true }
    ]

    Rectangle {
        id: outsideClickDim
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
        opacity: logoutWindow.open ? 1 : 0
        
        Behavior on opacity { 
            NumberAnimation { 
                duration: logoutWindow.open ? Services.Colors.animLarge : Services.Colors.animFast 
                easing.type: Easing.BezierSpline
                easing.bezierCurve: logoutWindow.open ? Services.Colors.curveEmphasizedDecel : Services.Colors.curveEmphasizedAccel
            } 
        }

        MouseArea {
            anchors.fill: parent
            onClicked: logoutWindow.closeRequested()
        }
    }

    FocusScope {
        id: contentRoot
        anchors.fill: parent
        focus: true
        opacity: 0
        
        state: logoutWindow.open ? "open" : "closed"
        
        states: [
            State {
                name: "closed"
                PropertyChanges { target: contentRoot; opacity: 0 }
                PropertyChanges { target: menuContainer; scale: 0.8 }
            },
            State {
                name: "open"
                PropertyChanges { target: contentRoot; opacity: 1 }
                PropertyChanges { target: menuContainer; scale: 1.0 }
            }
        ]

        transitions: [
            Transition {
                from: "closed"; to: "open"
                NumberAnimation { target: contentRoot; property: "opacity"; duration: Services.Colors.animLarge; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveEmphasizedDecel }
                NumberAnimation { target: menuContainer; property: "scale"; duration: Services.Colors.animLarge; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveExpressiveSpatial }
            },
            Transition {
                from: "open"; to: "closed"
                NumberAnimation { target: contentRoot; property: "opacity"; duration: Services.Colors.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveEmphasizedAccel }
                NumberAnimation { target: menuContainer; property: "scale"; duration: Services.Colors.animFast; easing.type: Easing.BezierSpline; easing.bezierCurve: Services.Colors.curveEmphasizedAccel }
            }
        ]

        Rectangle {
            id: menuContainer
            anchors.centerIn: parent
            implicitWidth: 320
            implicitHeight: 320
            color: "transparent"

            GridLayout {
                id: grid
                anchors.centerIn: parent
                columns: 2
                rows: 2
                columnSpacing: 16
                rowSpacing: 16
                focus: true

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        logoutWindow.closeRequested();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        const item = actions[currentIndex];
                        item.action();
                        if (item.closeOnAction) logoutWindow.closeRequested(); 
                        event.accepted = true;
                    } else if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                        currentIndex = (currentIndex % 2 === 1) ? currentIndex - 1 : currentIndex;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                        currentIndex = (currentIndex % 2 === 0) ? currentIndex + 1 : currentIndex;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                        currentIndex = (currentIndex >= 2) ? currentIndex - 2 : currentIndex;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                        currentIndex = (currentIndex < 2) ? currentIndex + 2 : currentIndex;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        currentIndex = (currentIndex + 1) % 4;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Backtab) {
                        currentIndex = (currentIndex + 3) % 4;
                        event.accepted = true;
                    }
                }

                Repeater {
                    model: logoutWindow.actions
                    delegate: Rectangle {
                        id: btn
                        implicitWidth: 140
                        implicitHeight: 140
                        radius: Services.Colors.radiusLarge
                        
                        property bool isSelected: logoutWindow.currentIndex === index
                        
                        color: isSelected ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.2) : Services.Colors.bg
                        border.width: 1.5
                        border.color: isSelected ? modelData.color : Services.Colors.border
                        
                        transformOrigin: {
                            if (index === 0) return Item.BottomRight;
                            if (index === 1) return Item.BottomLeft;
                            if (index === 2) return Item.TopRight;
                            return Item.TopLeft;
                        }
                        
                        scale: isSelected ? 1.15 : 1.0

                        Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }
                        Behavior on border.color { ColorAnimation { duration: Services.Colors.animNormal } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Services.Colors.spacingNormal

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignHCenter
                                text: (Services.PowerService.powerCountdown > 0 && Services.PowerService.powerActionType === modelData.label.toLowerCase()) 
                                       ? Services.PowerService.powerCountdown + "s" : modelData.icon
                                font.pixelSize: 42
                                font.family: Services.Colors.fontFamily
                                color: isSelected ? modelData.color : Services.Colors.mainText
                                
                                Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }
                            }

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.pixelSize: 14
                                font.family: Services.Colors.fontFamily
                                font.weight: Font.DemiBold
                                color: isSelected ? modelData.color : Services.Colors.dim
                                
                                Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: logoutWindow.currentIndex = index
                            onClicked: {
                                modelData.action();
                                if (modelData.closeOnAction) logoutWindow.closeRequested();
                            }
                        }
                    }
                }
            }
        }
    }
}
