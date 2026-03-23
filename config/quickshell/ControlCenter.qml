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

    property bool open: false
    visible: open || rootContainer.opacity > 0 || ccTranslate.x > -350

    onVisibleChanged: if (!visible) {
        rootContainer.powerMenuVisible = false
        rootContainer.showingInfo = false
        rootContainer.showingWifi = false
        rootContainer.showingBt = false
    }

    Timer {
        id: closeTimer
        interval: Services.Colors.autoCloseInterval
        running: ccWindow.visible && ccWindow.open && !ccHover.hovered
        repeat: true
        onTriggered: ccWindow.closeRequested()
    }

    HoverHandler {
        id: ccHover
    }

    // Window geometry
    implicitWidth: 400
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
        left: 0
    }

    color: "transparent"

    // ── Pipewire is accessed as a singleton: Pipewire.defaultAudioSink ──

    // ── Root container ───────────────────────────────────────
    Rectangle {
        id: rootContainer
        width: 330
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 12
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        clip: true

        opacity: ccWindow.open ? 1.0 : 0.0
        
        transform: Translate {
            id: ccTranslate
            x: ccWindow.open ? 0 : -350
            Behavior on x {
                NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutExpo }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutExpo }
        }
        
        // Internal page states moved from root to keep them reactive even when hidden
        property bool powerMenuVisible: false
        property bool showingInfo: false
        property bool showingWifi: false
        property bool showingBt: false

        onShowingInfoChanged: if (showingInfo) { powerMenuVisible = false; showingWifi = false; showingBt = false; }
        onPowerMenuVisibleChanged: if (powerMenuVisible) { showingInfo = false; showingWifi = false; showingBt = false; }
        onShowingWifiChanged: if (showingWifi) { powerMenuVisible = false; showingInfo = false; showingBt = false; Services.NetworkService.refreshWifi(); }
        onShowingBtChanged: if (showingBt) { powerMenuVisible = false; showingInfo = false; showingWifi = false; }

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
                    Layout.preferredHeight: rootContainer.showingInfo ? (infoContent.implicitHeight + (Services.Colors.spacingXLarge * 2)) : ccMainContent.implicitHeight
                    clip: true

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutQuart }
                    }

                    ColumnLayout {
                        id: ccMainContent
                        anchors.fill: parent
                        spacing: Services.Colors.spacingLarge
                        opacity: rootContainer.showingInfo ? 0 : 1
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
                                icon: Services.AudioService.micMuted ? "󰍭" : "󰍬"
                                active: Services.AudioService.micMuted
                                accent: Services.Colors.red
                                onToggle: function() { Services.AudioService.toggleMic() }
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
                                icon: Services.NetworkService.wifiOn ? "󰤨" : "󰤭"
                                active: rootContainer.showingWifi
                                onToggle: function() { rootContainer.showingWifi = !rootContainer.showingWifi }
                                Layout.fillWidth: true
                            }

                            Components.TogglePill {
                                label: "VPN"
                                icon: "󰖂"
                                active: Services.NetworkService.vpnOn
                                accent: Services.Colors.primary
                                onToggle: function() { Services.NetworkService.toggleVpn() }
                                Layout.fillWidth: true
                            }

                            Components.TogglePill {
                                label: "BT"
                                icon: "󰂯"
                                active: rootContainer.showingBt
                                onToggle: function() { rootContainer.showingBt = !rootContainer.showingBt }
                                Layout.fillWidth: true
                            }
                        }

                        // Wi-Fi List (Expandable SECTION)
                        ColumnLayout {
                            id: wifiExpandable
                            Layout.fillWidth: true
                            Layout.preferredHeight: rootContainer.showingWifi ? (wifiList.implicitHeight + powerRow.implicitHeight + sep.height + 20) : 0
                            clip: true
                            opacity: rootContainer.showingWifi ? 1 : 0
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
                                    visible: Services.NetworkService.wifiOn
                                }
                                Components.ShadowText {
                                    text: "󰤭"
                                    font.pixelSize: 14
                                    color: Services.Colors.dim
                                    visible: !Services.NetworkService.wifiOn
                                }

                                Components.ShadowText {
                                    text: "Wi-Fi Power"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Services.Colors.mainText
                                    Layout.fillWidth: true
                                }
                                
                                Components.BarButton {
                                    text: Services.NetworkService.wifiOn ? "ON" : "OFF"
                                    textColor: Services.NetworkService.wifiOn ? Services.Colors.primary : Services.Colors.mainText
                                    bgColor: Qt.rgba(1, 1, 1, 0.1)
                                    onClicked: Services.NetworkService.toggleWifi()
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
                                model: Services.NetworkService.wifiOn ? Services.NetworkService.wifiNetworks : []

                                delegate: Rectangle {
                                    width: wifiList.width
                                    height: 40
                                    radius: Services.Colors.radiusSmall
                                    color: netMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                                    border.width: 1
                                    border.color: netMouse.containsMouse ? Services.Colors.border : "transparent"

                                    property bool isActive: Services.NetworkService.netSsid === modelData.ssid

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
                                                Services.NetworkService.connectWifi(modelData.ssid)
                                            }
                                        }
                                    }
                                }

                                footer: Item {
                                    width: parent.width
                                    height: wifiList.count === 0 ? 40 : 0
                                    visible: wifiList.count === 0
                                    Components.ShadowText {
                                        anchors.centerIn: parent
                                        text: !Services.NetworkService.wifiOn ? "Wi-Fi is off" : "Scanning..."
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
                            Layout.preferredHeight: rootContainer.showingBt ? (btList.implicitHeight + btPowerRow.implicitHeight + btSep.height + 20) : 0
                            clip: true
                            opacity: rootContainer.showingBt ? 1 : 0
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
                                    visible: Services.NetworkService.btOn
                                }
                                Components.ShadowText {
                                    text: "󰂲"
                                    font.pixelSize: 14
                                    color: Services.Colors.dim
                                    visible: !Services.NetworkService.btOn
                                }

                                Components.ShadowText {
                                    text: "Bluetooth Power"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Services.Colors.mainText
                                    Layout.fillWidth: true
                                }
                                
                                Components.BarButton {
                                    text: Services.NetworkService.btOn ? "ON" : "OFF"
                                    textColor: Services.NetworkService.btOn ? Services.Colors.primary : Services.Colors.mainText
                                    bgColor: Qt.rgba(1, 1, 1, 0.1)
                                    onClicked: Services.NetworkService.toggleBt()
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
                                model: Services.NetworkService.btOn ? Services.NetworkService.btDevices : []

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
                                                Services.NetworkService.disconnectBt(modelData.address)
                                            } else {
                                                Services.NetworkService.connectBt(modelData.address)
                                            }
                                        }
                                    }
                                }

                                footer: Item {
                                    width: parent.width
                                    height: btList.count === 0 ? 40 : 0
                                    visible: btList.count === 0
                                    Components.ShadowText {
                                        anchors.centerIn: parent
                                        text: !Services.NetworkService.btOn ? "Bluetooth is off" : "No paired devices"
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
                        opacity: rootContainer.showingInfo ? 1 : 0
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
                                    onClicked: rootContainer.showingInfo = false
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
                                layer.enabled: ccWindow.open
                                layer.effect: OpacityMask {
                                    maskSource: maskRect
                                }

                                Image {
                                    id: avatarImage
                                    anchors.fill: parent
                                    source: (Services.ConfigService.shellAvatar.startsWith("/") || Services.ConfigService.shellAvatar.startsWith("http")) 
                                            ? Services.ConfigService.shellAvatar 
                                            : Quickshell.shellDir + "/" + Services.ConfigService.shellAvatar
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

                    // Settings button
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 28; implicitHeight: 28
                        radius: Services.Colors.radiusSmall
                        color: settingsMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12) : "transparent"
                        border.width: 1
                        border.color: settingsMouse.containsMouse ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.35) : Services.Colors.border
                        opacity: footerHover.hovered ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation { duration: Services.Colors.animFast }
                        }

                        Components.ShadowText {
                            anchors.centerIn: parent
                            text: "󰒓"
                            font.pixelSize: 15
                            font.family: Services.Colors.fontFamily
                            font.weight: Font.DemiBold
                            color: settingsMouse.containsMouse ? Services.Colors.primary : Services.Colors.dim
                        }

                        MouseArea {
                            id: settingsMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                Services.ShellData.settingsVisible = !Services.ShellData.settingsVisible
                                if (Services.ShellData.settingsVisible) ccWindow.closeRequested()
                            }
                        }
                    }

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
                                rootContainer.showingInfo = !rootContainer.showingInfo
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
                                rootContainer.powerMenuVisible = !rootContainer.powerMenuVisible
                            }
                        }
                    }
                }

                // ── Power Menu (Animate Slide) ──────────────
                Components.PowerMenu {
                    id: powerMenu
                    window: ccWindow
                    Layout.fillWidth: true
                    Layout.preferredHeight: rootContainer.powerMenuVisible ? 80 : 0
                    opacity: rootContainer.powerMenuVisible ? 1 : 0
                    visible: opacity > 0
                    Layout.topMargin: rootContainer.powerMenuVisible ? -4 : -8
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
