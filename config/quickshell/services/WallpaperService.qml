pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/wallpapers"
    property var wallpapers: []

    function setWallpaper(path) {
        let transitions = ["left", "right", "top", "bottom", "wipe", "wave", "grow", "center", "outer"]
        let type = transitions[Math.floor(Math.random() * transitions.length)]
        let posX = Math.random().toFixed(2)
        let posY = Math.random().toFixed(2)

        let cmd = "swww img '" + path + "' --transition-type " + type + " --transition-pos " + posX + "," + posY + " --transition-step 255 --transition-fps 60; " +
                  "matugen image '" + path + "' --source-color-index 0; " +
                  "sleep 1; " +
                  "pkill -SIGUSR2 cava; " +
                  "pkill -SIGUSR1 kitty"
        setThemeProc.command = ["bash", "-c", cmd]
        setThemeProc.running = true
    }

    Process {
        id: setThemeProc
        command: ["true"]
        running: false
    }

    Process {
        id: listProc
        command: ["ls", root.wallpaperDir]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n")
                let filtered = []
                for (let line of lines) {
                    let lowered = line.toLowerCase()
                    if (lowered.endsWith(".jpg") || lowered.endsWith(".jpeg") || lowered.endsWith(".png") || lowered.endsWith(".webp")) {
                        filtered.push("file://" + root.wallpaperDir + "/" + line)
                    }
                }
                root.wallpapers = filtered
            }
        }
    }

    // Refresh every now and then or on demand if needed
    function refresh() {
        listProc.running = true
    }

    Component.onCompleted: refresh()
}
