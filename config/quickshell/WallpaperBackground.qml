import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Wayland
import "services" as Services
import Qt5Compat.GraphicalEffects

// Final Zero-Handover Wallpaper Background (Explicit Flip-Flop)
PanelWindow {
    id: root
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"
    WlrLayershell.exclusiveZone: -1
    
    color: "black"

    Component.onCompleted: {
        if (Services.WallpaperService.currentWallpaper !== "") {
            let path = "file://" + Services.WallpaperService.currentWallpaper
            let isVideo = Services.WallpaperService.currentIsVideo
            root.transitionTo(path, isVideo, "")
        }
    }

    // ── Internal State ──
    property int activeLayer: 0 // 0 = Layer A, 1 = Layer B
    property bool isTransitioning: false
    property real wipeProgress: 0.0 
    property string transitionType: "wipeLeft"
    readonly property real diagonal: Math.sqrt(root.width * root.width + root.height * root.height)
    readonly property bool isCircle: transitionType.startsWith("circle")

    // Layer A State
    property string pathA: ""
    property bool isVideoA: false
    
    // Layer B State
    property string pathB: ""
    property bool isVideoB: false

    Item {
        id: layerA
        anchors.fill: parent
        z: (root.activeLayer === 0) ? 0 : 100
        visible: (root.activeLayer === 0) || root.isTransitioning

        layer.enabled: root.isTransitioning && root.activeLayer === 1 && root.isCircle
        layer.effect: OpacityMask {
            invert: root.transitionType === "circleShrink"
            maskSource: Rectangle {
                width: root.width; height: root.height
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: (root.transitionType === "circleGrow") ? (root.diagonal * root.wipeProgress) : (root.diagonal * (1.0 - root.wipeProgress))
                    height: width
                    radius: width / 2
                    color: "black"
                }
            }
        }

        MediaPlayer {
            id: playerA
            videoOutput: videoA
            loops: MediaPlayer.Infinite
            audioOutput: AudioOutput { muted: true }
            onMediaStatusChanged: {
                if (root.isTransitioning && root.activeLayer === 1 && !wipeInAnim.running) {
                    if (mediaStatus >= MediaPlayer.LoadedMedia || !root.isVideoA) {
                        proceedWithWipe()
                    }
                }
            }
        }

        Item {
            id: containerA
            clip: !root.isCircle
            width: (root.isTransitioning && root.activeLayer === 1 && !root.isCircle) ? 
                   ((transitionType === "wipeLeft" || transitionType === "wipeRight") ? root.width * wipeProgress : root.width) : root.width
            height: (root.isTransitioning && root.activeLayer === 1 && !root.isCircle) ? 
                    ((transitionType === "wipeUp" || transitionType === "wipeDown") ? root.height * wipeProgress : root.height) : root.height
            x: (root.isTransitioning && root.activeLayer === 1 && transitionType === "wipeRight") ? root.width * (1.0 - wipeProgress) : 0
            y: (root.isTransitioning && root.activeLayer === 1 && transitionType === "wipeDown") ? root.height * (1.0 - wipeProgress) : 0

            VideoOutput {
                id: videoA
                width: root.width; height: root.height
                x: -containerA.x; y: -containerA.y
                fillMode: VideoOutput.PreserveAspectCrop
                visible: root.isVideoA
            }
            Image {
                id: imageA
                width: root.width; height: root.height
                x: -containerA.x; y: -containerA.y
                fillMode: Image.PreserveAspectCrop
                visible: !root.isVideoA
                source: root.pathA
            }
        }
    }

    Item {
        id: layerB
        anchors.fill: parent
        z: (root.activeLayer === 1) ? 0 : 100
        visible: (root.activeLayer === 1) || root.isTransitioning

        layer.enabled: root.isTransitioning && root.activeLayer === 0 && root.isCircle
        layer.effect: OpacityMask {
            invert: root.transitionType === "circleShrink"
            maskSource: Rectangle {
                width: root.width; height: root.height
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: (root.transitionType === "circleGrow") ? (root.diagonal * root.wipeProgress) : (root.diagonal * (1.0 - root.wipeProgress))
                    height: width
                    radius: width / 2
                    color: "black"
                }
            }
        }

        MediaPlayer {
            id: playerB
            videoOutput: videoB
            loops: MediaPlayer.Infinite
            audioOutput: AudioOutput { muted: true }
            onMediaStatusChanged: {
                if (root.isTransitioning && root.activeLayer === 0 && !wipeInAnim.running) {
                    if (mediaStatus >= MediaPlayer.LoadedMedia || !root.isVideoB) {
                        proceedWithWipe()
                    }
                }
            }
        }

        Item {
            id: containerB
            clip: !root.isCircle
            width: (root.isTransitioning && root.activeLayer === 0 && !root.isCircle) ? 
                   ((transitionType === "wipeLeft" || transitionType === "wipeRight") ? root.width * wipeProgress : root.width) : root.width
            height: (root.isTransitioning && root.activeLayer === 0 && !root.isCircle) ? 
                    ((transitionType === "wipeUp" || transitionType === "wipeDown") ? root.height * wipeProgress : root.height) : root.height
            x: (root.isTransitioning && root.activeLayer === 0 && transitionType === "wipeRight") ? root.width * (1.0 - wipeProgress) : 0
            y: (root.isTransitioning && root.activeLayer === 0 && transitionType === "wipeDown") ? root.height * (1.0 - wipeProgress) : 0

            VideoOutput {
                id: videoB
                width: root.width; height: root.height
                x: -containerB.x; y: -containerB.y
                fillMode: VideoOutput.PreserveAspectCrop
                visible: root.isVideoB
            }
            Image {
                id: imageB
                width: root.width; height: root.height
                x: -containerB.x; y: -containerB.y
                fillMode: Image.PreserveAspectCrop
                visible: !root.isVideoB
                source: root.pathB
            }
        }
    }

    function proceedWithWipe() {
        if (!root.isTransitioning || wipeInAnim.running) return
        
        let types = ["wipeLeft", "wipeRight", "wipeUp", "wipeDown", "circleGrow", "circleShrink"]
        root.transitionType = types[Math.floor(Math.random() * types.length)]

        wipeInAnim.start()
        backupTimer.stop()
    }

    Timer { id: backupTimer; interval: 1200; onTriggered: proceedWithWipe() }

    NumberAnimation {
        id: wipeInAnim
        target: root
        property: "wipeProgress"
        from: 0.0; to: 1.0
        duration: 800
        easing.type: Easing.InOutCubic
        onFinished: {
            // Swap active layer
            let oldActive = root.activeLayer
            root.activeLayer = (oldActive === 0) ? 1 : 0
            
            // Now that the new layer is active and z:0 (bottom), we can safely hide the old one
            root.isTransitioning = false
            root.wipeProgress = 0.0
            
            // Stop the old player (which is now hidden on top)
            if (oldActive === 0) playerA.stop()
            else playerB.stop()
        }
    }

    function transitionTo(path, isVideo, framePath) {
        if (root.isTransitioning) return
        
        let curPath = (root.activeLayer === 0) ? root.pathA : root.pathB
        if (curPath === path) return

        if (root.pathA === "" && root.pathB === "") {
            // Initial load into Layer A
            root.pathA = path
            root.isVideoA = isVideo
            root.activeLayer = 0
            if (isVideo) { playerA.source = path; playerA.play() }
            return
        }

        root.isTransitioning = true
        root.wipeProgress = 0.0

        if (root.activeLayer === 0) {
            // Layer A is active (bottom). Prepare Layer B (top).
            root.pathB = path
            root.isVideoB = isVideo
            playerB.stop()
            if (isVideo) { playerB.source = path; playerB.play() }
            else { Qt.callLater(() => proceedWithWipe()) }
        } else {
            // Layer B is active (bottom). Prepare Layer A (top).
            root.pathA = path
            root.isVideoA = isVideo
            playerA.stop()
            if (isVideo) { playerA.source = path; playerA.play() }
            else { Qt.callLater(() => proceedWithWipe()) }
        }
        
        backupTimer.restart()
    }
}
