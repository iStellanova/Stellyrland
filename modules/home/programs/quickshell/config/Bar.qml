import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "services" as Services
import "components" as Components

PanelWindow {
    id: bar
    screen: Services.MonitorService.primaryScreen
    WlrLayershell.layer: WlrLayer.Overlay
    visible: !Services.ShellData.hasFullscreen && !logoutVisible
    property var trayMenu
    property var activeWorkspaceButton: null
    property bool logoutVisible: false

    Component {
        id: barBorderMaskComponent
        Canvas {
            id: canvas
            
            property color strokeColor: Services.Colors.border
            property real r: Services.Colors.radiusNormal

            property var popupState: [
                { name: "nix",      w: 350, cr: 12 },
                { name: "cal",      w: 330, cr: 12 },
                { name: "traffic",  w: 400, cr: 12 },
                { name: "ram",      w: 330, cr: 12 },
                { name: "cpu",      w: 330, cr: 12 },
                { name: "gpu",      w: 330, cr: 12 },
                { name: "temp",     w: 330, cr: 12 },
                { name: "media",    w: 330, cr: 12 },
                { name: "mic",      w: 330, cr: 12 },
                { name: "volume",   w: 330, cr: 12 },
                { name: "cc",       w: 330, cr: 12 },
                { name: "nc",       w: 340, cr: 12 }
            ]

            property var logicalState: ({})
            property var closeTimers: ({})

            // Trigger paint when any relevant popup state changes
            Connections {
                target: Services.ShellData
                function onPopupsChanged() {
                    for (let i = 0; i < canvas.popupState.length; i++) {
                        let name = canvas.popupState[i].name
                        let isRequested = Services.ShellData.isPopupVisible(name)
                        
                        if (isRequested) {
                            if (closeTimers[name]) {
                                closeTimers[name].stop()
                                closeTimers[name].destroy()
                                closeTimers[name] = null
                            }
                            if (!logicalState[name]) {
                                logicalState[name] = true
                                canvas.requestPaint()
                            }
                        } else {
                            if (logicalState[name] && !closeTimers[name]) {
                                let t = Qt.createQmlObject(`import QtQuick; Timer { interval: ${Services.Colors.animFast}; repeat: false }`, canvas, 'timer_' + name);
                                t.triggered.connect(function() {
                                    logicalState[name] = false
                                    canvas.requestPaint()
                                    t.destroy()
                                    closeTimers[name] = null
                                })
                                closeTimers[name] = t
                                t.start()
                            }
                        }
                    }
                }
            }

            onWidthChanged: canvas.requestPaint()
            onHeightChanged: canvas.requestPaint()

            onPaint: {
                let ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = strokeColor
                ctx.lineWidth = 1
                ctx.beginPath()

                let localOffset = Math.round(canvas.mapToItem(null, 0, 0).x) + bar.margins.left
                let holes = []
                
                for (let i = 0; i < popupState.length; i++) {
                    let p = popupState[i]
                    if (logicalState[p.name]) {
                        let offset = Services.ShellData.getPopupOffset(p.name)
                        if (offset !== 0) {
                            let centerX = Math.round(offset - localOffset)
                            let halfW = p.w / 2 + p.cr
                            holes.push({
                                start: centerX - halfW - 1, // 1px expansion
                                end: centerX + halfW + 1     // 1px expansion
                            })
                        }
                    }
                }

                holes.sort((a, b) => a.start - b.start)

                ctx.clearRect(0, 0, width, height)
                
                const o = 0.5
                const bottomY = height - o

                // --- Pass 1: Background Fill (Hole-Aware) ---
                ctx.fillStyle = Services.Colors.bg
                ctx.beginPath()
                ctx.moveTo(o, r)
                ctx.arc(r, r, r - o, Math.PI, Math.PI * 1.5, false)
                ctx.lineTo(width - r, o)
                ctx.arc(width - r, r, r - o, Math.PI * 1.5, Math.PI * 2, false)
                ctx.lineTo(width - o, height - r)
                ctx.arc(width - r, height - r, r - o, 0, Math.PI * 0.5, false)
                
                // Draw bottom edge with "bites" out of it for holes
                let curFillX = width - r
                for (let i = holes.length - 1; i >= 0; i--) {
                    let h = holes[i]
                    let hEnd = Math.min(h.end, curFillX)
                    let hStart = Math.max(h.start, r)
                    
                    if (hEnd > hStart) {
                        ctx.lineTo(hEnd, bottomY)
                        ctx.lineTo(hEnd, height + 10) // Bite exit
                        ctx.lineTo(hStart, height + 10) // Bite bottom
                        ctx.lineTo(hStart, bottomY) // Bite reentry
                        curFillX = hStart
                    }
                }
                ctx.lineTo(r, bottomY)
                ctx.arc(r, height - r, r - o, Math.PI * 0.5, Math.PI, false)
                ctx.closePath()
                ctx.fill()

                // --- Pass 2: Outer Border Stroke (Hole-Aware) ---
                ctx.strokeStyle = Services.Colors.border
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.moveTo(o, r)
                ctx.arc(r, r, r - o, Math.PI, Math.PI * 1.5, false)
                ctx.lineTo(width - r, o)
                ctx.arc(width - r, r, r - o, Math.PI * 1.5, Math.PI * 2, false)
                ctx.lineTo(width - o, height - r)
                ctx.arc(width - r, height - r, r - o, 0, Math.PI * 0.5, false)
                
                let curStrokeX = width - r
                for (let i = holes.length - 1; i >= 0; i--) {
                    let h = holes[i]
                    let hEnd = Math.min(h.end, curStrokeX)
                    let hStart = Math.max(h.start, r)

                    if (hEnd > hStart) {
                        ctx.lineTo(hEnd, bottomY)
                        ctx.moveTo(hStart, bottomY)
                        curStrokeX = hStart
                    }
                }
                
                if (curStrokeX > r) ctx.lineTo(r, bottomY)
                
                ctx.arc(r, height - r, r - o, Math.PI * 0.5, Math.PI, false)
                ctx.lineTo(o, r)
                ctx.stroke()
            }
        }
    }

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 15
        left: 15
        right: 15
    }

    implicitHeight: 42
    exclusiveZone: 42  // Height of the bar; margin is added by Quickshell/Hyprland for the total reserved space.
    color: "transparent"

    // ── Signals for popup toggling ───────────────────────────
    signal togglePopup(string name, real xPos)

    // ── Bar background ──────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // ═══════════════════════════════════════════
        // LEFT SECTION
        // ═══════════════════════════════════════════
        Rectangle {
            id: leftBubble
            anchors.left: parent.left
            height: parent.height
            width: leftRow.implicitWidth + 24
            radius: Services.Colors.radiusNormal
            clip: true

            Behavior on width {
                NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
            }
            color: "transparent"
            border.width: 0
            Loader {
                anchors.fill: parent
                sourceComponent: barBorderMaskComponent
            }

            // Animated selection box
            Rectangle {
                id: workspaceSelectionBox
                anchors.verticalCenter: parent.verticalCenter
                z: 1
                height: 26
                radius: Services.Colors.radiusSmall
                color: Services.Colors.alpha(Services.Colors.primary, 0.12)
                
                border.color: Services.Colors.alpha(Services.Colors.primary, 0.05)

                property var targetButton: bar.activeWorkspaceButton

                // Fade in/out when we have a target (e.g. focus moves to/from this monitor)
                opacity: targetButton && targetButton.visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }

                // Direct relative positioning
                x: targetButton ? leftRow.x + targetButton.x : 0
                width: targetButton ? targetButton.width : 0

                Behavior on x { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }
                Behavior on width { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }
            }

            RowLayout {
                id: leftRow
                z: 2
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: Services.Colors.spacingSmall

                // Control Center button
                Components.BarButton {
                    id: nixButton
                    text: "󱄅"
                    fontSize: Services.Colors.fontSizeLarge
                    textColor: Services.Colors.primary
                    bgColor: Services.Colors.alpha(Services.Colors.primary, 0.15)
                    active: Services.ShellData.isPopupVisible("cc")
                    onClicked: {
                        let pos = leftBubble.mapToItem(null, 177, 0) // Align left edge of popup (w:330, cr:12) with bubble start
                        bar.togglePopup("cc", pos.x + bar.margins.left)
                    }
                }

                // Workspaces
                Repeater {
                    id: wsRepeater
                    model: Hyprland.workspaces

                    Components.WorkspaceButton {
                        id: wsBtn
                        required property HyprlandWorkspace modelData
                        workspaceId: modelData.id
                        isActive: modelData.active
                        isFocused: modelData.focused
                        onActivate: function() { modelData.activate() }
                        visible: modelData.id > 0  // hide special workspaces

                        // Focus-based tracking: follow focus across monitors
                        function updateFocused() {
                            if (isFocused) {
                                bar.activeWorkspaceButton = wsBtn
                            } else if (bar.activeWorkspaceButton === wsBtn) {
                                bar.activeWorkspaceButton = null
                            }
                        }

                        onIsFocusedChanged: updateFocused()
                        Component.onCompleted: updateFocused()

                        onHoverStarted: (x, y) => {
                            wsPreview.workspaceId = modelData.id
                            wsPreview.xOffset = x
                            wsPreview.open = true
                        }
                        onHoverEnded: wsPreview.open = false
                    }
                }

                Components.WorkspacePreview {
                    id: wsPreview
                    open: false
                }

                // Audio Visualizer
                Components.SpectrumVisualizer {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true
                    Layout.topMargin: Services.Colors.spacingNormal
                    Layout.bottomMargin: Services.Colors.spacingNormal
                    opacity: 0.8
                    visible: Services.ShellData.cavaData.length > 0
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    mirrored: true
                }

                Item {
                    id: titleContainer
                    Layout.maximumWidth: 350
                    property real targetWidth: hiddenTitleMetric.text.length > 0 ? Math.min(hiddenTitleMetric.implicitWidth, 350) : 0
                    Layout.preferredWidth: targetWidth
                    implicitHeight: titleText.implicitHeight
                    clip: true
                    Layout.leftMargin: targetWidth > 0 ? 5 : 0
                    visible: targetWidth > 0 || width > 0

                    Components.ShadowText {
                        id: hiddenTitleMetric
                        text: Services.ShellData.windowTitle
                        visible: false
                    }

                    Components.ShadowText {
                        id: titleText
                        text: Services.ShellData.windowTitle
                        color: Services.Colors.mainText
                        elide: Text.ElideRight
                        width: titleContainer.width
                    }
                }
            }
        }

        // ═══════════════════════════════════════════
        // CENTER SECTION — MPRIS
        // ═══════════════════════════════════════════
        Rectangle {
            id: mprisBubble
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: Math.max(mprisRow.implicitWidth + 24, 380)
            radius: Services.Colors.radiusNormal
            clip: true
            Behavior on width {
                NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
            }

            color: "transparent"
            border.width: 0

            Loader {
                anchors.fill: parent
                sourceComponent: barBorderMaskComponent
            }



            visible: {
                let p = Services.Music.player
                return p !== null && p.playbackState !== MprisPlaybackState.Stopped
            }

            RowLayout {
                id: mprisRow
                anchors.centerIn: parent
                spacing: 8

                // Media Controls
                RowLayout {
                    spacing: 4

                    Components.BarButton {
                        text: "󰒮"
                        fontSize: 14
                        onClicked: { if (Services.Music.player) Services.Music.player.previous() }
                    }

                    Components.BarButton {
                        text: {
                            let p = Services.Music.player
                            if (!p) return ""
                            return p.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                        }
                        fontSize: 14
                        onClicked: { if (Services.Music.player) Services.Music.player.togglePlaying() }
                    }

                    Components.BarButton {
                        text: "󰒭"
                        fontSize: 14
                        onClicked: { if (Services.Music.player) Services.Music.player.next() }
                    }
                }

                // Track Information
                Rectangle {
                    implicitWidth: trackInfoText.implicitWidth + 12
                    implicitHeight: 26
                    radius: Services.Colors.radiusSmall
                    color: {
                        if (Services.ShellData.isPopupVisible("media")) return Services.Colors.alpha(Services.Colors.primary, 0.4)
                        if (textMouse.pressed) return Services.Colors.alpha(Services.Colors.primary, 0.35)
                        if (textMouse.containsMouse) return Services.Colors.alpha(Services.Colors.primary, 0.2)
                        return "transparent"
                    }
                    scale: textMouse.pressed || Services.ShellData.isPopupVisible("media") ? 0.95 : 1.0
                    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                    Components.MarqueeText {
                        id: trackInfoText
                        anchors.centerIn: parent
                        text: {
                            let p = Services.Music.player
                            if (!p) return ""
                            let t = p.trackTitle || "Unknown Track"
                            let a = p.trackArtist || "Unknown Artist"
                            return a.length > 0 ? (t + " - " + a) : t
                        }
                        maxWidth: 380
                        color: (textMouse.containsMouse || Services.ShellData.isPopupVisible("media")) ? Services.Colors.primary : Services.Colors.mainText
                    }

                    MouseArea {
                        id: textMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let pos = mprisBubble.mapToItem(null, mprisBubble.width / 2, 0)
                            bar.togglePopup("media", pos.x + bar.margins.left)
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════
        // RIGHT SECTION
        // ═══════════════════════════════════════════
        Rectangle {
            id: rightBubble
            anchors.right: parent.right
            height: parent.height
            width: rightRow.implicitWidth + 24
            radius: Services.Colors.radiusNormal
            clip: true
            Behavior on width {
                NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
            }
            color: "transparent"
            border.width: 0

            Loader {
                anchors.fill: parent
                sourceComponent: barBorderMaskComponent
            }

            RowLayout {
                id: rightRow
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: Services.Colors.spacingSmall

                // System Tray
                RowLayout {
                    spacing: Services.Colors.spacingSmall
                    Layout.rightMargin: 8
                    Repeater {
                        model: SystemTray.items
                        delegate: Rectangle {
                            id: trayItem
                            implicitWidth: 26; implicitHeight: 26
                            radius: Services.Colors.radiusSmall
                            color: trayMouse.containsMouse ? Services.Colors.alpha(Services.Colors.mainText, 0.1) : "transparent"

                            Image {
                                id: trayIcon
                                anchors.centerIn: parent
                                source: Services.IconStore.getIconPath(modelData.icon)
                                width: 18; height: 18
                                sourceSize: Qt.size(36, 36)
                                asynchronous: true
                                visible: status === Image.Ready
                            }
                            
                            // Fallback if image fails or is missing
                            Components.ShadowText {
                                anchors.centerIn: parent
                                text: "󰝚" // generic icon
                                font.pixelSize: 14
                                color: Services.Colors.primary
                                visible: trayIcon.status !== Image.Ready || trayIcon.source.toString() === ""
                            }

                            MouseArea {
                                id: trayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.LeftButton) {
                                        modelData.activate()
                                    } else if (mouse.button === Qt.RightButton) {
                                        var menu = modelData.menu;
                                        if (menu) {
                                            var pos = trayItem.mapToItem(null, 0, 0);
                                            trayMenu.xOffset = pos.x + (trayItem.width / 2) - 100 + bar.margins.left; // Center menu (width 200)
                                            trayMenu.menuHandle = menu;
                                            trayMenu.visible = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Microphone usage indicator
                Components.BarModule {
                    id: micMod
                    interactive: true
                    active: Services.ShellData.isPopupVisible("mic")
                    onClicked: {
                        let pos = micMod.mapToItem(null, micMod.width / 2, 0)
                        bar.togglePopup("mic", pos.x + bar.margins.left)
                    }
                    icon: "󰍬"
                    visible: Services.AudioService.micBusy
                    Layout.rightMargin: 8
                }

                // Nix Monitor
                Components.BarModule {
                    id: nixMod
                    interactive: true
                    active: Services.ShellData.isPopupVisible("nix")
                    onClicked: {
                        let pos = nixMod.mapToItem(null, 187, 0) // Align left edge of popup (w:350, cr:12) with module start
                        bar.togglePopup("nix", pos.x + bar.margins.left)
                    }
                    icon: "󱄅"
                    value: Services.ShellData.nixGenerations
                    visible: true
                }

                // Temperature
                Components.BarModule {
                    id: tempModule
                    interactive: true
                    active: Services.ShellData.isPopupVisible("temp")
                    onClicked: {
                        let pos = tempModule.mapToItem(null, 177, 0) // Align left edge of popup (w:330, cr:12) with module start
                        bar.togglePopup("temp", pos.x + bar.margins.left)
                    }
                    icon: ""
                    value: Services.ShellData.temperature + "°C"
                    textColor: Services.ShellData.temperature >= 90
                        ? Services.Colors.primary : Services.Colors.mainText
                    bgColor: Services.ShellData.temperature >= 90
                        ? Services.Colors.alpha(Services.Colors.primary, 0.15)
                        : "transparent"
                    Layout.leftMargin: 4
                }

                // CPU
                Components.BarModule {
                    id: cpuModule
                    interactive: true
                    active: Services.ShellData.isPopupVisible("cpu")
                    onClicked: {
                        let pos = cpuModule.mapToItem(null, cpuModule.width / 2, 0)
                        bar.togglePopup("cpu", pos.x + bar.margins.left)
                    }
                    icon: ""
                    value: Services.ShellData.cpuUsage + "%"
                    Layout.leftMargin: 9
                }

                // GPU
                Components.BarModule {
                    id: gpuModule
                    interactive: true
                    active: Services.ShellData.isPopupVisible("gpu")
                    onClicked: {
                        let pos = gpuModule.mapToItem(null, gpuModule.width / 2, 0)
                        bar.togglePopup("gpu", pos.x + bar.margins.left)
                    }
                    icon: "󰢮"
                    value: Services.ShellData.gpuUsage + "%"
                    Layout.leftMargin: 9
                }

                // Memory
                Components.BarModule {
                    id: ramModule
                    interactive: true
                    active: Services.ShellData.isPopupVisible("ram")
                    onClicked: {
                        let pos = ramModule.mapToItem(null, ramModule.width / 2, 0)
                        bar.togglePopup("ram", pos.x + bar.margins.left)
                    }
                    icon: ""
                    value: Services.ShellData.ramUsage
                    Layout.leftMargin: 9
                }

                // Network
                Components.BarModule {
                    id: wifiModule
                    interactive: true
                    active: Services.ShellData.isPopupVisible("traffic")
                    onClicked: {
                        let pos = wifiModule.mapToItem(null, wifiModule.width / 2, 0)
                        bar.togglePopup("traffic", pos.x + bar.margins.left)
                    }
                    icon: Services.NetworkService.netSsid === "Offline" ? "󰖪" : "󰤨"
                    value: Services.NetworkService.netSsid !== "Offline" ? Services.NetworkService.netSsid : ""
                    textColor: Services.NetworkService.netSsid === "Offline"
                        ? Services.Colors.alpha(Services.Colors.mainText, 0.35)
                        : Services.Colors.mainText
                    Layout.leftMargin: 9
                }

                // Volume
                Components.BarModule {
                    id: volModule
                    interactive: true
                    active: Services.ShellData.isPopupVisible("volume")
                    onClicked: {
                        let pos = volModule.mapToItem(null, volModule.width / 2, 0)
                        bar.togglePopup("volume", pos.x + bar.margins.left)
                    }
                    icon: {
                        if (Services.AudioService.muted) return "󰝟"
                        let v = Services.AudioService.volume
                        if (v === 0) return "󰕿"
                        if (v < 20) return "󰕿"
                        if (v < 40) return "󰖀"
                        if (v < 60) return "󰖀"
                        if (v < 80) return "󰕾"
                        return "󰕾"
                    }
                    textColor: Services.AudioService.muted 
                        ? Services.Colors.alpha(Services.Colors.mainText, 0.4) 
                        : Services.Colors.mainText
                    Layout.leftMargin: 9
                }

                // Clock (native SystemClock)
                Rectangle {
                    id: clockRect
                    implicitWidth: clockText.implicitWidth + 32
                    implicitHeight: 26
                    radius: Services.Colors.radiusSmall
                    property bool isHighlighted: clockMouse.pressed || Services.ShellData.isPopupVisible("cal")
                    scale: isHighlighted ? 0.95 : 1.0
                    color: {
                        if (isHighlighted) return Services.Colors.alpha(Services.Colors.primary, 0.2)
                        if (clockMouse.containsMouse) return Services.Colors.alpha(Services.Colors.primary, 0.1)
                        return "transparent"
                    }

                    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                    SystemClock {
                        id: sysClock
                        precision: SystemClock.Minutes
                    }

                    Components.ShadowText {
                        id: clockText
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(sysClock.date, "ddd dd MMM   hh:mm AP")
                        color: (clockMouse.containsMouse || clockRect.isHighlighted) ? Services.Colors.primary : Services.Colors.mainText
                    }

                    MouseArea {
                        id: clockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let pos = clockRect.mapToItem(null, clockRect.width / 2, 0)
                            bar.togglePopup("cal", pos.x + bar.margins.left)
                        }
                    }
                }

                // Notification Center button
                Components.BarButton {
                    id: notifButton
                    text: "󰅺"
                    fontSize: Services.Colors.fontSizeLarge
                    textColor: Services.Colors.primary
                    bgColor: Services.Colors.alpha(Services.Colors.primary, 0.15)
                    active: Services.ShellData.isPopupVisible("nc")
                    onClicked: {
                        let pos = notifButton.mapToItem(null, notifButton.width / 2, 0)
                        bar.togglePopup("nc", pos.x + bar.margins.left)
                    }
                }
            }
        }
    }
}
