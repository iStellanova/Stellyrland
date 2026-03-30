pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── Internal state ────────────────────────────────────────
    property var colors: ({})

    function resolve(keys, fallback) {
        for (let i = 0; i < keys.length; i++) {
            let k = keys[i]
            if (colors[k] !== undefined) return colors[k]
            if (ConfigService.hardcodedColors[k] !== undefined) return ConfigService.hardcodedColors[k]
        }
        return fallback
    }

    function alpha(baseColor, a) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, a)
    }

    // ── Exposed color properties ──────────────────────────────
    readonly property color primary:          resolve(["primary"], "#b1c5ff")
    readonly property color primaryContainer: resolve(["primaryContainer"], "#2f4578")
    readonly property color secondary:        resolve(["secondary"], "#c0c6dc")
    readonly property color background:       resolve(["background"], "#121318")
    readonly property color surface:          resolve(["surface"], "#121318")
    readonly property color mainText:         resolve(["onSurface", "onBackground"], "#ffffff")
    readonly property color onSurface:        resolve(["onSurface"], mainText)
    readonly property color onBackground:     resolve(["onBackground"], mainText)
    readonly property color onPrimary:        resolve(["onPrimary"], "#162e60")
    readonly property color success:          resolve(["success", "tertiaryContainer"], "#50fa7b")
    readonly property color warning:          resolve(["warning"], "#f1fa8c")
    readonly property color error:            resolve(["error", "errorContainer"], "#ff5555")

    // ── Typography ────────────────────────────────────────────
    readonly property string fontFamily: ConfigService.shellFont
    readonly property int fontSize: 14
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeLarge: 18

    // ── Animation ──────────────────────────────────────────
    readonly property int animFast: ConfigService.animFast
    readonly property int animNormal: ConfigService.animNormal
    readonly property int animSlow: ConfigService.animSlow
    readonly property int animExtraSlow: ConfigService.animExtraSlow
    readonly property int animLarge: ConfigService.animLarge
    readonly property int animExpressiveSpatial: ConfigService.animExpressiveSpatial

    // ── Animation Curves (BezierSpline) ─────────────────────
    readonly property list<real> curveEmphasized: [0.05, 0, 2/15, 0.06, 1/6, 0.4, 5/24, 0.82, 0.25, 1, 1, 1]
    readonly property list<real> curveEmphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property list<real> curveEmphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property list<real> curveFastDecel: [0.1, 1, 0, 1, 1, 1]
    readonly property list<real> curveStandard: [0.2, 0, 0, 1, 1, 1]
    readonly property list<real> curveExpressiveSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property list<real> curveExpressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]

    // ── Layout ──────────────────────────────────────────────
    readonly property int spacingSmall: 4
    readonly property int spacingNormal: 8
    readonly property int spacingLarge: 12
    readonly property int spacingXLarge: 16
    
    readonly property int radiusSmall: 8
    readonly property int radiusNormal: 12
    readonly property int radiusLarge: 20

    readonly property int popupMargin: 8
    readonly property int popupHideOffset: -10
    readonly property int autoCloseInterval: 1500

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
        if (ConfigService.useHardcodedColors) {
            root.colors = ConfigService.hardcodedColors
            return
        }

        try {
            let raw = colorFile.text()
            if (raw && raw.length > 0) {
                let parsed = JSON.parse(raw)
                root.colors = parsed
            }
        } catch (e) {
            console.warn("Failed to parse colors.json: " + e)
        }
    }

    Component.onCompleted: root.parseColors()
}
