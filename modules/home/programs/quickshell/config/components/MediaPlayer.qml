import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Services.Mpris
import "../services" as Services
import "." as Components

// Media player card using native MPRIS integration
Rectangle {
    id: root

    property MprisPlayer player: Services.Music.player
    property bool framed: true

    onPlayerChanged: syncAnchor(true)

    Layout.fillWidth: true
    Layout.preferredHeight: topCol.implicitHeight + (framed ? 28 : 0)
    implicitHeight: Layout.preferredHeight 
    
    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutCubic }
    }

    radius: Services.Colors.radiusNormal
    color: framed ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
    border.width: framed ? 1 : 0
    border.color: Qt.rgba(1, 1, 1, 0.1)

    // Anchor-based interpolation logic for smooth progress bar
    property real interpolatedPosition: 0
    property double anchorPos: 0
    property double anchorTime: 0
    property double lastManualChange: 0
    
    function syncAnchor(force = false) {
        if (!player) return;
        let now = Date.now();
        if (!force && (now - lastManualChange < 2000)) return;
        
        // Avoid jitter by only syncing if the deviation is significant (> 1s) or if forced
        if (!force && Math.abs(interpolatedPosition - player.position) < 1.0) return;

        anchorPos = Math.max(0, player.position);
        anchorTime = now;
        updateInterpolated();
    }

    function updateInterpolated() {
        if (!player) return;
        let now = Date.now();

        // re-anchor if player position changed significantly since last sync
        if (anchorTime === 0 || Math.abs(player.position - anchorPos) > 0.1) {
            anchorPos = player.position;
            anchorTime = now;
        }

        if (player.playbackState === MprisPlaybackState.Playing) {
            let elapsedSec = (now - anchorTime) / 1000.0;
            interpolatedPosition = anchorPos + elapsedSec;
        } else {
            interpolatedPosition = player.position;
        }

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
        running: root.visible && root.player !== null && root.player.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: updateInterpolated()
    }

    ColumnLayout {
        id: topCol
        anchors {
            left: parent.left; right: parent.right
            top: parent.top
            margins: root.framed ? 14 : 0
            rightMargin: root.framed ? 16 : 0
        }
        spacing: Services.Colors.spacingLarge

        // ── Tabs row ───────────────────────────────────────
        RowLayout {
            spacing: Services.Colors.spacingSmall
            visible: Services.Music.players.length > 1
            Layout.fillWidth: true
            Layout.bottomMargin: -Services.Colors.spacingSmall

            Repeater {
                model: Services.Music.players
                
                Rectangle {
                    id: tabBtn
                    required property var modelData
                    property bool isSelected: Services.Music.player === modelData
                    
                    implicitWidth: 32; implicitHeight: 28
                    radius: Services.Colors.radiusSmall
                    color: isSelected ? Services.Colors.alpha(Services.Colors.primary, 0.12) 
                                      : (tabMouse.containsMouse ? Services.Colors.alpha(Qt.color("white"), 0.05) : "transparent")
                    border.width: 1
                    border.color: isSelected ? Services.Colors.alpha(Services.Colors.primary, 0.2) 
                                             : (tabMouse.containsMouse ? Services.Colors.alpha(Qt.color("white"), 0.1) : "transparent")

                    // Scale feedback
                    scale: tabMouse.pressed ? 0.92 : 1.0
                    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: Services.Colors.animFast } }

                    ShadowText {
                        anchors.centerIn: parent
                        text: getIconForPlayer(modelData.identity)
                        font.pixelSize: 14
                        color: isSelected ? Services.Colors.primary : Services.Colors.mainText
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 2
                        width: 3; height: 3; radius: 1.5
                        color: isSelected ? Services.Colors.primary : Services.Colors.mainText
                        visible: modelData.playbackState === MprisPlaybackState.Playing
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.Music.manualPlayer = modelData
                    }
                }
            }
        }

        // ── Content Area with Sliding Animation ────────────
        ListView {
            id: playerListView
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            clip: true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: Services.Colors.animNormal
            highlightMoveVelocity: -1
            interactive: false // Selection via tabs

            model: Services.Music.players
            currentIndex: {
                for (let i = 0; i < Services.Music.players.length; i++) {
                    if (Services.Music.players[i] === Services.Music.player) return i;
                }
                return 0;
            }

            delegate: ColumnLayout {
                id: delegateCol
                width: playerListView.width
                spacing: Services.Colors.spacingLarge
                required property var modelData
                
                readonly property var mPlayer: modelData

                // ── Top row: art + title/artist ─────────────────────
                RowLayout {
                    spacing: Services.Colors.spacingLarge
                    Layout.fillWidth: true

                        // Record Art Container
                        Rectangle {
                            id: artCont
                            implicitWidth: 48; implicitHeight: 48
                            radius: Services.Colors.radiusNormal
                            color: Services.Colors.alpha(Services.Colors.primary, 0.12)
                            border.width: 1
                            border.color: Services.Colors.border

                            // The Mask (invisible item that defines the shape)
                            Rectangle {
                                id: artMask
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: artCont.radius - 1
                                color: "white"
                                visible: false
                                layer.enabled: true
                            }

                            Item {
                                anchors.fill: parent
                                anchors.margins: 1
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: artMask
                                }

                                Image {
                                    id: artImage
                                    anchors.fill: parent
                                    source: mPlayer ? (mPlayer.trackArtUrl || "") : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize: Qt.size(128, 128)
                                }
                            }

                            ShadowText {
                                anchors.centerIn: parent
                                text: getIconForPlayer(mPlayer ? mPlayer.identity : "")
                                font.pixelSize: 24
                                color: Services.Colors.primary
                                visible: artImage.status !== Image.Ready
                            }
                        }

                    ColumnLayout {
                        spacing: Services.Colors.spacingSmall; Layout.fillWidth: true
                        
                        Components.MarqueeText {
                            text: mPlayer ? (mPlayer.trackTitle || "Nothing playing") : "Nothing playing"
                            fontPixelSize: 12; fontWeight: Font.DemiBold; color: Services.Colors.mainText
                            maxWidth: 250; Layout.fillWidth: true
                            Layout.preferredHeight: 18
                        }

                        Components.MarqueeText {
                            text: mPlayer ? (mPlayer.trackArtist || "") : ""
                            fontPixelSize: 10; fontWeight: Font.DemiBold; color: Services.Colors.dim
                            maxWidth: 250; Layout.fillWidth: true
                            Layout.preferredHeight: 14
                            opacity: text.length > 0 ? 1 : 0
                        }

                    }
                }

                // ── Progress bar ─────────────────────────────────────
                Item {
                    id: pSliderCont
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24 
                    clip: true
                    
                    opacity: (mPlayer && mPlayer.length > 0) ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    StyledSlider {
                        id: pSlider
                        anchors.fill: parent
                        from: 0; to: (mPlayer && mPlayer.length > 0) ? mPlayer.length : 1
                        value: isSelectedPlayer ? root.interpolatedPosition : (mPlayer ? mPlayer.position : 0)
                        enabled: mPlayer && mPlayer.canSeek
                        
                        readonly property bool isSelectedPlayer: Services.Music.player === mPlayer

                        onMoved: {
                            if (mPlayer) {
                                mPlayer.position = pSlider.value
                                root.lastManualChange = Date.now()
                                root.interpolatedPosition = pSlider.value
                            }
                        }

                        onPressedChanged: {
                            if (!pressed) {
                                root.syncAnchor(true);
                            }
                        }
                    }
                }

                // ── Playback controls ────────────────────────────────
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: Services.Colors.spacingXLarge
                    
                    Components.BarButton {
                        buttonWidth: 28; buttonHeight: 28; bgRadius: 4
                        text: "󰒮"; fontSize: 15
                        textColor: hovered ? Services.Colors.mainText : Services.Colors.dim
                        onClicked: if (mPlayer) mPlayer.previous()
                    }

                    Components.BarButton {
                        buttonWidth: 32; buttonHeight: 32; bgRadius: 16
                        active: mPlayer && mPlayer.playbackState === MprisPlaybackState.Playing
                        text: active ? "󰏤" : "󰐊"; fontSize: 17
                        textColor: active ? Services.Colors.bg : Services.Colors.primary
                        bgColor: active ? Services.Colors.primary : Services.Colors.bg
                        onClicked: if (mPlayer) mPlayer.togglePlaying()

                    }

                    Components.BarButton {
                        buttonWidth: 28; buttonHeight: 28; bgRadius: 4
                        text: "󰒭"; fontSize: 15
                        textColor: hovered ? Services.Colors.mainText : Services.Colors.dim
                        onClicked: if (mPlayer) mPlayer.next()
                    }
                }

                // ── Volume ──────────────────────────────────────────
                RowLayout {
                    spacing: Services.Colors.spacingNormal; Layout.fillWidth: true; visible: mPlayer && mPlayer.volumeSupported
                    ShadowText { text: "󰕾"; font.pixelSize: 15; color: Services.Colors.primary }
                    StyledSlider {
                        id: vSlider
                        Layout.fillWidth: true; from: 0; to: 1; stepSize: 0.01
                        value: mPlayer ? mPlayer.volume : 0
                        onMoved: if (mPlayer) mPlayer.volume = vSlider.value
                    }
                }
            }
        }
    }

    function getIconForPlayer(identity) {
        if (!identity) return "󰝚";
        let id = identity.toLowerCase();
        if (id.includes("spotify")) return "";
        if (id.includes("firefox") || id.includes("chrome") || id.includes("browser") || id.includes("zen") || id.includes("floorp") || id.includes("chromium")) return "󰈹";
        if (id.includes("vlc")) return "󰕼";
        if (id.includes("mpv")) return "";
        if (id.includes("amberol")) return "󰎈";
        if (id.includes("lollypop")) return "󰎈";
        if (id.includes("strawberry")) return "󰎈";
        if (id.includes("rhythmbox")) return "󰎈";
        return "󰝚";
    }
}
