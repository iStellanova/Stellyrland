import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

PanelWindow {
    id: root

    // ── Architecture Note ─────────────────────────────────────
    // This launcher uses a Dual-Window system:
    // 1. AppLauncher (This): A 600px wide vertical strip for localized blur.
    //    The UI slides vertically WITHIN this strip for smooth animation.
    // 2. launcherScrim (in shell.qml): A full-screen transparent window
    //    that handles closing when clicking 'outside' the launcher.
    // ──────────────────────────────────────────────────────────

    signal closeRequested()
    property bool open: false
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "quickshell-popups"

    implicitWidth: 600
    implicitHeight: screen.height
    
    margins.left: (screen.width - 600) / 2
    margins.top: 0

    visible: open || container.opacity > 0
    
    // Internal state for sliding with a more premium Exponential easing
    property real slideY: open ? (root.height - 450) / 2 : root.height
    Behavior on slideY { 
        NumberAnimation { 
            duration: Services.Colors.animSlow
            easing.type: Easing.OutExpo 
        } 
    }

    Behavior on visible {
        PropertyAnimation { duration: 0 }
    }

    property bool mouseActive: true
    color: "transparent"

    onOpenChanged: {
        if (open) {
            // Ensure search is focused when opened
            searchInput.forceActiveFocus();
            // Start at index 0 (the first app)
            appList.currentIndex = 0;
            // Ensure we scroll to the top to see the Recent Apps header
            scrollTimer.restart();
        } else {
            searchInput.text = "";
            Services.AppService.searchQuery = "";
        }
    }

    Timer {
        id: scrollTimer
        interval: 10
        onTriggered: appList.positionViewAtBeginning()
    }

    Rectangle {
        id: container
        x: 0
        y: root.slideY
        width: 600
        height: 450
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1.5
        border.color: Services.Colors.border
        
        // Prevent clicks within the launcher but outside items from reaching the scrim
        MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => mouse.accepted = true
        }
        
        layer.enabled: root.open
        // Glassmorphism effect via opacity
        opacity: root.open ? 0.98 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: Services.Colors.spacingXLarge

            // Search Header
            RowLayout {
                spacing: Services.Colors.spacingLarge
                Layout.fillWidth: true

                Components.ShadowText {
                    text: "󰍉"
                    font.pixelSize: 22
                    color: Services.Colors.primary
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search apps..."
                    placeholderTextColor: Services.Colors.mainText
                    color: Services.Colors.mainText
                    font.family: Services.Colors.fontFamily
                    font.pixelSize: 18
                    background: null
                    
                    onTextChanged: {
                        Services.AppService.searchQuery = text
                        appList.currentIndex = 0
                        root.mouseActive = false
                    }
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.closeRequested();
                            return;
                        }

                        const isDown = event.key === Qt.Key_Down || (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier));
                        const isUp = event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier));

                        if (isDown) {
                            appList.currentIndex = (appList.currentIndex + 1) % appList.count;
                            event.accepted = true;
                        } else if (isUp) {
                            appList.currentIndex = (appList.currentIndex - 1 + appList.count) % appList.count;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            let current = appList.currentItem;
                            if (current) current.launch();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Services.Colors.border
            }

            // App List
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: Services.AppService.filteredApps
                spacing: Services.Colors.spacingSmall
                currentIndex: 0
                
                header: Component {
                    ColumnLayout {
                        width: appList.width
                        spacing: Services.Colors.spacingXLarge
                        visible: searchInput.text === "" && Services.AppService.recentApps.length > 0
                        
                        // Recent Apps Grid
                        Components.RecentAppsGrid {
                            onAppLaunched: root.closeRequested()
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Services.Colors.border
                            visible: Services.AppService.isCategorized && Services.AppService.recentApps.length > 0
                        }
                        
                        Item { height: 4; Layout.fillWidth: true }
                    }
                }

                onModelChanged: currentIndex = 0

                section.property: Services.AppService.isCategorized ? "name" : ""
                section.criteria: ViewSection.FirstCharacter
                section.delegate: Component {
                    Item {
                        width: appList.width
                        height: 32
                        visible: Services.AppService.isCategorized
                        
                        Components.ShadowText {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: section
                            font.pixelSize: 11
                            font.weight: Font.Black
                            font.family: Services.Colors.fontFamily
                            color: Services.Colors.primary
                            opacity: 0.6
                        }
                    }
                }

                highlight: Rectangle {
                    z: 2
                    radius: Services.Colors.radiusSmall
                    color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
                    border.width: 1
                    border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.4)
                    
                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 4
                        height: parent.height - 24
                        radius: Services.Colors.radiusSmall
                        color: Services.Colors.primary
                    }
                }
                
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 250
                highlightMoveVelocity: -1
                
                delegate: Item {
                    id: delegateItem
                    width: appList.width
                    height: 52
                    
                    property bool isCurrent: ListView.isCurrentItem

                    function launch() {
                        launchAnimation.start();
                    }

                    SequentialAnimation {
                        id: launchAnimation
                        NumberAnimation { target: contentRect; property: "scale"; to: 0.95; duration: Services.Colors.animFast; easing.type: Easing.OutQuad }
                        NumberAnimation { target: contentRect; property: "scale"; to: 1.0; duration: Services.Colors.animNormal; easing.type: Easing.OutBack }
                        ScriptAction { 
                            script: {
                                Services.AppService.launch(modelData.exec);
                                root.closeRequested();
                            }
                        }
                    }

                    Rectangle {
                        id: contentRect
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: Services.Colors.radiusSmall
                        color: "transparent"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 12
                            spacing: Services.Colors.spacingLarge

                            // App Icon
                            Components.AppIcon {
                                width: 34; height: 34
                                radius: Services.Colors.radiusSmall
                                iconBgColor: Qt.rgba(1, 1, 1, 0.08)
                                fallbackBgColor: Qt.rgba(1, 1, 1, 0.08)
                                fallbackBorderWidth: 0
                                scale: isCurrent ? 1.1 : 1.0
                                iconName: modelData.icon
                                fallbackText: modelData.name
                                imageMargins: 4
                                
                                Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutBack } }
                            }

                            Components.ShadowText {
                                text: modelData.name
                                font.pixelSize: 15
                                font.weight: isCurrent ? Font.Bold : Font.DemiBold
                                color: isCurrent ? Services.Colors.primary : Services.Colors.mainText
                                Layout.fillWidth: true
                                
                                Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }
                            }
                            
                            Components.ShadowText {
                                text: " Enter"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: Services.Colors.primary
                                opacity: isCurrent ? 0.7 : 0
                                
                                Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal } }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: if (root.mouseActive) appList.currentIndex = index
                        onClicked: launch()
                    }
                }
            }

        }

        // Global mouse movement detector
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            hoverEnabled: true
            z: -1 // Behind everything
            onPositionChanged: {
                if (!root.mouseActive) root.mouseActive = true
            }
        }
    }
}
