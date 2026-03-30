import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: ncWindow

    windowWidth: 340
    
    // Unified Data Syncing (No local model needed)
    property var notifModel: Services.NotificationService.notifications

    property bool isClearing: false
    
    Timer {
        id: staggeredClearTimer
        interval: 40 
        repeat: true
        onTriggered: {
            if (notifModel.count > 0) {
                let iid = notifModel.get(notifModel.count - 1)._internalId
                Services.NotificationService.dismissNotificationByInternalId(iid)
            } else {
                stop()
                isClearing = false
                Services.NotificationService.clearHistory()
            }
        }
    }

    function startFinalClear() {
        if (notifModel.count === 0) {
            Services.NotificationService.clearHistory()
            return
        }
        isClearing = true
        staggeredClearTimer.start()
    }

    Item {
        id: rootContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(600, notifModel.count > 0 ? (notifList.contentHeight + 32) : 100)
                    clip: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: Services.Colors.animNormal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: ncWindow.visible ? Services.Colors.curveFastDecel : Services.Colors.curveEmphasizedAccel
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: 16 
                        anchors.bottomMargin: 8 
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: Services.Colors.spacingNormal
                        
                        opacity: ncWindow.visible ? 1.0 : 0.0
                        transform: Translate { y: ncWindow.visible ? 0 : 20 }
                        Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                        Behavior on transform { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }

                        Item {
                            id: listWrapper
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ListView {
                                id: notifList
                                anchors.fill: parent
                                model: notifModel
                                spacing: Services.Colors.spacingNormal
                                clip: false 
                                interactive: true
                                ScrollBar.vertical: ScrollBar { }

                                delegate: Components.NotificationItem {
                                    width: notifList.width - (notifList.ScrollBar.vertical.visible ? 12 : 0)
                                    appName: model.appName
                                    summary: model.summary
                                    body: model.body
                                    iconSource: model.iconSource
                                    actions: model.actionData
                                    desktopEntry: model.desktopEntry
                                    pid: model.pid
                                    urgency: model.urgency

                                    onAction: (act) => Services.NotificationService.invokeActionByInternalId(model._internalId, act)
                                    onDismissed: Services.NotificationService.dismissNotificationByInternalId(model._internalId)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: notifModel.count === 0
                            text: "No notifications"
                            font.pixelSize: 12
                            font.family: Services.Colors.fontFamily
                            font.weight: Font.DemiBold
                            font.italic: true
                            color: Services.Colors.dim
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            visible: notifModel.count === 0
                        }
                    }
                }

                Components.ActionButton {
                    id: clearButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: (notifModel.count > 0 && !isClearing) ? 38 : 0
                    opacity: (notifModel.count > 0 && !isClearing) ? 1.0 : 0.0
                    visible: opacity > 0
                    
                    text: "Clear All"
                    icon: "󰎟"

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: Services.Colors.animNormal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: (notifModel.count > 0 && !isClearing) ? Services.Colors.curveFastDecel : Services.Colors.curveEmphasizedAccel
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Services.Colors.animNormal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: (notifModel.count > 0 && !isClearing) ? Services.Colors.curveEmphasizedDecel : Services.Colors.curveEmphasizedAccel
                        }
                    }

                    onClicked: ncWindow.startFinalClear()
                }
}
