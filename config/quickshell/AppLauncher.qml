import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

FloatingWindow {
    id: root

    property bool active: false
    signal closeRequested()

    implicitWidth: 600
    implicitHeight: 450
    
    property bool mouseActive: true
    
    color: "transparent"
    
    // Handle focus
    onActiveChanged: if (active) searchInput.forceActiveFocus()

    onVisibleChanged: {
        if (visible) {
            // Ensure search is focused when opened
            searchInput.forceActiveFocus();
        } else {
            searchInput.text = "";
            Services.AppService.searchQuery = "";
        }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        radius: Services.Colors.radiusNormal
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        
        layer.enabled: true
        // Glassmorphism effect via opacity and gradient
        opacity: 0.98

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
                            Rectangle {
                                width: 34; height: 34
                                radius: Services.Colors.radiusSmall
                                color: Qt.rgba(1, 1, 1, 0.08)
                                scale: isCurrent ? 1.1 : 1.0
                                
                                Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutBack } }
                                
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: modelData.icon.startsWith("/") ? ("file://" + modelData.icon) : ("image://icon/" + modelData.icon)
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    sourceSize: Qt.size(52, 52)
                                }
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
}
