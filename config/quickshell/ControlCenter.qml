import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "services" as Services
import "components" as Components

PanelWindow {
    id: ccWindow
    WlrLayershell.layer: WlrLayer.Top

    // Visibility is controlled by shell.qml
    signal closeRequested()

    property bool hasMouseEntered: false
    property bool powerMenuVisible: false
    property bool showingInfo: false
    property bool showingWifi: false
    property bool showingBt: false
    onVisibleChanged: if (!visible) {
        hasMouseEntered = false
        powerMenuVisible = false
        showingInfo = false
        showingWifi = false
        showingBt = false
    }

    onShowingInfoChanged: if (showingInfo) { powerMenuVisible = false; showingWifi = false; showingBt = false; }
    onPowerMenuVisibleChanged: if (powerMenuVisible) { showingInfo = false; showingWifi = false; showingBt = false; }
    onShowingWifiChanged: if (showingWifi) { powerMenuVisible = false; showingInfo = false; showingBt = false; Services.ShellData.refreshWifi(); }
    onShowingBtChanged: if (showingBt) { powerMenuVisible = false; showingInfo = false; showingWifi = false; Services.ShellData.refreshBt(); }

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
    Behavior on implicitHeight {
        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutQuart }
    }

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
        radius: Services.Colors.radiusLarge
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
                spacing: Services.Colors.spacingLarge

                Item {
                    id: ccContentStack
                    Layout.fillWidth: true
                    Layout.preferredHeight: ccWindow.showingInfo ? (infoContent.implicitHeight + (Services.Colors.spacingXLarge * 2)) : ccMainContent.implicitHeight
                    clip: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutQuart }
                    }

                    ColumnLayout {
                        id: ccMainContent
                        anchors.fill: parent
                        spacing: Services.Colors.spacingLarge
                        opacity: ccWindow.showingInfo ? 0 : 1
                        visible: opacity > 0

                        Behavior on opacity { NumberAnimation { duration: Services.Colors.animFast } }

                        // ── Header (Clock + Date) ─────────────────────
                        ColumnLayout {
                            id: clockCol
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8
                            spacing: Services.Colors.spacingSmall

                            SystemClock {
                                id: ccClock
                                precision: SystemClock.Minutes
                            }

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignLeft
                                text: Qt.formatDateTime(ccClock.date, "hh:mm AP")
                                font.pixelSize: 32
                                font.weight: Font.DemiBold
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.primary
                            }

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignLeft
                                text: Qt.formatDateTime(ccClock.date, "dddd, MMMM d")
                                font.pixelSize: 11
                                font.family: Services.Colors.fontFamily
                                font.weight: Font.Medium
                                color: Services.Colors.dim
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Services.Colors.border
                            Layout.topMargin: 4
                        }

                        // ── Toggles ─────────────────────────────
                        GridLayout {
                            id: toggleRow
                            columns: 3
                            rows: 2
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            columnSpacing: Services.Colors.spacingNormal
                            rowSpacing: Services.Colors.spacingNormal

                            // Top row: DND, Mic, Idle Disabler
                            Components.TogglePill {
                                label: "DND"
                                icon: "󰂛"
                                active: Services.ShellData.dndOn
                                accent: Services.Colors.red
                                onToggle: function() { Services.ShellData.toggleDnd() }
                                Layout.fillWidth: true
                            }

                            Components.TogglePill {
                                label: "Mic"
                                icon: Services.ShellData.micMuted ? "󰍭" : "󰍬"
                                active: Services.ShellData.micMuted
                                accent: Services.Colors.red
                                onToggle: function() { Services.ShellData.toggleMic() }
                                Layout.fillWidth: true
                            }

                            Components.TogglePill {
                                label: "Idle"
                                icon: Services.ShellData.idleOn ? "󰒲" : "󰒳"
                                active: !Services.ShellData.idleOn
                                accent: Services.Colors.red
                                onToggle: function() { Services.ShellData.toggleIdle() }
                                Layout.fillWidth: true
                            }

                            // Bottom row: Wi-Fi, VPN, BT
                            Components.TogglePill {
                                label: "Wi-Fi"
                                icon: Services.ShellData.wifiOn ? "󰤨" : "󰤭"
                                active: ccWindow.showingWifi
                                onToggle: function() { ccWindow.showingWifi = !ccWindow.showingWifi }
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
                                active: ccWindow.showingBt
                                onToggle: function() { ccWindow.showingBt = !ccWindow.showingBt }
                                Layout.fillWidth: true
                            }
                        }

                        // Wi-Fi List (Expandable SECTION)
                        ColumnLayout {
                            id: wifiExpandable
                            Layout.fillWidth: true
                            Layout.preferredHeight: ccWindow.showingWifi ? (wifiList.implicitHeight + powerRow.implicitHeight + sep.height + 20) : 0
                            clip: true
                            opacity: ccWindow.showingWifi ? 1 : 0
                            visible: opacity > 0
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10

                            Behavior on Layout.preferredHeight { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutQuart } }
                            Behavior on opacity { NumberAnimation { duration: Services.Colors.animFast } }

                            RowLayout {
                                id: powerRow
                                Layout.fillWidth: true
                                Layout.leftMargin: 4
                                Layout.rightMargin: 4
                                spacing: Services.Colors.spacingSmall

                                Components.ShadowText {
                                    text: "󰤨"
                                    font.pixelSize: 14
                                    color: Services.Colors.primary
                                    visible: Services.ShellData.wifiOn
                                }
                                Components.ShadowText {
                                    text: "󰤭"
                                    font.pixelSize: 14
                                    color: Services.Colors.dim
                                    visible: !Services.ShellData.wifiOn
                                }

                                Components.ShadowText {
                                    text: "Wi-Fi Power"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Services.Colors.mainText
                                    Layout.fillWidth: true
                                }
                                
                                Components.BarButton {
                                    text: Services.ShellData.wifiOn ? "ON" : "OFF"
                                    textColor: Services.ShellData.wifiOn ? Services.Colors.primary : Services.Colors.mainText
                                    bgColor: Qt.rgba(1, 1, 1, 0.1)
                                    onClicked: Services.ShellData.toggleWifi()
                                }
                            }

                            Rectangle {
                                id: sep
                                Layout.fillWidth: true
                                height: 1
                                color: Services.Colors.border
                                Layout.topMargin: 4
                                Layout.bottomMargin: 8
                            }

                            ListView {
                                id: wifiList
                                Layout.fillWidth: true
                                implicitHeight: Math.min(contentHeight, 300)
                                clip: true
                                interactive: true // Explicitly enable interaction
                                spacing: Services.Colors.spacingSmall
                                model: Services.ShellData.wifiOn ? Services.ShellData.wifiNetworks : []

                                delegate: Rectangle {
                                    width: wifiList.width
                                    height: 40
                                    radius: Services.Colors.radiusSmall
                                    color: netMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                                    border.width: 1
                                    border.color: netMouse.containsMouse ? Services.Colors.border : "transparent"

                                    property bool isActive: Services.ShellData.netSsid === modelData.ssid

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: Services.Colors.spacingLarge

                                        Components.ShadowText {
                                            text: {
                                                if (modelData.signal > 80) return "󰤨"
                                                if (modelData.signal > 60) return "󰤥"
                                                if (modelData.signal > 40) return "󰤢"
                                                if (modelData.signal > 20) return "󰤟"
                                                return "󰤯"
                                            }
                                            font.pixelSize: 16
                                            color: isActive ? Services.Colors.primary : Services.Colors.mainText
                                        }

                                        Components.ShadowText {
                                            text: modelData.ssid
                                            color: isActive ? Services.Colors.primary : Services.Colors.mainText
                                            font.bold: isActive
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            font.pixelSize: 11
                                        }
                                        
                                        Components.ShadowText {
                                            text: modelData.security && modelData.security !== "--" ? "" : ""
                                            font.pixelSize: 10
                                            color: Services.Colors.dim
                                            visible: text !== ""
                                        }
                                    }

                                    MouseArea {
                                        id: netMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!isActive) {
                                                Services.ShellData.connectWifi(modelData.ssid)
                                            }
                                        }
                                    }
                                }

                                footer: Item {
                                    width: parent.width
                                    height: contentHeight === 0 ? 40 : 0
                                    visible: contentHeight === 0
                                    Components.ShadowText {
                                        anchors.centerIn: parent
                                        text: !Services.ShellData.wifiOn ? "Wi-Fi is off" : "Scanning..."
                                        color: Services.Colors.dim
                                        font.pixelSize: 10
                                        font.italic: true
                                        visible: parent.visible
                                    }
                                }
                            }
                        }

                        // Bluetooth List (Expandable SECTION)
                        ColumnLayout {
                            id: btExpandable
                            Layout.fillWidth: true
                            Layout.preferredHeight: ccWindow.showingBt ? (btList.implicitHeight + btPowerRow.implicitHeight + btSep.height + 20) : 0
                            clip: true
                            opacity: ccWindow.showingBt ? 1 : 0
                            visible: opacity > 0
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10

                            Behavior on Layout.preferredHeight { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutQuart } }
                            Behavior on opacity { NumberAnimation { duration: Services.Colors.animFast } }

                            RowLayout {
                                id: btPowerRow
                                Layout.fillWidth: true
                                Layout.leftMargin: 4
                                Layout.rightMargin: 4
                                spacing: Services.Colors.spacingSmall

                                Components.ShadowText {
                                    text: "󰂯"
                                    font.pixelSize: 14
                                    color: Services.Colors.primary
                                    visible: Services.ShellData.btOn
                                }
                                Components.ShadowText {
                                    text: "󰂲"
                                    font.pixelSize: 14
                                    color: Services.Colors.dim
                                    visible: !Services.ShellData.btOn
                                }

                                Components.ShadowText {
                                    text: "Bluetooth Power"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Services.Colors.mainText
                                    Layout.fillWidth: true
                                }
                                
                                Components.BarButton {
                                    text: Services.ShellData.btOn ? "ON" : "OFF"
                                    textColor: Services.ShellData.btOn ? Services.Colors.primary : Services.Colors.mainText
                                    bgColor: Qt.rgba(1, 1, 1, 0.1)
                                    onClicked: Services.ShellData.toggleBt()
                                }
                            }

                            Rectangle {
                                id: btSep
                                Layout.fillWidth: true
                                height: 1
                                color: Services.Colors.border
                                Layout.topMargin: 4
                                Layout.bottomMargin: 8
                            }

                            ListView {
                                id: btList
                                Layout.fillWidth: true
                                implicitHeight: Math.min(contentHeight, 300)
                                clip: true
                                interactive: true
                                spacing: Services.Colors.spacingSmall
                                model: Services.ShellData.btOn ? Services.ShellData.btDevices : []

                                delegate: Rectangle {
                                    width: btList.width
                                    height: 40
                                    radius: Services.Colors.radiusSmall
                                    color: btMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                                    border.width: 1
                                    border.color: btMouse.containsMouse ? Services.Colors.border : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: Services.Colors.spacingLarge

                                        Components.ShadowText {
                                            text: modelData.connected ? "󰂱" : "󰂯"
                                            font.pixelSize: 16
                                            color: modelData.connected ? Services.Colors.primary : Services.Colors.mainText
                                        }

                                        Components.ShadowText {
                                            text: modelData.name
                                            color: modelData.connected ? Services.Colors.primary : Services.Colors.mainText
                                            font.bold: modelData.connected
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            font.pixelSize: 11
                                        }
                                        
                                        Components.ShadowText {
                                            text: modelData.connected ? "Connected" : "Paired"
                                            font.pixelSize: 9
                                            color: Services.Colors.dim
                                        }
                                    }

                                    MouseArea {
                                        id: btMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.connected) {
                                                Services.ShellData.disconnectBt(modelData.address)
                                            } else {
                                                Services.ShellData.connectBt(modelData.address)
                                            }
                                        }
                                    }
                                }

                                footer: Item {
                                    width: parent.width
                                    height: contentHeight === 0 ? 40 : 0
                                    visible: contentHeight === 0
                                    Components.ShadowText {
                                        anchors.centerIn: parent
                                        text: !Services.ShellData.btOn ? "Bluetooth is off" : "No paired devices"
                                        color: Services.Colors.dim
                                        font.pixelSize: 10
                                        font.italic: true
                                        visible: parent.visible
                                    }
                                }
                            }
                        }


                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Services.Colors.border
                        }

                        // ── Weather ─────────────────────────────
                        ColumnLayout {
                            id: weatherCol
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            spacing: Services.Colors.spacingNormal 

                            HoverHandler {
                                id: cardHover
                            }

                            RowLayout {
                                spacing: Services.Colors.spacingLarge
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
                                    spacing: Services.Colors.spacingSmall
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
                                    id: weatherRefreshBtn
                                    implicitWidth: 32; implicitHeight: 32
                                    radius: Services.Colors.radiusSmall
                                    color: weatherRefreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.1)
                                    opacity: cardHover.hovered ? 1.0 : 0.0
                                    
                                    Behavior on opacity {
                                        NumberAnimation { duration: Services.Colors.animFast }
                                    }

                                    transform: Scale {
                                        id: refreshScale
                                        origin.x: weatherRefreshBtn.width / 2
                                        origin.y: weatherRefreshBtn.height / 2
                                    }

                                    SequentialAnimation {
                                        id: clickAnim
                                        NumberAnimation { target: refreshScale; property: "xScale"; from: 1.0; to: 0.8; duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
                                        NumberAnimation { target: refreshScale; property: "yScale"; from: 1.0; to: 0.8; duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
                                        NumberAnimation { target: refreshScale; property: "xScale"; from: 0.8; to: 1.0; duration: Services.Colors.animNormal; easing.type: Easing.OutBack }
                                        NumberAnimation { target: refreshScale; property: "yScale"; from: 0.8; to: 1.0; duration: Services.Colors.animNormal; easing.type: Easing.OutBack }
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
                                        onClicked: {
                                            Services.ShellData.refreshWeather()
                                            clickAnim.restart()
                                        }
                                    }
                                }
                            }

                            // Hourly forecast (Scrollable)
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64
                                clip: true

                                Flickable {
                                    id: weatherFlick
                                    anchors.fill: parent
                                    contentWidth: hourlyRow.implicitWidth
                                    flickableDirection: Flickable.HorizontalFlick
                                    boundsBehavior: Flickable.StopAtBounds

                                    ScrollBar.horizontal: ScrollBar {
                                        id: weatherScrollBar
                                        policy: ScrollBar.AlwaysOn
                                        parent: weatherFlick
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        opacity: (weatherHover.hovered || weatherScrollBar.active) ? 1.0 : 0.0
                                        
                                        Behavior on opacity {
                                            NumberAnimation { duration: Services.Colors.animNormal }
                                        }
                                        
                                        contentItem: Rectangle {
                                            implicitHeight: 3
                                            radius: Services.Colors.radiusSmall
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
                                        spacing: Services.Colors.spacingXLarge
                                        Layout.topMargin: 4
                                        
                                        Repeater {
                                            model: Services.ShellData.hourlyWeather
                                            delegate: ColumnLayout {
                                                spacing: Services.Colors.spacingSmall
                                                
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

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Services.Colors.border
                        }
                    }

                    // ── Info Content ────────────────────────────────
                    ColumnLayout {
                        id: infoContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Services.Colors.spacingXLarge
                        spacing: Services.Colors.spacingXLarge
                        opacity: ccWindow.showingInfo ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity { NumberAnimation { duration: Services.Colors.animFast } }

                        RowLayout {
                            Layout.fillWidth: true
                            
                            // Back button
                            Rectangle {
                                implicitWidth: 32; implicitHeight: 32
                                radius: Services.Colors.radiusSmall
                                color: backMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.1)

                                Components.ShadowText {
                                    anchors.centerIn: parent
                                    text: "󰁍"
                                    font.pixelSize: 16
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.primary
                                }

                                MouseArea {
                                    id: backMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: ccWindow.showingInfo = false
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Services.Colors.spacingNormal

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "✦"
                                font.pixelSize: 64
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.primary
                            }

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignHCenter
                                text: Services.ShellData.configTitle
                                font.pixelSize: 24
                                font.weight: Font.Bold
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.mainText
                            }

                            Components.ShadowText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Version " + Services.ShellData.configVersion
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                font.family: Services.Colors.fontFamily
                                color: Services.Colors.dim
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Services.Colors.border
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Services.Colors.spacingLarge

                            RowLayout {
                                spacing: Services.Colors.spacingLarge
                                Components.ShadowText {
                                    text: "󰆍"
                                    font.pixelSize: 22
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.primary
                                }
                                ColumnLayout {
                                    spacing: Services.Colors.spacingSmall
                                    Components.ShadowText {
                                        text: "Quickshell"
                                        font.pixelSize: 15
                                        font.weight: Font.Bold
                                        font.family: Services.Colors.fontFamily
                                        color: Services.Colors.mainText
                                    }
                                    Components.ShadowText {
                                        text: "v" + Services.ShellData.shellVersion
                                        font.pixelSize: 11
                                        font.family: Services.Colors.fontFamily
                                        color: Services.Colors.dim
                                    }
                                }
                            }

                            RowLayout {
                                spacing: Services.Colors.spacingNormal
                                Components.ShadowText {
                                    text: "󰰏"
                                    font.pixelSize: 14
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.primary
                                }
                                Components.ShadowText {
                                    text: "Author: " + Services.ShellData.shellAuthor
                                    font.pixelSize: 13
                                    font.family: Services.Colors.fontFamily
                                    color: Services.Colors.mainText
                                }
                            }
                        }
                    }
                }

                // ── Footer ──────────────────────────────
                RowLayout {
                    id: footerRow
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    spacing: Services.Colors.spacingNormal

                    HoverHandler {
                        id: footerHover
                    }

                        // Avatar
                        Rectangle {
                            id: avatarContainer
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: 38; implicitHeight: 38
                            radius: Services.Colors.radiusLarge
                            color: "transparent"
                            border.width: 1.5
                            border.color: Services.Colors.border

                            Rectangle {
                                id: maskRect
                                width: avatarContainer.width; height: avatarContainer.height
                                radius: avatarContainer.radius
                                visible: false
                            }

                            Item {
                                anchors.fill: parent
                                anchors.margins: 2
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: maskRect
                                }

                                Image {
                                    id: avatarImage
                                    anchors.fill: parent
                                    source: "face.png"
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize: Qt.size(76, 76)
                                }

                                Components.ShadowText {
                                    anchors.centerIn: parent
                                    text: "󰇓"
                                    visible: avatarImage.status !== Image.Ready
                                    font.pixelSize: 20
                                    color: Services.Colors.dim
                                }
                            }
                        }

                    // Name + system info
                    ColumnLayout {
                        spacing: Services.Colors.spacingSmall
                        Layout.alignment: Qt.AlignVCenter

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

                    Item { Layout.fillWidth: true }

                    // Info button
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 28; implicitHeight: 28
                        radius: Services.Colors.radiusSmall
                        color: infoMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12) : "transparent"
                        border.width: 1
                        border.color: infoMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35) : Services.Colors.border
                        opacity: footerHover.hovered ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation { duration: Services.Colors.animFast }
                        }

                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: "󰋼"
                            font.pixelSize: 15
                            font.family: Services.Colors.fontFamily
                            font.weight: Font.DemiBold
                            color: infoMouse.containsMouse ? Services.Colors.primary : Services.Colors.dim
                        }

                        MouseArea {
                            id: infoMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                ccWindow.showingInfo = !ccWindow.showingInfo
                            }
                        }
                    }

                    // Power button
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 28; implicitHeight: 28
                        radius: Services.Colors.radiusSmall
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
                        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.InOutQuart }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
                    }
                    Behavior on Layout.topMargin {
                        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.InOutQuart }
                    }
                }
            }
        }
    }

}
