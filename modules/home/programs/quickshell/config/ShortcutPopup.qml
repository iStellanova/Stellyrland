import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "services" as Services
import "components" as Components

PanelWindow {
    id: root
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-popups"
    focusable: true
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    property bool open: false
    signal closeRequested()
    
    color: "transparent"
    visible: open || container.opacity > 0
    
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: 900
        height: 650
        radius: Services.Colors.radiusLarge
        color: Services.Colors.bg
        border.width: 1
        border.color: Services.Colors.border
        
        readonly property int contentPadding: 32
        readonly property int itemSpacing: 16
        readonly property int listSpacing: 32
        
        layer.enabled: true
        
        anchors.verticalCenterOffset: open ? 0 : 40
        opacity: open ? 1 : 0
        
        Behavior on anchors.verticalCenterOffset { 
            NumberAnimation { 
                duration: open ? Services.Colors.animLarge : Services.Colors.animFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: open ? Services.Colors.curveExpressiveSpatial : Services.Colors.curveEmphasizedAccel
            } 
        }
        
        Behavior on opacity { 
            NumberAnimation { 
                duration: open ? Services.Colors.animLarge : Services.Colors.animFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: open ? Services.Colors.curveEmphasizedDecel : Services.Colors.curveEmphasizedAccel
            } 
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: container.contentPadding
            spacing: 24

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Components.ShadowText {
                    text: "󰌌"
                    font.pixelSize: 32
                    color: Services.Colors.primary
                }
                
                ColumnLayout {
                    spacing: 2
                    Components.ShadowText {
                        text: "Keyboard Shortcuts"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: Services.Colors.mainText
                    }
                    Components.ShadowText {
                        text: "Quickshell & Hyprland Cheat-sheet"
                        font.pixelSize: 14
                        opacity: 0.7
                        color: Services.Colors.mainText
                    }
                }
                
                Item { Layout.fillWidth: true }
            }

            FocusScope {
                Layout.fillWidth: true
                Layout.fillHeight: true
                focus: true

                // Bind List
                ListView {
                    id: categoriesList
                    anchors.fill: parent
                    model: Services.ShellData.hyprlandBinds
                    spacing: container.listSpacing
                    clip: true
                    cacheBuffer: 3000
                    focus: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.closeRequested()
                            event.accepted = true
                        }
                    }
                
                    ScrollBar.vertical: ScrollBar {
                        id: scrollBar
                        width: 12
                        policy: ScrollBar.AsNeeded
                        active: categoriesList.moving || categoriesList.flicking || scrollBar.hovered || scrollBar.pressed
                        
                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: Services.Colors.primary
                            opacity: scrollBar.active ? 0.6 : 0.2
                            
                            Behavior on opacity {
                                NumberAnimation { duration: Services.Colors.animFast }
                            }
                        }
                    }
                    
                    delegate: ColumnLayout {
                        width: categoriesList.width
                        spacing: 16
                        
                        // Category Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Rectangle {
                                width: 4
                                height: 20
                                radius: 2
                                color: Services.Colors.primary
                            }
                            
                            Components.ShadowText {
                                text: modelData.name.toUpperCase()
                                font.pixelSize: 14
                                font.weight: Font.Black
                                color: Services.Colors.primary
                                font.letterSpacing: 1.5
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Services.Colors.border
                                opacity: 0.3
                            }
                        }
                        
                        // Binds Grid
                        Flow {
                            width: parent.width
                            spacing: 16
                            
                            Repeater {
                                model: modelData.binds
                                
                                delegate: Rectangle {
                                    width: (categoriesList.width - container.itemSpacing) / 2
                                    height: 48
                                    radius: Services.Colors.radiusSmall
                                    color: bindMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.03) : "transparent"
                                    
                                    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 12
                                        
                                        // Key Combination
                                        Row {
                                            spacing: 4
                                            Layout.alignment: Qt.AlignVCenter
                                            
                                            Repeater {
                                                model: modelData.mod.split(" + ").filter(m => m.length > 0)
                                                delegate: Rectangle {
                                                    height: 24
                                                    width: Math.max(24, keyText.implicitWidth + 12)
                                                    radius: 4
                                                    color: Qt.rgba(1, 1, 1, 0.1)
                                                    border.width: 1
                                                    border.color: Qt.rgba(1, 1, 1, 0.1)
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    
                                                    Text {
                                                        id: keyText
                                                        anchors.centerIn: parent
                                                        text: modelData.trim()
                                                        font.pixelSize: 10
                                                        font.weight: Font.Bold
                                                        font.family: Services.Colors.fontFamily
                                                        color: Services.Colors.mainText
                                                    }
                                                }
                                            }
                                            
                                            Text {
                                                text: "+"
                                                visible: modelData.mod.length > 0 && modelData.key.length > 0
                                                anchors.verticalCenter: parent.verticalCenter
                                                font.pixelSize: 12
                                                font.family: Services.Colors.fontFamily
                                                color: Services.Colors.mainText
                                                opacity: 0.5
                                            }

                                            Rectangle {
                                                height: 24
                                                width: Math.max(24, mainKeyText.implicitWidth + 12)
                                                radius: 4
                                                color: Services.Colors.primary
                                                visible: modelData.key.length > 0
                                                anchors.verticalCenter: parent.verticalCenter
                                                
                                                Text {
                                                    id: mainKeyText
                                                    anchors.centerIn: parent
                                                    text: modelData.key
                                                    font.pixelSize: 10
                                                    font.weight: Font.Black
                                                    font.family: Services.Colors.fontFamily
                                                    color: Services.Colors.onPrimary
                                                }
                                            }
                                        }
                                        
                                        // Description / Action
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.description || (modelData.dispatcher + (modelData.arg ? ": " + modelData.arg : ""))
                                            font.pixelSize: 13
                                            font.family: Services.Colors.fontFamily
                                            color: Services.Colors.mainText
                                            elide: Text.ElideRight
                                            opacity: modelData.description ? 1.0 : 0.6
                                        }
                                    }
                                    MouseArea {
                                        id: bindMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: categoriesList.forceActiveFocus()
    }
    
    onOpenChanged: {
        if (open) {
            focusTimer.start()
        } else {
            focusTimer.stop()
        }
    }
}
