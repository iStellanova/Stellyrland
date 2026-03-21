import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

FloatingWindow {
    id: root

    property bool active: false
    property string activeTab: "wallpaper"
    signal closeRequested()

    implicitWidth: 700
    implicitHeight: 550
    
    color: "transparent"
    
    // Internal state for editing
    property var editingSettings: ({})
    
    onVisibleChanged: {
        if (visible) {
            // Clone settings to avoid direct mutation before save
            editingSettings = JSON.parse(JSON.stringify(Services.ConfigService.settings))
        }
    }

    function refreshSettings() {
        // Force QML to re-evaluate bindings to the plain JS object
        let tmp = editingSettings
        editingSettings = ({})
        editingSettings = tmp
    }

    // ── Internal Styled Components ───────────────────
    component StyledTextField : TextField {
        id: stf
        background: Rectangle {
            implicitHeight: 32
            radius: Services.Colors.radiusSmall
            color: Qt.rgba(1, 1, 1, 0.05)
            border.width: stf.activeFocus ? 1 : 0
            border.color: Services.Colors.primary
        }
        color: Services.Colors.mainText
        font.pixelSize: 12
        leftPadding: 10; rightPadding: 10
        placeholderTextColor: Services.Colors.dim
        selectionColor: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.3)
    }

    component StyledSpinBox : SpinBox {
        id: ssb
        editable: true
        background: Rectangle {
            implicitHeight: 32
            radius: Services.Colors.radiusSmall
            color: Qt.rgba(1, 1, 1, 0.05)
            border.width: ssb.activeFocus ? 1 : 1
            border.color: ssb.activeFocus ? Services.Colors.primary : Services.Colors.border
        }
        contentItem: TextInput {
            z: 2; x: 32; width: ssb.width - 64; height: ssb.height
            text: ssb.textFromValue(ssb.value, ssb.locale)
            font.pixelSize: 12; color: Services.Colors.mainText
            horizontalAlignment: Qt.AlignHCenter; verticalAlignment: Qt.AlignVCenter
            readOnly: !ssb.editable; validator: ssb.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onAccepted: ssb.value = ssb.valueFromText(text, ssb.locale)
        }
        
        // Manual button visuals since standard ones are failing to capture events
        Rectangle {
            id: downBtnVis
            anchors.left: parent.left; width: 32; height: parent.height; z: 10
            radius: Services.Colors.radiusSmall; color: ssbMouse.isDownPressed ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
            Components.ShadowText { anchors.centerIn: parent; text: "-"; font.pixelSize: 14; font.bold: true; color: ssbMouse.isDownPressed ? Services.Colors.primary : Services.Colors.dim }
        }
        Rectangle {
            id: upBtnVis
            anchors.right: parent.right; width: 32; height: parent.height; z: 10
            radius: Services.Colors.radiusSmall; color: ssbMouse.isUpPressed ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
            Components.ShadowText { anchors.centerIn: parent; text: "+"; font.pixelSize: 14; font.bold: true; color: ssbMouse.isUpPressed ? Services.Colors.primary : Services.Colors.dim }
        }
        
        MouseArea {
            id: ssbMouse
            anchors.fill: parent; z: 20
            property bool isDownPressed: false
            property bool isUpPressed: false
            onPressed: (mouse) => {
                if (mouse.x < 32) { isDownPressed = true; ssb.decrease(); mouse.accepted = true }
                else if (mouse.x > width - 32) { isUpPressed = true; ssb.increase(); mouse.accepted = true }
                else { mouse.accepted = false }
            }
            onReleased: { isDownPressed = false; isUpPressed = false }
            onCanceled: { isDownPressed = false; isUpPressed = false }
        }
        
        // Satisfy the template with empty items
        up.indicator: Item {}
        down.indicator: Item {}
    }

    component StyledComboBox : ComboBox {
        id: scb
        delegate: ItemDelegate {
            width: scb.width
            contentItem: Components.ShadowText { text: modelData; font.pixelSize: 12; color: highlighted ? Services.Colors.primary : Services.Colors.mainText; verticalAlignment: Text.AlignVCenter }
            background: Rectangle { color: highlighted ? Qt.rgba(1, 1, 1, 0.05) : "transparent" }
        }
        indicator: Components.ShadowText { x: scb.width - width - 10; y: scb.topPadding + (scb.availableHeight - height) / 2; text: "󰅀"; font.pixelSize: 10; color: Services.Colors.dim }
        contentItem: Components.ShadowText { leftPadding: 12; text: scb.displayText; font.pixelSize: 12; color: Services.Colors.mainText; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { implicitHeight: 32; radius: Services.Colors.radiusSmall; color: Qt.rgba(1, 1, 1, 0.05); border.width: scb.activeFocus ? 1 : 0; border.color: Services.Colors.primary }
        popup: Popup {
            y: scb.height + 4; width: scb.width; implicitHeight: contentItem.implicitHeight; padding: 1
            contentItem: ListView { 
                clip: true; implicitHeight: contentHeight; model: scb.popup.visible ? scb.delegateModel : null
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
            background: Rectangle { radius: Services.Colors.radiusSmall; color: Services.Colors.bg; border.color: Services.Colors.border; border.width: 1 }
        }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ───────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: Qt.rgba(1, 1, 1, 0.03)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: Services.Colors.spacingLarge

                    Components.ShadowText {
                        text: "󰒓"
                        font.pixelSize: 22
                        color: Services.Colors.primary
                    }

                    Components.ShadowText {
                        text: "Settings"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: Services.Colors.mainText
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Services.Colors.border
                }
            }

            // ── Main Content Area ────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Sidebar
                Rectangle {
                    Layout.fillHeight: true
                    width: 180
                    color: Qt.rgba(0, 0, 0, 0.1)
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4


                        Repeater {
                            model: [
                                { id: "wallpaper", label: "Wallpaper", icon: "󰸉" },
                                { id: "network", label: "Network", icon: "󰤨" },
                                { id: "notifications", label: "Notifications", icon: "󰂚" },
                                { id: "weather", label: "Weather", icon: "󰖐" },
                                { id: "polling", label: "Polling", icon: "󰑐" },
                                { id: "animation", label: "Animations", icon: "󰖨" },
                                { id: "colors", label: "Theme", icon: "󰏘" },
                                { id: "system", label: "System", icon: "󰒓" }
                            ]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                radius: Services.Colors.radiusSmall
                                color: parent.activeTab === modelData.id ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15) : (sidebarMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    spacing: 12

                                    Components.ShadowText {
                                        text: modelData.icon
                                        font.pixelSize: 16
                                        color: root.activeTab === modelData.id ? Services.Colors.primary : Services.Colors.dim
                                    }

                                    Components.ShadowText {
                                        text: modelData.label
                                        font.pixelSize: 13
                                        font.weight: root.activeTab === modelData.id ? Font.Bold : Font.Medium
                                        color: root.activeTab === modelData.id ? Services.Colors.mainText : Services.Colors.dim
                                    }
                                }

                                MouseArea {
                                    id: sidebarMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activeTab = modelData.id
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        height: parent.height
                        width: 1
                        color: Services.Colors.border
                    }
                }

                // Settings View (Flickable)
                StackLayout {
                    id: settingsStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 24
                    Layout.topMargin: 20
                    currentIndex: {
                        let tabs = ["wallpaper", "network", "notifications", "weather", "polling", "animation", "colors", "system"]
                        return Math.max(0, tabs.indexOf(root.activeTab))
                    }

                    // Content is added below
                    
                    // --- Wallpaper Section ---
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: settingsStack.width - 40
                            anchors.margins: 20
                            spacing: 16

                            Components.ShadowText { text: "Wallpaper Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            
                            Components.ShadowText { text: "Startup Mode"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledComboBox {
                                Layout.fillWidth: true
                                model: ["random", "first"]
                                currentIndex: editingSettings.wallpaper ? (editingSettings.wallpaper.startup_mode === "random" ? 0 : 1) : 0
                                onActivated: index => { editingSettings.wallpaper.startup_mode = (index === 0 ? "random" : "first"); root.refreshSettings() }
                            }

                            Components.ShadowText { text: "Rotation Interval (minutes)"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledSpinBox {
                                Layout.fillWidth: true
                                from: 0; to: 1440
                                value: editingSettings.wallpaper ? editingSettings.wallpaper.rotation_interval_minutes : 30
                                onValueModified: { editingSettings.wallpaper.rotation_interval_minutes = value; root.refreshSettings() }
                            }

                            Components.ShadowText { text: "Wallpaper Directory"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.wallpaper ? editingSettings.wallpaper.directory : ""
                                onTextEdited: { editingSettings.wallpaper.directory = text; root.refreshSettings() }
                            }
                        }
                    }

                    // --- Network Section ---
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: settingsStack.width - 40
                            anchors.margins: 20
                            spacing: 16
                            Components.ShadowText { text: "Network Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            
                            Components.ShadowText { text: "Monitoring Interface (empty for auto)"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.network ? editingSettings.network.interface : ""
                                onTextEdited: { editingSettings.network.interface = text; root.refreshSettings() }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: Services.Colors.border; Layout.topMargin: 8; Layout.bottomMargin: 8 }

                            Components.ShadowText { text: "VPN Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            
                            Components.ShadowText { text: "VPN Interface"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.vpn ? editingSettings.vpn.interface : "proton0"
                                onTextEdited: { if (!editingSettings.vpn) editingSettings.vpn = {}; editingSettings.vpn.interface = text; root.refreshSettings() }
                            }

                            Components.ShadowText { text: "VPN Connect Command"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.vpn ? editingSettings.vpn.connect_command : "protonvpn connect"
                                onTextEdited: { if (!editingSettings.vpn) editingSettings.vpn = {}; editingSettings.vpn.connect_command = text; root.refreshSettings() }
                            }

                            Components.ShadowText { text: "VPN Disconnect Command"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.vpn ? editingSettings.vpn.disconnect_command : "protonvpn disconnect"
                                onTextEdited: { if (!editingSettings.vpn) editingSettings.vpn = {}; editingSettings.vpn.disconnect_command = text; root.refreshSettings() }
                            }
                        }
                    }

                    // --- Notifications Section ---
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: settingsStack.width - 40
                            anchors.margins: 20
                            spacing: 16
                            Components.ShadowText { text: "Notification Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            Components.ShadowText { text: "Max History"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledSpinBox { 
                                Layout.fillWidth: true; from: 5; to: 100
                                value: editingSettings.notifications ? editingSettings.notifications.max_history : 20
                                onValueModified: { editingSettings.notifications.max_history = value; root.refreshSettings() } 
                            }
                            Components.ShadowText { text: "Max Toasts"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledSpinBox { 
                                Layout.fillWidth: true; from: 1; to: 10
                                value: editingSettings.notifications ? editingSettings.notifications.toast_limit : 5
                                onValueModified: { editingSettings.notifications.toast_limit = value; root.refreshSettings() } 
                            }
                            CheckBox {
                                text: "Show Notification Timer"
                                checked: (editingSettings.notifications && editingSettings.notifications.show_timer) !== false
                                onToggled: { if (editingSettings.notifications) { editingSettings.notifications.show_timer = checked; root.refreshSettings() } }
                                contentItem: Components.ShadowText {
                                    text: parent.text
                                    font.pixelSize: 12
                                    color: Services.Colors.mainText
                                    leftPadding: parent.indicator.width + parent.spacing
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    // --- Weather Section ---
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: settingsStack.width - 40
                            anchors.margins: 20
                            spacing: 16
                            Components.ShadowText { text: "Weather Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            RowLayout {
                                spacing: 10
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Components.ShadowText { text: "Latitude (0 for Auto)"; font.pixelSize: 11; color: Services.Colors.dim }
                                    StyledTextField {
                                        Layout.fillWidth: true
                                        text: editingSettings.weather ? editingSettings.weather.latitude : ""
                                        onTextEdited: { editingSettings.weather.latitude = parseFloat(text) || 0; root.refreshSettings() }
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Components.ShadowText { text: "Longitude (0 for Auto)"; font.pixelSize: 11; color: Services.Colors.dim }
                                    StyledTextField {
                                        Layout.fillWidth: true
                                        text: editingSettings.weather ? editingSettings.weather.longitude : ""
                                        onTextEdited: { editingSettings.weather.longitude = parseFloat(text) || 0; root.refreshSettings() }
                                    }
                                }
                            }
                            Components.ShadowText { text: "Polling Interval (minutes)"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledSpinBox {
                                Layout.fillWidth: true
                                from: 1; to: 60
                                value: editingSettings.weather ? Math.round(editingSettings.weather.polling_interval_ms / 60000) : 15
                                onValueModified: { editingSettings.weather.polling_interval_ms = value * 60000; root.refreshSettings() }
                            }
                        }
                    }

                        // --- Polling Section ---
                        ScrollView {
                            clip: true
                            ColumnLayout {
                                width: settingsStack.width - 40
                                anchors.margins: 20
                                spacing: 16
                                Components.ShadowText { text: "Background Services Polling"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                                Components.ShadowText { text: "Updates Polling (minutes)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 1; to: 240
                                    value: editingSettings.polling ? Math.round(editingSettings.polling.updates_interval_ms / 60000) : 60
                                    onValueModified: { editingSettings.polling.updates_interval_ms = value * 60000; root.refreshSettings() }
                                }
                                Components.ShadowText { text: "Uptime Polling (seconds)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 1; to: 300
                                    value: editingSettings.polling ? Math.round(editingSettings.polling.uptime_interval_ms / 1000) : 60
                                    onValueModified: { editingSettings.polling.uptime_interval_ms = value * 1000; root.refreshSettings() }
                                }
                                Components.ShadowText { text: "Idle Check (seconds)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 1; to: 60
                                    value: editingSettings.polling ? Math.round(editingSettings.polling.idle_check_interval_ms / 1000) : 2
                                    onValueModified: { editingSettings.polling.idle_check_interval_ms = value * 1000; root.refreshSettings() }
                                }
                                Components.ShadowText { text: "Stats Polling (seconds)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 1; to: 60
                                    value: editingSettings.polling ? (editingSettings.polling.stats_interval_s || 5) : 5
                                    onValueModified: { editingSettings.polling.stats_interval_s = value; root.refreshSettings() }
                                }
                            }
                        }

                        // --- Animation Section ---
                        ScrollView {
                            clip: true
                            ColumnLayout {
                                width: settingsStack.width - 40
                                anchors.margins: 20
                                spacing: 16
                                Components.ShadowText { text: "Animation Timings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                                Components.ShadowText { text: "Fast (ms)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 0; to: 1000
                                    value: editingSettings.animation ? editingSettings.animation.fast : 100
                                    onValueModified: { editingSettings.animation.fast = value; root.refreshSettings() }
                                }
                                Components.ShadowText { text: "Normal (ms)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 0; to: 1000
                                    value: editingSettings.animation ? editingSettings.animation.normal : 150
                                    onValueModified: { editingSettings.animation.normal = value; root.refreshSettings() }
                                }
                                Components.ShadowText { text: "Slow (ms)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 0; to: 1000
                                    value: editingSettings.animation ? editingSettings.animation.slow : 250
                                    onValueModified: { editingSettings.animation.slow = value; root.refreshSettings() }
                                }
                                Components.ShadowText { text: "Extra Slow (ms)"; font.pixelSize: 12; color: Services.Colors.mainText }
                                StyledSpinBox {
                                    Layout.fillWidth: true; from: 0; to: 2000
                                    value: editingSettings.animation ? editingSettings.animation.extra_slow : 500
                                    onValueModified: { editingSettings.animation.extra_slow = value; root.refreshSettings() }
                                }
                            }
                        }

                    // --- Colors Section ---
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: settingsStack.width - 40
                            anchors.margins: 20
                            spacing: 16
                            Components.ShadowText { text: "Theme Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            CheckBox {
                                id: useHardcodedCheck
                                text: "Use Hardcoded Colors (Bypass Matugen/Pywal)"
                                checked: (editingSettings.colors && editingSettings.colors.use_hardcoded) || false
                                onToggled: { if (editingSettings.colors) { editingSettings.colors.use_hardcoded = checked; root.refreshSettings() } }
                                contentItem: Components.ShadowText {
                                    text: parent.text
                                    font.pixelSize: 12
                                    color: Services.Colors.mainText
                                    leftPadding: parent.indicator.width + parent.spacing
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Components.ShadowText { text: "Hardcoded Colors"; font.pixelSize: 11; color: Services.Colors.dim }
                            
                            Flow {
                                Layout.fillWidth: true
                                spacing: 10
                                enabled: useHardcodedCheck.checked
                                opacity: enabled ? 1.0 : 0.5

                                property var colorKeys: [
                                    "primary", "primaryContainer", "secondary", "background",
                                    "surface", "onSurface", "onBackground", "onPrimary",
                                    "tertiaryContainer", "error"
                                ]

                                Repeater {
                                    model: parent.colorKeys
                                    delegate: ColumnLayout {
                                        width: (parent.width - 20) / 3
                                        spacing: 4
                                        Components.ShadowText { text: modelData; font.pixelSize: 10; color: Services.Colors.dim }
                                        RowLayout {
                                            Rectangle {
                                                width: 24; height: 24
                                                radius: 4
                                                color: (editingSettings.colors && editingSettings.colors.hardcoded) ? (editingSettings.colors.hardcoded[modelData] || "#000000") : "#000000"
                                                border.width: 1
                                                border.color: Services.Colors.border
                                            }
                                            StyledTextField {
                                                Layout.fillWidth: true
                                                font.pixelSize: 10
                                                text: (editingSettings.colors && editingSettings.colors.hardcoded) ? (editingSettings.colors.hardcoded[modelData] || "") : ""
                                                onTextEdited: { if (editingSettings.colors.hardcoded) { editingSettings.colors.hardcoded[modelData] = text; root.refreshSettings() } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // --- System Section ---
                    ScrollView {
                        clip: true
                        ColumnLayout {
                            width: settingsStack.width - 40
                            anchors.margins: 20
                            spacing: 16
                            Components.ShadowText { text: "System & Shell Settings"; font.pixelSize: 14; font.bold: true; color: Services.Colors.primary }
                            
                            Components.ShadowText { text: "Lock Command"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.shell ? editingSettings.shell.lock_command : "hyprlock"
                                onTextEdited: { if (!editingSettings.shell) editingSettings.shell = {}; editingSettings.shell.lock_command = text; root.refreshSettings() }
                            }

                            Components.ShadowText { text: "Profile Image Path (Avatar)"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.shell ? editingSettings.shell.avatar_path : "face.png"
                                onTextEdited: { if (!editingSettings.shell) editingSettings.shell = {}; editingSettings.shell.avatar_path = text; root.refreshSettings() }
                            }

                            Components.ShadowText { text: "UI Font Family"; font.pixelSize: 12; color: Services.Colors.mainText }
                            StyledTextField {
                                Layout.fillWidth: true
                                text: editingSettings.shell ? editingSettings.shell.font_family : "JetBrains Mono Nerd Font Propo"
                                onTextEdited: { if (!editingSettings.shell) editingSettings.shell = {}; editingSettings.shell.font_family = text; root.refreshSettings() }
                            }
                        }
                    }
                }
            }

            // ── Footer (Action Buttons) ──────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 70
                color: Qt.rgba(1, 1, 1, 0.03)

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: Services.Colors.border
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Item { Layout.fillWidth: true }

                    // Custom Cancel Button
                    Rectangle {
                        implicitWidth: 100; implicitHeight: 36
                        radius: Services.Colors.radiusSmall
                        color: cancelMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: Services.Colors.border
                        
                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: Services.Colors.mainText
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.closeRequested()
                        }
                    }

                    // Custom Save Button
                    Rectangle {
                        implicitWidth: 140; implicitHeight: 36
                        radius: Services.Colors.radiusSmall
                        color: saveBtnMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25) : Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.15)
                        border.width: 1
                        border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35)
                        
                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: "Apply & Save"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: Services.Colors.primary
                        }

                        MouseArea {
                            id: saveBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Services.ConfigService.save(editingSettings)
                                root.closeRequested()
                            }
                        }
                    }
                }
            }
        }
    }
}
