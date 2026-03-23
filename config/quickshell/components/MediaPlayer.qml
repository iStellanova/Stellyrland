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
                    color: isSelected ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12) 
                                      : (tabMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                    border.width: 1
                    border.color: isSelected ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) 
                                             : (tabMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent")

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
            Layout.preferredHeight: currentItem ? currentItem.implicitHeight : 160
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

                    Rectangle {
                        id: artCont
                        implicitWidth: 48; implicitHeight: 48; radius: Services.Colors.radiusNormal
                        color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.12)
                        border.width: 1; border.color: Services.Colors.border
                        
                        Item {
                            anchors.fill: parent; anchors.margins: 1; layer.enabled: true
                            layer.effect: OpacityMask { maskSource: Rectangle { width: artCont.width; height: artCont.height; radius: artCont.radius } }
                            Image {
                                anchors.fill: parent
                                source: mPlayer ? (mPlayer.trackArtUrl || "") : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true; sourceSize: Qt.size(128, 128)
                            }
                        }
                        ShadowText {
                            anchors.centerIn: parent
                            text: getIconForPlayer(mPlayer ? mPlayer.identity : "")
                            font.pixelSize: 24; color: Services.Colors.primary
                            visible: !mPlayer || !mPlayer.trackArtUrl
                        }
                    }

                    ColumnLayout {
                        spacing: Services.Colors.spacingSmall; Layout.fillWidth: true
                        ShadowText {
                            text: mPlayer ? (mPlayer.trackTitle || "Nothing playing") : "Nothing playing"
                            font.pixelSize: 12; font.weight: Font.DemiBold; color: Services.Colors.mainText
                            elide: Text.ElideRight; Layout.fillWidth: true; Layout.maximumWidth: 160
                        }
                        ShadowText {
                            text: mPlayer ? (mPlayer.trackArtist || "") : ""
                            font.pixelSize: 10; font.weight: Font.DemiBold; color: Services.Colors.dim
                            elide: Text.ElideRight; Layout.fillWidth: true; Layout.maximumWidth: 160
                            visible: text.length > 0
                        }
                    }
                }

                // ── Progress bar ─────────────────────────────────────
                StyledSlider {
                    id: pSlider
                    Layout.fillWidth: true
                    visible: mPlayer && mPlayer.length > 0
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

                // ── Playback controls ────────────────────────────────
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: Services.Colors.spacingXLarge
                    
                    Rectangle {
                        implicitWidth: 28; implicitHeight: 28; radius: 4
                        color: prevM.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                        ShadowText { anchors.centerIn: parent; text: "󰒮"; font.pixelSize: 15; color: prevM.containsMouse ? Services.Colors.mainText : Services.Colors.dim }
                        MouseArea { id: prevM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: if (mPlayer) mPlayer.previous() }
                    }
                    Rectangle {
                        implicitWidth: 32; implicitHeight: 32; radius: 16
                        color: mPlayer && mPlayer.playbackState === MprisPlaybackState.Playing ? Services.Colors.primary : Services.Colors.bg
                        ShadowText { anchors.centerIn: parent; text: mPlayer && mPlayer.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"; font.pixelSize: 17; color: mPlayer && mPlayer.playbackState === MprisPlaybackState.Playing ? Services.Colors.bg : Services.Colors.primary }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (mPlayer) mPlayer.togglePlaying() }
                    }
                    Rectangle {
                        implicitWidth: 28; implicitHeight: 28; radius: 4
                        color: nextM.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                        ShadowText { anchors.centerIn: parent; text: "󰒭"; font.pixelSize: 15; color: nextM.containsMouse ? Services.Colors.mainText : Services.Colors.dim }
                        MouseArea { id: nextM; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: if (mPlayer) mPlayer.next() }
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
                    Item { implicitWidth: 20 }
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
