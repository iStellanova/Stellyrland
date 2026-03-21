pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // ── Unified Data Models ──────────────────────────────────
    ListModel { id: notifModel }
    property alias notifications: notifModel
    
    property int maxHistory: ConfigService.notifMaxHistory
    property int toastLimit: ConfigService.notifToastLimit
    property int defaultTimeout: 6000
    property int dismissCooldown: 2000
    property bool dndActive: false
    onDndActiveChanged: {
        if (dndActive) {
            for (let i = 0; i < notifModel.count; i++) {
                if (notifModel.get(i).isToast) {
                    notifModel.setProperty(i, "isToast", false)
                }
            }
        }
    }

    // Track IDs that have been explicitly removed to prevent reappearance
    // Value is the timestamp when it can be allowed again
    property var dismissedIds: ({})
    
    // Fallback ID counter for apps that don't provide one
    property int _idCounter: 1000000

    // Unified Master Timer for background maintenance
    Timer {
        id: masterTimer
        interval: 1000
        repeat: true
        running: notifModel.count > 0 || Object.keys(root.dismissedIds).length > 0
        onTriggered: {
            let now = Date.now()
            
            // 1. Safety Lifetimer Check for toasts (legacy fallback)
            for (let i = 0; i < notifModel.count; i++) {
                let item = notifModel.get(i)
                if (item.isToast && item._startTime && (now - item._startTime > 60000)) { // Increased to 60s as a true 'safety'
                    notifModel.setProperty(i, "isToast", false)
                }
            }
            
            // 2. Cleanup Dismissed IDs
            let keys = Object.keys(root.dismissedIds)
            let dChanged = false
            for (let i = 0; i < keys.length; i++) {
                if (now > root.dismissedIds[keys[i]]) {
                    delete root.dismissedIds[keys[i]]
                    dChanged = true
                }
            }
            if (dChanged) root.dismissedIdsChanged()

            // 3. Cleanup Reaper List
            let rChanged = false
            for (let i = root._reaperList.length - 1; i >= 0; i--) {
                if (now > root._reaperList[i].expiry) {
                    root._reaperList.splice(i, 1)
                    rChanged = true
                }
            }
            if (rChanged) root._updateObjectList()
        }
    }

    // ── Real Object Cache (for actions) ──────────────────────
    property var _objectCache: ({}) // internalId -> Notification object
    
    NotificationServer {
        id: server
        
        bodySupported: true
        actionsSupported: true
        persistenceSupported: true
        
        onNotification: (n) => {
            if (!n) return
            
            // Set tracked to true to prevent garbage collection of the object and its actions.
            // This is required to keep handles to images and actions valid.
            n.tracked = true
            
            const s = (n.summary || "").trim()
            const b = (n.body || "").trim()
            const a = (n.appName || "").trim()
            
            let icon = ""
            const rawIcon = n.image || n.appIcon || n.icon || ""
            if (rawIcon) {
                if (typeof rawIcon === "object") {
                    if (rawIcon.url) icon = String(rawIcon.url)
                    else {
                        // Attempt to call toString if it's not [object Object], 
                        // as QML objects sometimes have custom toString for URLs.
                        let s = rawIcon.toString()
                        if (s !== "[object Object]") icon = s
                    }
                } else {
                    icon = String(rawIcon)
                }
            }
            icon = (icon || "").trim()
            
            if (n.image && typeof n.image === "object") {
                try {
                    if ("tracked" in n.image) {
                        n.image.tracked = true
                    }
                } catch(e) {}
            }

            if (icon === "[object Object]") icon = ""
            
            if (!icon && n.hints) {
                // Check common hints in order of preference
                if (n.hints["image-path"]) icon = String(n.hints["image-path"])
                else if (n.hints["image_path"]) icon = String(n.hints["image_path"])
                else if (n.hints["icon-path"]) icon = String(n.hints["icon-path"])
                else if (n.hints["icon_path"]) icon = String(n.hints["icon_path"])
                else if (n.hints["image-data"]) icon = "image://qsimage/notification/" + n.id // Ensure we try to use the image data hint if available
                else if (n.hints["image_data"]) icon = "image://qsimage/notification/" + n.id
                else if (n.hints["image-file"]) icon = String(n.hints["image-file"])
                else if (n.hints["icon-file"]) icon = String(n.hints["icon-file"])
            }

            if (s.length === 0 && b.length === 0 && a.length === 0 && icon.length === 0) return

            // Extract PID and Urgency from hints if available
            let pid = 0
            let urgency = 1 // default to Normal
            if (n.hints) {
                if (n.hints["sender-pid"] !== undefined) pid = n.hints["sender-pid"]
                else if (n.hints["pid"] !== undefined) pid = n.hints["pid"]
                
                if (n.hints["urgency"] !== undefined) urgency = n.hints["urgency"]
            }

            // 1. Find existing item by ID or Fuzzy Match
            let existingIdx = -1
            const nid = n.id !== undefined && n.id !== null ? String(n.id) : ""
            
            for (let i = 0; i < notifModel.count; i++) {
                let item = notifModel.get(i)
                if (nid !== "" && String(item.id) === nid) { existingIdx = i; break }
            }

            // Fallback to fuzzy match
            if (existingIdx === -1 && (nid === "" || parseInt(nid) >= 1000000)) {
                for (let i = 0; i < notifModel.count; i++) {
                    let item = notifModel.get(i)
                    if (item.appName === a && item.summary === s && item.body === b) { existingIdx = i; break }
                }
            }

            // If this ID was recently dismissed, ignore updates for it briefly
            if (nid !== "" && root.dismissedIds[nid]) return

            // 2. Prepare lightweight action data
            let actData = []
            if (n.actions) {
                for (let i = 0; i < n.actions.length; i++) {
                    let aObj = n.actions[i]
                    if (aObj) actData.push({ "id": String(aObj.identifier), "text": String(aObj.text) })
                }
            }

            const now = Date.now()
            const internalId = existingIdx !== -1 ? notifModel.get(existingIdx)._internalId : "internal_" + (root._idCounter++)

            // PERSISTENCE: If update doesn't have icon/actions but existing item does, keep them.
            if (existingIdx !== -1) {
                let existingItem = notifModel.get(existingIdx)
                if (icon.length === 0 && existingItem.iconSource.length > 0) {
                    icon = existingItem.iconSource
                }
                if (actData.length === 0 && existingItem.actionData && existingItem.actionData.length > 0) {
                    // This is tricky because we need the real objects too. 
                    // We'll trust the model for lightweight data and handle real objects below.
                    actData = existingItem.actionData
                }
            }

            const properties = {
                "id": nid,
                "_internalId": internalId,
                "summary": s,
                "body": b,
                "appName": a.length > 0 ? a : "System",
                "iconSource": icon,
                "actionData": actData,
                "desktopEntry": (n.desktopEntry || "").trim(),
                "pid": pid,
                "urgency": urgency,
                "originalAppName": n.appName || "", // Keep the raw one for focusing
                "expireTimeout": n.expireTimeout !== undefined ? n.expireTimeout : -1,
                "_startTime": now,
                "isToast": !root.dndActive,
                "isClosing": false
            }

            // Cache real object and its actions explicitly
            let actions = []
            if (n.actions && n.actions.length > 0) {
                for (let i = 0; i < n.actions.length; i++) {
                    if (n.actions[i]) actions.push(n.actions[i])
                }
            } else if (existingIdx !== -1) {
                // Persist real actions if update has none
                let oldCache = root._objectCache[internalId]
                if (oldCache && oldCache.actions) actions = oldCache.actions
            }
            
            root._objectCache[internalId] = { "obj": n, "actions": actions }

            if (existingIdx !== -1) {
                // Move old object to reaper to keep its images alive during transition
                let oldIid = notifModel.get(existingIdx)._internalId
                let oldCache = root._objectCache[oldIid]
                if (oldCache && oldCache.obj) {
                    root._reaperList.push({ "obj": oldCache.obj, "expiry": Date.now() + 30000 }) // Increased to 30s
                }

                notifModel.set(existingIdx, properties)
                if (existingIdx !== 0) notifModel.move(existingIdx, 0, 1)
            } else {
                notifModel.insert(0, properties)
                if (notifModel.count > root.maxHistory) {
                    let dropped = notifModel.get(notifModel.count - 1)
                    if (dropped) {
                        let cache = root._objectCache[dropped._internalId]
                        if (cache && cache.obj) cache.obj.tracked = false
                        delete root._objectCache[dropped._internalId]
                    }
                    notifModel.remove(notifModel.count - 1)
                }
            }

            // Enforce toast limit
            let toastCount = 0
            for (let i = 0; i < notifModel.count; i++) {
                if (notifModel.get(i).isToast) {
                    toastCount++
                    if (toastCount > root.toastLimit) notifModel.setProperty(i, "isToast", false)
                }
            }
            // Explicitly update object list whenever model changes
            root._updateObjectList()
        }
    }

    // Connections to trigger GC protection updates on any model change
    Connections {
        target: notifModel
        function onDataChanged() { root._updateObjectList() }
        function onRowsInserted() { root._updateObjectList() }
        function onRowsRemoved() { root._updateObjectList() }
        function onModelReset() { root._updateObjectList() }
    }

    function removeActiveToast(iid) {
        if (!iid) return
        for (let i = 0; i < notifModel.count; i++) {
            if (notifModel.get(i)._internalId === iid) {
                notifModel.setProperty(i, "isToast", false)
                break
            }
        }
    }

    function dismissNotificationByInternalId(iid) {
        if (!iid) return
        for (let i = 0; i < notifModel.count; i++) {
            let item = notifModel.get(i)
            if (item._internalId === iid) {
                let cache = root._objectCache[iid]
                if (cache && cache.obj) {
                    cache.obj.tracked = false
                    // Also put dismissed object in reaper just in case it's still visible during animation
                    root._reaperList.push({ "obj": cache.obj, "expiry": Date.now() + 5000 })
                }
                
                if (item.id) {
                    root.dismissedIds[item.id] = Date.now() + root.dismissCooldown
                    root.dismissedIdsChanged()
                }
                
                // Clear real object
                delete root._objectCache[iid]
                notifModel.remove(i)
                root._updateObjectList()
                break
            }
        }
    }

    // Keep a list of all current and recently-seen notification objects to prevent garbage collection
    // which causes image://qsimage handles to break.
    property var _notificationObjects: []
    property var _reaperList: [] // objects kept alive temporarily: {obj, expiry}

    function _updateObjectList() {
        let newList = []
        
        // 1. Current objects
        for (let i = 0; i < notifModel.count; i++) {
            let row = notifModel.get(i)
            if (!row) continue
            let iid = row._internalId
            let cache = root._objectCache[iid]
            if (cache) {
                if (cache.obj) {
                    newList.push(cache.obj)
                    // Keep sub-objects alive too just in case
                    if (cache.obj.image && typeof cache.obj.image === "object") newList.push(cache.obj.image)
                    if (cache.obj.appIcon && typeof cache.obj.appIcon === "object") newList.push(cache.obj.appIcon)
                }
                if (cache.actions) {
                    for (let j = 0; j < cache.actions.length; j++) {
                        if (cache.actions[j]) newList.push(cache.actions[j])
                    }
                }
            }
        }

        // 2. Reaper objects (recently updated/dismissed)
        for (let i = 0; i < root._reaperList.length; i++) {
            let r = root._reaperList[i]
            if (r && r.obj) {
                newList.push(r.obj)
                if (r.obj.image && typeof r.obj.image === "object") newList.push(r.obj.image)
                if (r.obj.appIcon && typeof r.obj.appIcon === "object") newList.push(r.obj.appIcon)
            }
        }

        root._notificationObjects = newList
    }

    onNotificationsChanged: root._updateObjectList()

    function clearHistory() {
        for (let iid in root._objectCache) {
            let cache = root._objectCache[iid]
            if (cache && cache.obj) cache.obj.tracked = false
        }
        notifModel.clear()
        root._objectCache = {}
        root._updateObjectList()
    }

    function invokeActionByInternalId(iid, act) {
        let cache = root._objectCache[iid]
        if (!cache) return
        
        if (act && act.id) {
            let realAct = null
            let actions = cache.actions || []
            for (let i = 0; i < actions.length; i++) {
                if (actions[i] && String(actions[i].id) === String(act.id)) {
                    realAct = actions[i]
                    break
                }
            }
            if (realAct && typeof realAct.invoke === "function") {
                realAct.invoke()
                root.dismissNotificationByInternalId(iid)
            }
        } else {
            root.focusApp(iid)
            root.invokeDefaultActionByInternalId(iid)
        }
    }

    function focusApp(iid) {
        let item = null
        for (let i = 0; i < notifModel.count; i++) {
            if (notifModel.get(i)._internalId === iid) {
                item = notifModel.get(i)
                break
            }
        }
        if (!item) return
        
        if (item.pid > 0) {
            root._runFocus(["hyprctl", "dispatch", "focuswindow", "pid:" + item.pid])
        } else {
            // Try focusing by originalAppName first, then stylized appName
            let app = item.originalAppName || item.appName || ""
            if (app.length > 0) {
                // Escape single quotes for shell/hyprctl command
                let escapedApp = app.replace(/'/g, "'\\''")
                // Try focusing by class name (case insensitive fuzzy match)
                let cmd = "hyprctl dispatch focuswindow 'class:^(?i).*" + escapedApp + ".*$'"
                root._runFocus(["sh", "-c", cmd])
            }
        }
    }

    function invokeDefaultActionByInternalId(iid) {
        let cache = root._objectCache[iid]
        if (!cache) return
        
        let n = cache.obj
        let actions = cache.actions || []
        
        try {
            let defaultAction = null
            for (let i = 0; i < actions.length; i++) {
                let actId = String(actions[i].identifier)
                if (actId === "default" || actId === "") {
                    defaultAction = actions[i]
                    break
                }
            }
            // Fallback to first action if it's the only one
            if (!defaultAction && actions.length === 1 && actions[0]) {
                defaultAction = actions[0]
            }
            
            if (defaultAction && typeof defaultAction.invoke === "function") {
                defaultAction.invoke()
            } else {
                let desktopEntry = ""
                for (let i = 0; i < notifModel.count; i++) {
                    if (notifModel.get(i)._internalId === iid) {
                        desktopEntry = notifModel.get(i).desktopEntry
                        break
                    }
                }

                if (desktopEntry && desktopEntry.length > 0) {
                    root._runOneShot(["gtk-launch", desktopEntry])
                }
            }
            
            // Delay dismissal slightly to ensure DBus message is sent and app has time to react
            // before we destroy the notification object.
            dismissTimer.iid = iid
            dismissTimer.start()
        } catch (e) {
            root.dismissNotificationByInternalId(iid)
        }
    }

    Timer {
        id: dismissTimer
        interval: 500
        property string iid: ""
        onTriggered: root.dismissNotificationByInternalId(iid)
    }

    function _runOneShot(cmd) {
        let proc = procFactory.createObject(root, { command: cmd })
        proc.running = true
    }

    function _runFocus(cmd) {
        let proc = procFactory.createObject(root, { command: cmd })
        proc.running = true
    }

    Component {
        id: procFactory
        Process {
            onRunningChanged: if (!running) this.destroy()
        }
    }
}
