import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import "../services" as Services

// Media player card using native MPRIS integration
Rectangle {
    id: root

    property MprisPlayer player: Services.Music.player
    property bool framed: true

    Layout.fillWidth: true
    Layout.preferredHeight: playerCol.implicitHeight + (framed ? 28 : 0)
    implicitHeight: Layout.preferredHeight 
    
    radius: Services.Colors.radiusNormal
    color: framed ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
    border.width: framed ? 1 : 0
    border.color: Qt.rgba(1, 1, 1, 0.1)

    property string currentTrack: player ? (player.trackTitle || "") : ""
    onCurrentTrackChanged: {
        interpolatedPosition = 0;
        anchorPos = 0;
        anchorTime = Date.now();
        syncAnchor(true);
    }
    onPlayerChanged: {
        interpolatedPosition = 0;
        anchorPos = 0;
        anchorTime = Date.now();
        syncAnchor(true);
    }

    // Anchor-based interpolation: avoid cumulative drift by calculating relative to last sync
    property real interpolatedPosition: 0
    property double anchorPos: 0
    property double anchorTime: 0
    property double lastManualChange: 0
    
    function syncAnchor(force = false) {
        if (!player) {
            anchorPos = 0;
            anchorTime = 0;
            return;
        }
        let now = Date.now();
        if (!force && (now - lastManualChange < 2000)) return;
        
        // MPRIS positions use microseconds
        anchorPos = Math.max(0, player.position);
        anchorTime = now;
        updateInterpolated();
    }

    function updateInterpolated() {
        if (!player || anchorTime === 0) return;
        
        let now = Date.now();
        if (player.playbackState === MprisPlaybackState.Playing) {
            let elapsedSec = (now - anchorTime) / 1000.0;
            interpolatedPosition = anchorPos + elapsedSec;
        } else {
            interpolatedPosition = anchorPos;
        }

        // Cap at track length
        if (player.length > 0 && interpolatedPosition > player.length) {
            interpolatedPosition = player.length;
        }
    }

    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onMetadataChanged() { syncAnchor(true); }
        function onPlaybackStateChanged() { syncAnchor(true); }
        function onPositionChanged() { syncAnchor(); }
    }

    Timer {
        interval: 100
        running: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: updateInterpolated()
    }

    ColumnLayout {
        id: playerCol
        anchors {
            left: parent.left; right: parent.right
            top: parent.top
            margins: root.framed ? 14 : 0
            rightMargin: root.framed ? 16 : 0
        }
        spacing: Services.Colors.spacingLarge

        // ── Top row: art + title/artist + fav button ─────────
        RowLayout {
            spacing: Services.Colors.spacingLarge
            Layout.fillWidth: true

            // Album art
            Rectangle {
                id: artContainer
                implicitWidth: 48; implicitHeight: 48
                radius: Services.Colors.radiusNormal
                color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12)
                border.width: 1
                border.color: Services.Colors.border
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 1
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: artContainer.width; height: artContainer.height
                            radius: artContainer.radius
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: source != ""
                        asynchronous: true
                        sourceSize: Qt.size(96, 96)
                    }
                }

                ShadowText {
                    anchors.centerIn: parent
                    text: "♪"
                    font.pixelSize: 24
                    color: Services.Colors.primary
                    visible: !root.player || !root.player.trackArtUrl || root.player.trackArtUrl === ""
                }
            }

            // Title + artist
            ColumnLayout {
                spacing: Services.Colors.spacingSmall
                Layout.fillWidth: true

                ShadowText {
                    text: root.player ? (root.player.trackTitle || "Nothing playing") : "Nothing playing"
                    font.pixelSize: 12
                    font.family: Services.Colors.fontFamily
                    font.weight: Font.DemiBold
                    color: Services.Colors.mainText
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.maximumWidth: 160
                }

                ShadowText {
                    text: root.player ? (root.player.trackArtist || "") : ""
                    font.pixelSize: 10
                    font.family: Services.Colors.fontFamily
                    font.weight: Font.DemiBold
                    color: Services.Colors.dim
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.maximumWidth: 160
                    visible: text.length > 0
                }
            }
        }

        // ── Progress bar ─────────────────────────────────────
        Slider {
            id: progressSlider
            Layout.fillWidth: true
            visible: root.player && root.player.length > 0
            Layout.preferredHeight: visible ? implicitHeight : 0
            from: 0
            to: (root.player && root.player.length > 0) ? root.player.length : 1
            value: {
                if (!root.player || root.player.length <= 0) return 0
                let val = root.interpolatedPosition
                return isNaN(val) ? 0 : Math.min(val, root.player.length)
            }
            enabled: root.player !== null && root.player.canSeek

            background: Rectangle {
                x: progressSlider.leftPadding
                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                implicitWidth: 200; implicitHeight: 4
                width: progressSlider.availableWidth; height: implicitHeight
                radius: Services.Colors.radiusLarge
                color: Qt.rgba(1, 1, 1, 0.15) // Brighter background track

                // Played part
                Rectangle {
                    width: progressSlider.visualPosition * parent.width
                    height: parent.height; radius: Services.Colors.radiusLarge
                    color: Services.Colors.primary
                }
            }

            handle: Rectangle {
                x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                implicitWidth: 12; implicitHeight: 12
                radius: Services.Colors.radiusLarge
                color: "white"
                
                layer.enabled: true
                layer.effect: DropShadow {
                    color: Qt.rgba(0, 0, 0, 0.5)
                    radius: Services.Colors.radiusSmall
                    samples: 9
                }
            }

            onMoved: {
                if (root.player) {
                    root.player.position = progressSlider.value
                    root.anchorPos = progressSlider.value
                    root.anchorTime = Date.now()
                    root.lastManualChange = Date.now()
                    root.updateInterpolated()
                }
            }
        }

        // ── Playback controls ────────────────────────────────
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Services.Colors.spacingXLarge

            // Previous
            Rectangle {
                implicitWidth: 28; implicitHeight: 28; radius: Services.Colors.radiusSmall
                color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                ShadowText {
                    anchors.centerIn: parent; text: "󰒮"
                    font.pixelSize: 15; font.family: Services.Colors.fontFamily; font.weight: Font.DemiBold
                    color: prevMouse.containsMouse ? Services.Colors.mainText : Services.Colors.dim
                }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: if (root.player) root.player.previous()
                }
            }

            // Play/Pause
            Rectangle {
                implicitWidth: 32; implicitHeight: 32; radius: Services.Colors.radiusLarge
                color: root.player && root.player.playbackState === MprisPlaybackState.Playing
                       ? Services.Colors.primary : Services.Colors.primary

                ShadowText {
                    anchors.centerIn: parent
                    text: root.player && root.player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                    font.pixelSize: 17; font.family: Services.Colors.fontFamily; font.weight: Font.DemiBold
                    color: Services.Colors.bg
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.player) root.player.togglePlaying()
                }
            }

            // Next
            Rectangle {
                implicitWidth: 28; implicitHeight: 28; radius: Services.Colors.radiusSmall
                color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                ShadowText {
                    anchors.centerIn: parent; text: "󰒭"
                    font.pixelSize: 15; font.family: Services.Colors.fontFamily; font.weight: Font.DemiBold
                    color: nextMouse.containsMouse ? Services.Colors.mainText : Services.Colors.dim
                }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: if (root.player) root.player.next()
                }
            }
        }

        // ── Per-player volume ────────────────────────────────
        RowLayout {
            spacing: Services.Colors.spacingNormal
            Layout.fillWidth: true
            visible: root.player !== null && root.player.volumeSupported

            ShadowText {
                text: "󰕾"; font.pixelSize: 15; font.family: Services.Colors.fontFamily; font.weight: Font.DemiBold
                color: Services.Colors.primary
            }

            Slider {
                id: volSlider
                Layout.fillWidth: true
                from: 0; to: 1
                value: root.player ? root.player.volume : 0
                stepSize: 0.01

                background: Rectangle {
                    x: volSlider.leftPadding
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200; implicitHeight: 14
                    width: volSlider.availableWidth; height: implicitHeight
                    radius: Services.Colors.radiusLarge; color: Services.Colors.border

                    Rectangle {
                        width: volSlider.visualPosition * parent.width
                        height: parent.height; radius: Services.Colors.radiusLarge
                        color: Services.Colors.primary
                    }
                }

                handle: Rectangle {
                    x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    implicitWidth: 14; implicitHeight: 14; radius: Services.Colors.radiusLarge; color: "white"
                }

                onMoved: if (root.player) root.player.volume = volSlider.value

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: (wheel) => {
                        if (!root.player) return
                        let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                        let newVal = Math.max(0, Math.min(1, root.player.volume + step))
                        root.player.volume = newVal
                    }
                }
            }

            Item { implicitWidth: 20 }
        }
    }
}
