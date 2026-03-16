import Quickshell
import QtQuick
import QtQuick.Layouts
import "services" as Services
import "components" as Components

PanelWindow {
    id: popupWindow

    implicitWidth: 390
    implicitHeight: mainColumn.contentHeight

    visible: stableToasts.count > 0 && !Services.NotificationService.dndActive

    focusable: false
    exclusiveZone: 0
    anchors { top: true; right: true }
    margins { top: 20; right: 20 }
    color: "transparent"

    ListModel { id: stableToasts }

    function updateToasts() {
        if (Services.NotificationService.dndActive) {
            stableToasts.clear()
            return
        }

        const source = Services.NotificationService.notifications
        const activeIds = new Set()
        
        for (let i = 0; i < source.count; i++) {
            const item = source.get(i)
            if (item.isToast) activeIds.add(item._internalId)
        }

        // Remove old toasts
        for (let i = stableToasts.count - 1; i >= 0; i--) {
            if (!activeIds.has(stableToasts.get(i)._internalId)) {
                stableToasts.remove(i)
            }
        }

        // Update or insert toasts
        for (let i = 0; i < source.count; i++) {
            const item = source.get(i)
            if (!item.isToast) continue

            let foundIdx = -1
            for (let j = 0; j < stableToasts.count; j++) {
                if (stableToasts.get(j)._internalId === item._internalId) {
                    foundIdx = j; break
                }
            }

            const props = {
                "_internalId": item._internalId,
                "appName": item.appName,
                "summary": item.summary,
                "body": item.body,
                "iconSource": item.iconSource,
                "actionData": item.actionData,
                "desktopEntry": item.desktopEntry,
                "pid": item.pid,
                "urgency": item.urgency,
                "expireTimeout": item.expireTimeout,
                "isClosing": item.isClosing
            }

            if (foundIdx === -1) stableToasts.insert(0, props)
            else stableToasts.set(foundIdx, props)
        }
    }

    Connections {
        target: Services.NotificationService.notifications
        function onDataChanged() { popupWindow.updateToasts() }
        function onRowsInserted() { popupWindow.updateToasts() }
        function onRowsRemoved() { popupWindow.updateToasts() }
    }

    Connections {
        target: Services.NotificationService
        function onDndActiveChanged() { popupWindow.updateToasts() }
    }

    ListView {
        id: mainColumn
        width: parent.width
        height: contentHeight
        interactive: false
        spacing: 12
        model: stableToasts

        delegate: Item {
            id: delegateRoot
            width: mainColumn.width
            height: card.implicitHeight
            clip: true
            
            readonly property bool isClosing: model.isClosing

            Components.NotificationItem {
                id: card
                width: popupWindow.width - 20
                
                opacity: delegateRoot.isClosing ? 0 : 1.0
                x: delegateRoot.isClosing ? 450 : 0

                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                appName: model.appName
                summary: model.summary
                body: model.body
                iconSource: model.iconSource
                actions: model.actionData
                desktopEntry: model.desktopEntry
                pid: model.pid
                urgency: model.urgency

                showProgress: true
                progressDuration: (model.expireTimeout > 0) ? model.expireTimeout : Services.NotificationService.defaultTimeout
                isPaused: card.mouseAreaHovered

                onAction: (act) => Services.NotificationService.invokeActionByInternalId(model._internalId, act)
                onDismissed: Services.NotificationService.dismissNotificationByInternalId(model._internalId)
                onExpired: Services.NotificationService.removeActiveToast(model._internalId)
            }
        }
    }
}
