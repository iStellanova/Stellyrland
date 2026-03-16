import Quickshell
import Quickshell.Io as Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "services" as Services
import "components" as Components

PanelWindow {
    id: ncWindow

    signal closeRequested()

    property bool hasMouseEntered: false
    onVisibleChanged: if (!visible) hasMouseEntered = false

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: ncWindow.visible && hasMouseEntered && !ncHover.hovered
        repeat: true
        onTriggered: ncWindow.closeRequested()
    }

    HoverHandler {
        id: ncHover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    implicitWidth: 340
    exclusiveZone: 0

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: 8
        bottom: 8
        right: 12
    }

    color: "transparent"

    // Unified Data Syncing (No local model needed)
    property var notifModel: Services.NotificationService.notifications

    property bool isClearing: false
    
    Timer {
        id: staggeredClearTimer
        interval: 40 
        repeat: true
        onTriggered: {
            // Check if we still have items
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

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            id: rootContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 20
            color: Services.Colors.bg
            border.width: 2
            border.color: Services.Colors.border
            clip: true

            // Premium rounded corner clipping
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: rootContainer.width
                    height: rootContainer.height
                    radius: rootContainer.radius
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 16 
                anchors.bottomMargin: 8 
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Item {
                    id: listWrapper
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true // Ensure notifications cut off at top/bottom of list area

                    // ── Scrollable History ────────────────────────────
                    ListView {
                        id: notifList
                        anchors.fill: parent
                        model: notifModel
                        spacing: 8
                        clip: false 
                        interactive: true
                        ScrollBar.vertical: ScrollBar { }

                        // Managed transitions
                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 250 }
                            NumberAnimation { property: "x"; from: 100; to: 0; duration: 300; easing.type: Easing.OutCubic }
                        }
                        
                        remove: Transition {
                            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                            NumberAnimation { property: "x"; to: 400; duration: 250; easing.type: Easing.InCubic }
                        }

                        displaced: Transition {
                            NumberAnimation { property: "y"; duration: Services.Colors.animDuration; easing.type: Easing.OutCubic }
                        }

                        delegate: Components.NotificationItem {
                            width: notifList.width - (notifList.ScrollBar.vertical.visible ? 12 : 0)
                            
                            // Snapshot data
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

                // ── Empty state (only if model is truly empty) ──
                Components.ShadowText {
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

        // ── "Clear All" Button Underneath ──────────────────
        Rectangle {
            id: clearButton
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: clearRow.implicitWidth + 32
            Layout.preferredHeight: (notifModel.count > 0 && !isClearing) ? 38 : 0
            
            // Layout.fillWidth override to prevent expansion
            Layout.fillWidth: false
            
            radius: 12
            color: Services.Colors.primaryContainer
            opacity: (notifModel.count > 0 && !isClearing) ? 0.9 : 0
            border.width: 1
            border.color: Services.Colors.primary
            visible: opacity > 0
            clip: true

            Behavior on Layout.preferredHeight { NumberAnimation { duration: Services.Colors.animDuration; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on opacity { NumberAnimation { duration: Services.Colors.animDuration; easing.type: Easing.OutCubic } }

            RowLayout {
                id: clearRow
                anchors.centerIn: parent
                spacing: 8

                Components.ShadowText {
                    text: "󰎟 Clear All"
                    font.pixelSize: 13
                    font.family: Services.Colors.fontFamily
                    font.weight: Font.Bold
                    color: Services.Colors.mainText
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: clearButton.opacity > 0.8 // Only clickable when fully visible
                onClicked: ncWindow.startFinalClear()
                onEntered: {
                    clearButton.color = Qt.lighter(Services.Colors.primaryContainer, 1.1)
                    clearButton.opacity = 1.0
                }
                onExited: {
                    clearButton.color = Services.Colors.primaryContainer
                    clearButton.opacity = 0.9
                }
            }
        }
    }

}
