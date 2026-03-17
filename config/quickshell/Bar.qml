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
    visible: !Services.ShellData.hasFullscreen
    property var trayMenu
    property var activeWorkspaceButton: null

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 12
        left: 12
        right: 12
    }

    implicitHeight: 42
    exclusiveZone: 42  // adjusted to account for Hyprland gaps (54 - 12)
    color: "transparent"

    // ── Signals for popup toggling ───────────────────────────
    signal toggleControlCenter(real xPos)
    signal toggleNotificationCenter(real xPos)
    signal toggleCalendar(real xPos)
    signal toggleWifiMenu(real xPos)
    signal toggleRamMenu(real xPos)
    signal toggleCpuMenu(real xPos)
    signal toggleTempMenu(real xPos)
    signal toggleMediaMenu(real xPos)

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
            radius: 14
            clip: true

            Behavior on width {
                NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
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
                radius: 8
                color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12)
                border.width: 1
                border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.05)

                property var targetButton: bar.activeWorkspaceButton
                
                // Fade in/out when we have a target (e.g. focus moves to/from this monitor)
                opacity: targetButton && targetButton.visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                
                // Direct relative positioning
                // Direct relative positioning
                x: targetButton ? leftRow.x + targetButton.x : 0
                width: targetButton ? targetButton.width : 0

                Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            }

            RowLayout {
                id: leftRow
                z: 2
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // Control Center button
                Components.BarButton {
                    id: archButton
                    text: "󰣇"
                    fontSize: Services.Colors.fontSizeLarge
                    textColor: Services.Colors.primary
                    bgColor: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15)
                    onClicked: {
                        let pos = archButton.mapToItem(null, archButton.width / 2, 0)
                        bar.toggleControlCenter(pos.x)
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
                    }
                }

                // Cava
                Components.CavaVisualizer {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 20
                    color: "white"
                    barOpacity: 1.0
                    visible: Services.ShellData.cavaData.length > 0
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                }

                Item {
                    id: titleContainer
                    Layout.maximumWidth: 350
                    property real targetWidth: titleText.text.length > 0 ? Math.min(titleText.implicitWidth, 350) : 0
                    Layout.preferredWidth: targetWidth
                    implicitHeight: titleText.implicitHeight
                    clip: true
                    Layout.leftMargin: targetWidth > 0 ? 5 : 0
                    visible: targetWidth > 0 || width > 0

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
            width: mprisRow.implicitWidth + 30
            radius: 18
            clip: true
            Behavior on width {
                NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
            }
            color: mprisMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.1) : Services.Colors.bg
            border.width: 1
            border.color: mprisMouse.containsMouse ? Services.Colors.primary : Services.Colors.border
            
            scale: mprisMouse.pressed ? 0.95 : 1.0
            Behavior on color { ColorAnimation { duration: 80 } }
            Behavior on border.color { ColorAnimation { duration: 80 } }
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
            
            visible: {
                let p = Services.Music.player
                return p !== null && p.playbackState !== MprisPlaybackState.Stopped
            }

            RowLayout {
                id: mprisRow
                anchors.centerIn: parent
                spacing: 8

                Components.ShadowText {
                    text: {
                        let p = Services.Music.player
                        if (!p) return ""
                        return p.playbackState === MprisPlaybackState.Playing ? "▶" : "⏸"
                    }
                    font.pixelSize: Services.Colors.fontSizeSmall
                    color: mprisMouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
                }

                Components.ShadowText {
                    text: {
                        let p = Services.Music.player
                        if (!p) return ""
                        let t = p.trackTitle || "Unknown Track"
                        let a = p.trackArtist || "Unknown Artist"
                        let display = a.length > 0 ? (t + " - " + a) : t
                        return display.length > 20 ? display.substring(0, 20) + "…" : display
                    }
                    color: mprisMouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
                }
            }

            MouseArea {
                id: mprisMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    let pos = mprisBubble.mapToItem(null, mprisBubble.width / 2, 0)
                    bar.toggleMediaMenu(pos.x)
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
            radius: 14
            clip: true
            Behavior on width {
                NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
            }
            color: Services.Colors.bg
            border.width: 1
            border.color: Services.Colors.border

            RowLayout {
                id: rightRow
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                // System Tray
                RowLayout {
                    spacing: 4
                    Layout.rightMargin: 8
                    Repeater {
                        model: SystemTray.items
                        delegate: Rectangle {
                            id: trayItem
                            implicitWidth: 26; implicitHeight: 26
                            radius: 6
                            color: trayMouse.containsMouse ? Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.1) : "transparent"

                            Image {
                                anchors.centerIn: parent
                                source: modelData.icon
                                width: 18; height: 18
                                sourceSize: Qt.size(36, 36)
                                asynchronous: true
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
                                            trayMenu.screen = bar.screen;
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

                // Pacman updates
                Components.BarModule {
                    icon: "󰮯"
                    value: Services.ShellData.pacmanUpdates
                    visible: value.length > 0
                }

                // AUR updates
                Components.BarModule {
                    icon: "󰣇"
                    value: Services.ShellData.aurUpdates
                    visible: value.length > 0
                }

                // Temperature
                Components.BarModule {
                    id: tempModule
                    interactive: true
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
                    onClicked: {
                        let pos = cpuModule.mapToItem(null, cpuModule.width / 2, 0)
                        bar.toggleCpuMenu(pos.x)
                    }
                    icon: ""
                    value: Services.ShellData.cpuUsage + "%"
                    Layout.leftMargin: 9
                }

                // Memory
                Components.BarModule {
                    id: ramModule
                    interactive: true
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
                    onClicked: {
                        let pos = wifiModule.mapToItem(null, wifiModule.width / 2, 0)
                        bar.toggleWifiMenu(pos.x)
                    }
                    icon: Services.ShellData.netSsid === "Offline" ? "󰖪" : "󰤨"
                    value: Services.ShellData.netSsid !== "Offline" ? Services.ShellData.netSsid : ""
                    textColor: Services.ShellData.netSsid === "Offline"
                        ? Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.35)
                        : Services.Colors.mainText
                    Layout.leftMargin: 9
                }

                // Clock (native SystemClock)
                Rectangle {
                    id: clockRect
                    implicitWidth: clockText.implicitWidth + 32
                    implicitHeight: 26
                    radius: 8
                    scale: clockMouse.pressed ? 0.95 : 1.0
                    color: {
                        if (clockMouse.pressed) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2)
                        if (clockMouse.containsMouse) return Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.1)
                        return "transparent"
                    }

                    Behavior on color { ColorAnimation { duration: 80 } }
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                    SystemClock {
                        id: sysClock
                        precision: SystemClock.Minutes
                    }

                    Components.ShadowText {
                        id: clockText
                        anchors.centerIn: parent
                        text: Qt.formatDateTime(sysClock.date, "ddd dd MMM   hh:mm AP")
                        color: clockMouse.containsMouse ? Services.Colors.primary : Services.Colors.mainText
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
                    onClicked: {
                        let pos = notifButton.mapToItem(null, notifButton.width / 2, 0)
                        bar.toggleNotificationCenter(pos.x)
                    }
                }
            }
        }
    }
}
