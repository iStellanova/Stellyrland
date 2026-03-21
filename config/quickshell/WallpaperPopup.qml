import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtMultimedia
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
            id: delegateItem
            width: root.width * 0.4
            height: root.height * 0.5
            z: PathView.isCurrentItem ? 10 : 1
            scale: PathView.iconScale
            opacity: PathView.iconOpacity

            property bool isCurrent: PathView.isCurrentItem
            property bool isVideo: modelData.isVideo

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

                // ── Static image preview ──
                Image {
                    id: img
                    anchors.fill: parent
                    source: delegateItem.isVideo ? modelData.framePath : modelData.path
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    sourceSize: Qt.size(960, 540) // Downscale for carousel efficiency
                    visible: true
                    cache: true
                }

                // ── Animated video preview ──
                Item {
                    id: videoContainer
                    anchors.fill: parent
                    visible: delegateItem.isVideo && delegateItem.isCurrent

                    MediaPlayer {
                        id: videoPlayer
                        source: delegateItem.isVideo ? modelData.path : ""
                        videoOutput: videoOutput
                        loops: MediaPlayer.Infinite
                        
                        audioOutput: AudioOutput {
                            muted: true
                        }
                    }

                    VideoOutput {
                        id: videoOutput
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                    }

                    // Auto-play when this is the current item and visible
                    Connections {
                        target: delegateItem
                        function onIsCurrentChanged() {
                            if (delegateItem.isCurrent && delegateItem.isVideo && root.visible) {
                                videoPlayer.play()
                            } else {
                                videoPlayer.pause()
                            }
                        }
                    }

                    Connections {
                        target: root
                        function onVisibleChanged() {
                            if (root.visible && delegateItem.isCurrent && delegateItem.isVideo) {
                                videoPlayer.play()
                            } else {
                                videoPlayer.pause()
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (delegateItem.isCurrent && delegateItem.isVideo && root.visible) {
                            videoPlayer.play()
                        }
                    }
                }

                FastBlur {
                    anchors.fill: parent
                    source: (delegateItem.isVideo && delegateItem.isCurrent) ? videoOutput : img
                    radius: delegateItem.PathView.iconBlur
                    visible: radius > 0
                }
                
                // Active indicator
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 4
                    border.color: Services.Colors.primary
                    radius: Services.Colors.radiusLarge
                    visible: delegateItem.PathView.iconScale > 0.9
                }

                // ── Video badge ──
                Rectangle {
                    visible: delegateItem.isVideo && delegateItem.PathView.iconScale > 0.5
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 12
                    anchors.rightMargin: 12
                    width: 36
                    height: 36
                    radius: 18
                    color: Qt.rgba(0, 0, 0, 0.6)

                    Text {
                        anchors.centerIn: parent
                        text: "▶"
                        color: "white"
                        font.pixelSize: 16
                    }
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
            let entry = view.model[view.currentIndex]
            let wallpaperPath = entry.path.replace("file://", "")
            Services.WallpaperService.setWallpaper(wallpaperPath)
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
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_D) {
                view.incrementCurrentIndex()
                event.accepted = true
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
                view.decrementCurrentIndex()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_S) {
                applyWallpaper()
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                root.closeRequested()
                event.accepted = true
            }
        }
    }
}
