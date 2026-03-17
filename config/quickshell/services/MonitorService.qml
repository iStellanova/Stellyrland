pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property string targetName: "DP-2"
    property var primaryScreen: {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === targetName) {
                return Quickshell.screens[i]
            }
        }
        return Quickshell.screens[0] // Fallback
    }
}
