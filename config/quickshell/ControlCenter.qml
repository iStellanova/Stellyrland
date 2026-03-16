import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "services" as Services
import "components" as Components

PanelWindow {
    id: ccWindow

    // Visibility is controlled by shell.qml
    signal closeRequested()

    property bool hasMouseEntered: false
    property bool wallpaperSelectorVisible: false
    property bool powerMenuVisible: false
    onVisibleChanged: if (!visible) {
        hasMouseEntered = false
        wallpaperSelectorVisible = false
        powerMenuVisible = false
    }

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: ccWindow.visible && hasMouseEntered && !ccHover.hovered
        repeat: true
        onTriggered: ccWindow.closeRequested()
    }

    HoverHandler {
        id: ccHover
        onHoveredChanged: if (hovered) hasMouseEntered = true
    }

    // Window geometry
    implicitWidth: 330
    implicitHeight: mainCol.implicitHeight + 16

    // Overlay — doesn't reserve space
    exclusiveZone: 0

    // Position: top-left with offset
    anchors {
        top: true
        left: true
    }

    margins {
        top: 8
        left: 12
    }

    color: "transparent"

    // ── Pipewire is accessed as a singleton: Pipewire.defaultAudioSink ──

    // ── Root container ───────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true


        Flickable {
            anchors.fill: parent
            anchors.margins: 8
            contentHeight: mainCol.implicitHeight
            clip: true

            ColumnLayout {
                id: mainCol
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                // ── Clock + Weather Card ─────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: clockCol.implicitHeight + 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    SystemClock {
                        id: ccClock
                        precision: SystemClock.Minutes
                    }

                    ColumnLayout {
                        id: clockCol
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top
                            margins: 14; rightMargin: 16
                        }
                        spacing: 3

                        RowLayout {
                            spacing: 3
                            Layout.fillWidth: true

                            Components.ShadowText {
                                text: Qt.formatDateTime(ccClock.date, "hh:mm AP")
                                font.pixelSize: 38
                                font.weight: Font.Light
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.mainText
                            }

                            Item { Layout.fillWidth: true }
                        }

                        Components.ShadowText {
                            text: Qt.formatDateTime(ccClock.date, "ddd, dd MMM")
                            font.pixelSize: 11
                            font.family: Services.Colors.fontFamily
                            font.weight: Font.DemiBold
                            color: Services.Colors.dim
                        }
                    }
                }

                // ── Toggles Card ─────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: toggleRow.implicitHeight + 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    RowLayout {
                        id: toggleRow
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top
                            margins: 14
                        }
                        spacing: 6

                        Components.TogglePill {
                            label: "Wi-Fi"
                            icon: "󰤨"
                            active: Services.ShellData.wifiOn
                            onToggle: function() { Services.ShellData.toggleWifi() }
                            Layout.fillWidth: true
                        }

                        Components.TogglePill {
                            label: "VPN"
                            icon: "󰖂"
                            active: Services.ShellData.vpnOn
                            accent: Services.Colors.primary
                            onToggle: function() { Services.ShellData.toggleVpn() }
                            Layout.fillWidth: true
                        }

                        Components.TogglePill {
                            label: "BT"
                            icon: "󰂯"
                            active: Services.ShellData.btOn
                            onToggle: function() { Services.ShellData.toggleBt() }
                            Layout.fillWidth: true
                        }

                        Components.TogglePill {
                            label: "DND"
                            icon: "󰂛"
                            active: Services.ShellData.dndOn
                            accent: Services.Colors.red
                            onToggle: function() { Services.ShellData.toggleDnd() }
                            Layout.fillWidth: true
                        }

                        Components.TogglePill {
                            label: "Walls"
                            icon: "󰸉"
                            active: ccWindow.wallpaperSelectorVisible
                            onToggle: function() {
                                ccWindow.wallpaperSelectorVisible = !ccWindow.wallpaperSelectorVisible
                                if (ccWindow.powerMenuVisible) ccWindow.powerMenuVisible = false
                            }
                            Layout.fillWidth: true
                        }
                    }
                }

                // ── Wallpaper Selector (Animate Slide) ────────
                Components.WallpaperSelector {
                    id: wallSelector
                    Layout.fillWidth: true
                    Layout.preferredHeight: ccWindow.wallpaperSelectorVisible ? 200 : 0
                    opacity: ccWindow.wallpaperSelectorVisible ? 1 : 0
                    visible: opacity > 0
                    Layout.topMargin: ccWindow.wallpaperSelectorVisible ? -4 : -8
                    clip: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuart }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on Layout.topMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuart }
                    }
                }

                // ── Volume Slider Card ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: volSliderRow.implicitHeight + 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    Components.SliderRow {
                        id: volSliderRow
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top
                            margins: 14; rightMargin: 16
                        }
                        value: Services.ShellData.volume
                        muted: Services.ShellData.muted
                        onValueMoved: function(v) {
                            Services.ShellData.setVolume(v)
                        }
                        onIconClicked: function() {
                            Services.ShellData.toggleMute()
                        }
                    }
                }

                // ── Weather Card ─────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: weatherCol.implicitHeight + 24
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    HoverHandler {
                        id: cardHover
                    }

                    ColumnLayout {
                        id: weatherCol
                        anchors {
                            left: parent.left; right: parent.right
                            top: parent.top
                            margins: 14; bottomMargin: 2 // Reduced bottom margin
                        }
                        spacing: 8 // Reduced spacing

                        RowLayout {
                            spacing: 12
                            Layout.fillWidth: true

                            // Conditions Icon (Left)
                            Components.ShadowText {
                                text: Services.ShellData.weather.split(" ")[1] || "󰖐"
                                font.pixelSize: 34
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.primary
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Current Temp (Middle)
                            Components.ShadowText {
                                text: (Services.ShellData.weather.split(" ")[0] || "N/A").replace("°", "")
                                font.pixelSize: 42
                                font.weight: Font.Light
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.mainText
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // High/Low Column (Right)
                            ColumnLayout {
                                spacing: 0
                                Layout.alignment: Qt.AlignVCenter
                                
                                Components.ShadowText {
                                    text: " " + Services.ShellData.highTemp
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.primary
                                }
                                Components.ShadowText {
                                    text: " " + Services.ShellData.lowTemp
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.primary
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Refresh button
                            Rectangle {
                                implicitWidth: 32; implicitHeight: 32
                                radius: 8
                                color: weatherRefreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.1)
                                opacity: cardHover.hovered ? 1.0 : 0.0
                                
                                Behavior on opacity {
                                    NumberAnimation { duration: 200 }
                                }

                                Components.ShadowText {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    font.pixelSize: 14
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.dim
                                }

                                MouseArea {
                                    id: weatherRefreshMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Services.ShellData.refreshWeather()
                                }
                            }
                        }

                        // Hourly forecast (Scrollable)
                        Flickable {
                            id: weatherFlick
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            contentWidth: hourlyRow.implicitWidth
                            clip: true
                            flickableDirection: Flickable.HorizontalFlick
                            boundsBehavior: Flickable.StopAtBounds

                            ScrollBar.horizontal: ScrollBar {
                                id: weatherScrollBar
                                policy: ScrollBar.AlwaysOn
                                parent: weatherFlick.parent
                                anchors.bottom: weatherFlick.bottom
                                anchors.left: weatherFlick.left
                                anchors.right: weatherFlick.right
                                opacity: (weatherHover.hovered || weatherScrollBar.active) ? 1.0 : 0.0
                                
                                Behavior on opacity {
                                    NumberAnimation { duration: 150 }
                                }
                                
                                contentItem: Rectangle {
                                    implicitHeight: 3
                                    radius: 2
                                    color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.4)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onPressed: (mouse) => mouse.accepted = false
                                onWheel: (wheel) => {
                                    // Manually scroll horizontally with vertical wheel
                                    let newX = weatherFlick.contentX - wheel.angleDelta.y;
                                    weatherFlick.contentX = Math.max(0, Math.min(weatherFlick.contentWidth - weatherFlick.width, newX));
                                }
                            }

                            HoverHandler {
                                id: weatherHover
                            }

                            RowLayout {
                                id: hourlyRow
                                spacing: 18 // Increased spacing
                                Layout.topMargin: 4 // Space for comfort
                                
                                Repeater {
                                    model: Services.ShellData.hourlyWeather
                                    delegate: ColumnLayout {
                                        spacing: 4
                                        
                                        Components.ShadowText {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.time
                                            font.pixelSize: 9
                                            font.weight: Font.DemiBold
                                            font.family: Services.Colors.fontFamily
                                            color: Services.Colors.dim
                                        }
                                        
                                        Components.ShadowText {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.icon
                                            font.pixelSize: 18
                                            font.family: Services.Colors.fontFamily
                                            color: Services.Colors.mainText
                                        }
                                        
                                        Components.ShadowText {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.temp
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                            font.family: Services.Colors.fontFamily
                                            color: Services.Colors.mainText
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                // ── System Stats Card ────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: sysRow.implicitHeight + 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    RowLayout {
                        id: sysRow
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 0

                        Components.SysRing {
                            label: "CPU"
                            value: Services.ShellData.cpuUsage
                            accent: Services.Colors.primary
                            Layout.fillWidth: true
                        }

                        Components.SysRing {
                            label: "RAM"
                            value: Services.ShellData.ramPerc
                            accent: Services.Colors.primary
                            Layout.fillWidth: true
                        }

                        Components.SysRing {
                            label: "GPU"
                            value: Services.ShellData.gpuUsage
                            accent: Services.Colors.primary
                            Layout.fillWidth: true
                        }
                    }
                }

                // ── Footer Card ──────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: footerRow.implicitHeight + 18
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    RowLayout {
                        id: footerRow
                        anchors {
                            left: parent.left; right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 9; rightMargin: 16
                        }
                        spacing: 9

                        // Avatar
                        Rectangle {
                            id: avatarContainer
                            implicitWidth: 38; implicitHeight: 38
                            radius: 99
                            color: "transparent"
                            border.width: 1.5
                            border.color: Services.Colors.border

                            Item {
                                anchors.fill: parent
                                anchors.margins: 2
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: avatarContainer.width; height: avatarContainer.height
                                        radius: avatarContainer.radius
                                    }
                                }

                                Image {
                                    anchors.fill: parent
                                    source: "file:///home/stellanova/.config/quickshell/face.png"
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize: Qt.size(76, 76)
                                }
                            }
                        }

                        // Name + system info
                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true

                            Components.ShadowText {
                                text: Services.ShellData.username
                                font.pixelSize: 11
                                font.family: Services.Colors.fontFamily
                                font.weight: Font.DemiBold
                                color: Services.Colors.mainText
                            }

                            Components.ShadowText {
                                text: Services.ShellData.distroName + " • up " + Services.ShellData.uptime
                                font.pixelSize: 9
                                font.family: Services.Colors.fontFamily
                                font.weight: Font.DemiBold
                                color: Services.Colors.dim
                            }
                        }

                        // Settings button
                        Rectangle {
                            implicitWidth: 28; implicitHeight: 28
                            radius: 8
                            color: settingsMouse.containsMouse ? Services.Colors.border : "transparent"
                            border.width: 1
                            border.color: Services.Colors.border

                            Components.ShadowText {
                                anchors.centerIn: parent
                                text: "󰒓"
                                font.pixelSize: 15
                                font.family: Services.Colors.fontFamily
                                font.weight: Font.DemiBold
                                color: settingsMouse.containsMouse ? Services.Colors.mainText : Services.Colors.dim
                            }

                            MouseArea {
                                id: settingsMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    settingsProc.running = true
                                    ccWindow.closeRequested()
                                }
                            }
                        }

                        // Power button
                        Rectangle {
                            implicitWidth: 28; implicitHeight: 28
                            radius: 8
                            color: powerMouse.containsMouse ? Qt.rgba(Services.Colors.red.r, Services.Colors.red.g, Services.Colors.red.b, 0.12) : "transparent"
                            border.width: 1
                            border.color: powerMouse.containsMouse ? Qt.rgba(Services.Colors.red.r, Services.Colors.red.g, Services.Colors.red.b, 0.35) : Services.Colors.border

                            Components.ShadowText {
                                anchors.centerIn: parent
                                text: "󰐥"
                                font.pixelSize: 15
                                font.family: Services.Colors.fontFamily
                                font.weight: Font.DemiBold
                                color: Services.Colors.red
                            }

                            MouseArea {
                                id: powerMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    ccWindow.powerMenuVisible = !ccWindow.powerMenuVisible
                                    if (ccWindow.wallpaperSelectorVisible) ccWindow.wallpaperSelectorVisible = false
                                }
                            }
                        }
                    }
                }

                // ── Power Menu (Animate Slide) ──────────────
                Components.PowerMenu {
                    id: powerMenu
                    window: ccWindow
                    Layout.fillWidth: true
                    Layout.preferredHeight: ccWindow.powerMenuVisible ? 80 : 0
                    opacity: ccWindow.powerMenuVisible ? 1 : 0
                    visible: opacity > 0
                    Layout.topMargin: ccWindow.powerMenuVisible ? -4 : -8
                    clip: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuart }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on Layout.topMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuart }
                    }
                }
            }
        }
    }

    Process {
        id: settingsProc
        command: ["bash", "-c", "zeditor /home/stellanova/dotfiles/source.py &"]
        running: false
    }
}
