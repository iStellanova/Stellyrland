pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Internal state ────────────────────────────────────────
    property var colors: ({})

    // ── Exposed color properties ──────────────────────────────
    readonly property color primary:          colors.primary          ?? "#b1c5ff"
    readonly property color primaryContainer: colors.primaryContainer ?? "#2f4578"
    readonly property color secondary:        colors.secondary        ?? "#c0c6dc"
    readonly property color background:       colors.background       ?? "#121318"
    readonly property color surface:          colors.surface          ?? "#121318"
    readonly property color mainText:         colors.onSurface        ?? colors.onBackground ?? "#ffffff"
    readonly property color onSurface:        colors.onSurface        ?? mainText
    readonly property color onBackground:     colors.onBackground     ?? mainText
    readonly property color onPrimary:        colors.onPrimary        ?? "#162e60"
    readonly property color success:          "#50fa7b"
    readonly property color warning:          "#f1fa8c"
    readonly property color error:            "#ff5555"

    // ── Typography ────────────────────────────────────────────
    readonly property string fontFamily: "JetBrains Mono Nerd Font Propo"
    readonly property int fontSize: 14
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeLarge: 18

    // ── Animation & Layout ──────────────────────────────────
    readonly property int animDuration: 300
    readonly property int popupMargin: 8
    readonly property int popupHideOffset: -10
    readonly property int autoCloseInterval: 800

    // ── Derived aliases ───────────────────────────────────────
    readonly property color text:    mainText
    readonly property color subtext: Qt.rgba(mainText.r, mainText.g, mainText.b, 0.70)
    readonly property color dim:     Qt.rgba(mainText.r, mainText.g, mainText.b, 0.45)
    readonly property color border:  Qt.rgba(secondary.r, secondary.g, secondary.b, 0.20)
    readonly property color bg:      Qt.rgba(background.r, background.g, background.b, 0.50)
    readonly property color red:     "#f7768e"

    // ── File watcher ──────────────────────────────────────────
    FileView {
        id: colorFile
        path: Quickshell.shellDir + "/colors.json"
        watchChanges: true

        onFileChanged: {
            console.log("Colors.json changed, reloading...")
            this.reload()
            reloadTimer.restart()
        }

        onLoadedChanged: {
            if (loaded) root.parseColors()
        }
    }

    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: root.parseColors()
    }

    function parseColors() {
        try {
            let raw = colorFile.text()
            if (raw && raw.length > 0) {
                let parsed = JSON.parse(raw)
                root.colors = parsed
                console.log("Successfully parsed " + Object.keys(parsed).length + " colors from JSON")
            }
        } catch (e) {
            console.warn("Failed to parse colors.json: " + e)
        }
    }

    Component.onCompleted: root.parseColors()
}
