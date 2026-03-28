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
    signal toggleControlCenter()
    signal toggleNotificationCenter()
    signal toggleCalendar(real xPos)
    signal toggleWifiMenu(real xPos)
    signal toggleRamMenu(real xPos)
    signal toggleCpuMenu(real xPos)
    signal toggleGpuMenu(real xPos)
    signal toggleTempMenu(real xPos)
    signal toggleMediaMenu(real xPos)
    signal toggleUpdatesMenu(real xPos)
    signal toggleMicMenu(real xPos)
    signal toggleVolumeMenu(real xPos)

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
            color: Services.Colors.bg
            border.width: 1
            border.color: Services.Colors.border

            // Animated selection box
            Rectangle {
                id: workspaceSelectionBox
                anchors.verticalCenter: parent.verticalCenter
                z: 1
                height: 26
                radius: Services.Colors.radiusSmall
                color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12)
                border.width: 1
                border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.05)

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
                anchors.verticalCenter: parent.verticalCenter
                spacing: Services.Colors.spacingSmall

                // Control Center button
                Components.BarButton {
                    id: archButton
                    iconSource: Quickshell.shellDir + "/logo.svg"
                    fontSize: Services.Colors.fontSizeLarge
                    textColor: Services.Colors.primary
                    bgColor: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15)
                    active: Services.ShellData.ccVisible
                    onClicked: {
                        bar.toggleControlCenter()
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

                // Cava
                Components.CavaVisualizer {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 20
                    color: Services.Colors.mainText
                    barOpacity: 1.0
                    visible: Services.ShellData.cavaData.length > 0
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
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
            width: mprisRow.implicitWidth + 24
            radius: Services.Colors.radiusNormal
            clip: true
            Behavior on width {
                NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
            }

            color: Services.Colors.bg
            border.width: 1
            border.color: Services.Colors.border

            scale: 1.0

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

                    // Previous track
                    Rectangle {
                        implicitWidth: 28; implicitHeight: 26; radius: Services.Colors.radiusSmall
                        color: prevMouse.pressed ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35)
                               : (prevMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) : "transparent")
                        scale: prevMouse.pressed ? 0.95 : 1.0
                        Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                        Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: "󰒮"
                            font.pixelSize: 14
                            color: prevMouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
                        }
                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { if (Services.Music.player) Services.Music.player.previous() }
                        }
                    }

                    // Play/Pause toggle
                    Rectangle {
                        implicitWidth: 28; implicitHeight: 26; radius: Services.Colors.radiusSmall
                        color: playMouse.pressed ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35)
                               : (playMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) : "transparent")
                        scale: playMouse.pressed ? 0.95 : 1.0
                        Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                        Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: {
                                let p = Services.Music.player
                                if (!p) return ""
                                return p.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                            }
                            font.pixelSize: 14
                            color: playMouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
                        }
                        MouseArea {
                            id: playMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { if (Services.Music.player) Services.Music.player.togglePlaying() }
                        }
                    }

                    // Next track
                    Rectangle {
                        implicitWidth: 28; implicitHeight: 26; radius: Services.Colors.radiusSmall
                        color: nextMouse.pressed ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35)
                               : (nextMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) : "transparent")
                        scale: nextMouse.pressed ? 0.95 : 1.0
                        Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                        Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: "󰒭"
                            font.pixelSize: 14
                            color: nextMouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
                        }
                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { if (Services.Music.player) Services.Music.player.next() }
                        }
                    }
                }

                // Track Information
                Rectangle {
                    implicitWidth: trackInfoText.implicitWidth + 12
                    implicitHeight: 26
                    radius: Services.Colors.radiusSmall
                    color: {
                        if (Services.ShellData.mediaVisible) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.4)
                        if (textMouse.pressed) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35)
                        if (textMouse.containsMouse) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2)
                        return "transparent"
                    }
                    scale: textMouse.pressed || Services.ShellData.mediaVisible ? 0.95 : 1.0
                    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic } }

                    Components.ShadowText {
                        id: trackInfoText
                        anchors.centerIn: parent
                        text: {
                            let p = Services.Music.player
                            if (!p) return ""
                            let t = p.trackTitle || "Unknown Track"
                            let a = p.trackArtist || "Unknown Artist"
                            return a.length > 0 ? (t + " - " + a) : t
                        }
                        Layout.maximumWidth: 400
                        elide: Text.ElideRight
                        color: (textMouse.containsMouse || Services.ShellData.mediaVisible) ? Services.Colors.primary : Services.Colors.mainText
                    }

                    MouseArea {
                        id: textMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let pos = mprisBubble.mapToItem(null, mprisBubble.width / 2, 0)
                            bar.toggleMediaMenu(pos.x)
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
            color: Services.Colors.bg
            border.width: 1
            border.color: Services.Colors.border

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
                            color: trayMouse.containsMouse ? Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.1) : "transparent"

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
                                            trayMenu.xOffset = pos.x + (trayItem.width / 2) - 100; // Center menu (width 200)
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
                    active: Services.ShellData.micVisible
                    onClicked: {
                        let pos = micMod.mapToItem(null, micMod.width / 2, 0)
                        bar.toggleMicMenu(pos.x)
                    }
                    icon: "󰍬"
                    visible: Services.AudioService.micBusy
                    Layout.rightMargin: 8
                }

                // Pacman updates
                Components.BarModule {
                    id: pacmanMod
                    interactive: true
                    active: Services.ShellData.updatesVisible
                    onClicked: {
                        let pos = pacmanMod.mapToItem(null, pacmanMod.width / 2, 0)
                        bar.toggleUpdatesMenu(pos.x)
                    }
                    icon: "󰮯"
                    value: Services.ShellData.pacmanUpdates
                    visible: value.length > 0
                }

                // AUR updates
                Components.BarModule {
                    id: aurMod
                    interactive: true
                    active: Services.ShellData.updatesVisible
                    onClicked: {
                        let pos = aurMod.mapToItem(null, aurMod.width / 2, 0)
                        bar.toggleUpdatesMenu(pos.x)
                    }
                    iconSource: Quickshell.shellDir + "/artixlinux-svgrepo-com.svg"
                    value: Services.ShellData.aurUpdates
                    visible: value.length > 0
                }

                // Temperature
                Components.BarModule {
                    id: tempModule
                    interactive: true
                    active: Services.ShellData.tempVisible
                    onClicked: {
                        let pos = tempModule.mapToItem(null, tempModule.width / 2, 0)
                        bar.toggleTempMenu(pos.x)
                    }
                    icon: ""
                    value: Services.ShellData.temperature + "°C"
                    textColor: Services.ShellData.temperature >= 90
                        ? Services.Colors.primary : Services.Colors.mainText
                    bgColor: Services.ShellData.temperature >= 90
                        ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15)
                        : "transparent"
                    Layout.leftMargin: 4
                }

                // CPU
                Components.BarModule {
                    id: cpuModule
                    interactive: true
                    active: Services.ShellData.cpuVisible
                    onClicked: {
                        let pos = cpuModule.mapToItem(null, cpuModule.width / 2, 0)
                        bar.toggleCpuMenu(pos.x)
                    }
                    icon: ""
                    value: Services.ShellData.cpuUsage + "%"
                    Layout.leftMargin: 9
                }

                // GPU
                Components.BarModule {
                    id: gpuModule
                    interactive: true
                    active: Services.ShellData.gpuVisible
                    onClicked: {
                        let pos = gpuModule.mapToItem(null, gpuModule.width / 2, 0)
                        bar.toggleGpuMenu(pos.x)
                    }
                    icon: "󰢮"
                    value: Services.ShellData.gpuUsage + "%"
                    Layout.leftMargin: 9
                }

                // Memory
                Components.BarModule {
                    id: ramModule
                    interactive: true
                    active: Services.ShellData.ramVisible
                    onClicked: {
                        let pos = ramModule.mapToItem(null, ramModule.width / 2, 0)
                        bar.toggleRamMenu(pos.x)
                    }
                    icon: ""
                    value: Services.ShellData.ramUsage
                    Layout.leftMargin: 9
                }

                // Network
                Components.BarModule {
                    id: wifiModule
                    interactive: true
                    active: Services.ShellData.trafficVisible
                    onClicked: {
                        let pos = wifiModule.mapToItem(null, wifiModule.width / 2, 0)
                        bar.toggleWifiMenu(pos.x)
                    }
                    icon: Services.NetworkService.netSsid === "Offline" ? "󰖪" : "󰤨"
                    value: Services.NetworkService.netSsid !== "Offline" ? Services.NetworkService.netSsid : ""
                    textColor: Services.NetworkService.netSsid === "Offline"
                        ? Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.35)
                        : Services.Colors.mainText
                    Layout.leftMargin: 9
                }

                // Volume
                Components.BarModule {
                    id: volModule
                    interactive: true
                    active: Services.ShellData.volumeVisible
                    onClicked: {
                        let pos = volModule.mapToItem(null, volModule.width / 2, 0)
                        bar.toggleVolumeMenu(pos.x)
                    }
                    icon: {
                        if (Services.AudioService.muted) return "󰝟"
                        let v = Services.AudioService.volume
                        if (v === 0) return "󰕿"
                        if (v < 34) return "󰕿"
                        if (v < 67) return "󰖀"
                        return "󰕾"
                    }
                    Layout.leftMargin: 9
                }

                // Clock (native SystemClock)
                Rectangle {
                    id: clockRect
                    implicitWidth: clockText.implicitWidth + 32
                    implicitHeight: 26
                    radius: Services.Colors.radiusSmall
                    property bool isHighlighted: clockMouse.pressed || Services.ShellData.calVisible
                    scale: isHighlighted ? 0.95 : 1.0
                    color: {
                        if (isHighlighted) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2)
                        if (clockMouse.containsMouse) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.1)
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
                            bar.toggleCalendar(pos.x)
                        }
                    }
                }

                // Notification Center button
                Components.BarButton {
                    id: notifButton
                    text: "󰅺"
                    fontSize: Services.Colors.fontSizeLarge
                    textColor: Services.Colors.primary
                    bgColor: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15)
                    active: Services.ShellData.ncVisible
                    onClicked: {
                        bar.toggleNotificationCenter()
                    }
                }
            }
        }
    }
}
