import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "services" as Services
import "components" as Components

PanelWindow {
    id: root

    property bool active: false
    signal closeRequested()
    
    screen: Services.MonitorService.primaryScreen
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    focusable: true
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            view.forceActiveFocus()
        }
    }

    PathView {
        id: view
        anchors.fill: parent
        model: Services.WallpaperService.wallpapers
        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        snapMode: PathView.SnapToItem

        path: Path {
            startX: root.width / 6
            startY: root.height / 2
            PathAttribute { name: "iconScale"; value: 0.3 }
            PathAttribute { name: "iconOpacity"; value: 0.0 }
            PathAttribute { name: "iconBlur"; value: 32 }
            
            PathLine { x: root.width / 2; y: root.height / 2 }
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathAttribute { name: "iconOpacity"; value: 1.0 }
            PathAttribute { name: "iconBlur"; value: 0 }
            
            PathLine { x: 5 * root.width / 6; y: root.height / 2 }
            PathAttribute { name: "iconScale"; value: 0.3 }
            PathAttribute { name: "iconOpacity"; value: 0.0 }
            PathAttribute { name: "iconBlur"; value: 32 }
        }

        delegate: Item {
            width: root.width * 0.4
            height: root.height * 0.5
            z: PathView.isCurrentItem ? 10 : 1
            scale: PathView.iconScale
            opacity: PathView.iconOpacity

            Item {
                anchors.fill: parent
                
                // Rounded corners via opacity mask
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: root.width * 0.4
                        height: root.height * 0.5
                        radius: Services.Colors.radiusLarge
                    }
                }

                Image {
                    id: img
                    anchors.fill: parent
                    source: modelData
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize: Qt.size(1920, 1080)
                }

                FastBlur {
                    anchors.fill: img
                    source: img
                    radius: PathView.iconBlur
                    visible: radius > 0
                }
                
                // Active indicator (optional, but keep it subtle)
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 4
                    border.color: Services.Colors.primary
                    radius: Services.Colors.radiusLarge
                    visible: PathView.iconScale > 0.9
                }

                // Title label for current item (text only)
                Components.ShadowText {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 30
                    visible: PathView.iconScale > 0.95
                    text: modelData.split('/').pop().split('.')[0]
                    color: "white"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    font.family: Services.Colors.fontFamily
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (PathView.isCurrentItem) {
                        applyWallpaper()
                    } else {
                        view.currentIndex = index
                    }
                }
            }
        }
        
        function applyWallpaper() {
            let wallpaper = view.model[view.currentIndex].replace("file://", "")
            Services.WallpaperService.setWallpaper(wallpaper)
            root.closeRequested()
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Tab) {
                if (event.modifiers & Qt.ShiftModifier) {
                    view.decrementCurrentIndex()
                } else {
                    view.incrementCurrentIndex()
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                view.incrementCurrentIndex()
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                view.decrementCurrentIndex()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                applyWallpaper()
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                root.closeRequested()
                event.accepted = true
            }
        }
    }
}
