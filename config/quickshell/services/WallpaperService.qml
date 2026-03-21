pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string wallpaperDir: ConfigService.wallpaperDir
    property var wallpapers: []  // Array of { path: "file://...", isVideo: bool }
    property string currentWallpaper: ""  // Track current wallpaper for transitions
    property bool currentIsVideo: false

    readonly property var videoExtensions: ["mp4", "mkv", "webm", "mov"]
    readonly property var imageExtensions: ["jpg", "jpeg", "png", "webp"]

    signal wallpaperChanged(string path, bool isVideo, string framePath)

    function isVideoFile(filename) {
        let ext = filename.split('.').pop().toLowerCase()
        return videoExtensions.indexOf(ext) >= 0
    }

    function isWallpaperFile(filename) {
        let ext = filename.split('.').pop().toLowerCase()
        return imageExtensions.indexOf(ext) >= 0 || videoExtensions.indexOf(ext) >= 0
    }

    function setWallpaper(path) {
        let ext = path.split('.').pop().toLowerCase()
        let isVideo = videoExtensions.indexOf(ext) >= 0

        currentWallpaper = path
        currentIsVideo = isVideo
        
        let name = path.split('/').pop()
        let home = Quickshell.env("HOME")
        let framePath = "file://" + home + "/.cache/quickshell/wallpapers/" + name + ".png"

        // Trigger extraction and theme generation IMMEDIATELY
        root.finalizeTheming(path)

        root.wallpaperChanged("file://" + path, isVideo, isVideo ? framePath : "")
    }

    function finalizeTheming(path) {
        let scriptPath = Quickshell.shellDir + "/scripts/switchwall.sh"
        setThemeProc.command = ["bash", scriptPath, path]
        setThemeProc.running = true
    }

    Process {
        id: setThemeProc
        command: []
        running: false
    }

    Process {
        id: listProc
        command: ["ls", root.wallpaperDir]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n")
                let entries = []
                let home = Quickshell.env("HOME")
                for (let line of lines) {
                    if (root.isWallpaperFile(line)) {
                        let isVideo = root.isVideoFile(line)
                        entries.push({
                            path: "file://" + root.wallpaperDir + "/" + line,
                            isVideo: isVideo,
                            framePath: isVideo ? ("file://" + home + "/.cache/quickshell/wallpapers/" + line + ".png") : ""
                        })
                    }
                }
                root.wallpapers = entries
                
                if (root.currentWallpaper === "" && entries.length > 0) {
                    let startupMode = ConfigService.wallpaperStartup
                    let wallToSet = ""
                    if (startupMode === "random") {
                        let randomIndex = Math.floor(Math.random() * entries.length);
                        wallToSet = entries[randomIndex].path.replace("file://", "")
                    } else {
                        wallToSet = entries[0].path.replace("file://", "")
                    }
                    root.setWallpaper(wallToSet)
                }
            }
        }
    }

    function refresh() {
        listProc.running = true
        batchGenProc.command = ["bash", Quickshell.shellDir + "/scripts/switchwall.sh", "--all", root.wallpaperDir]
        batchGenProc.running = true
    }

    Process {
        id: batchGenProc
        command: []
        running: false
    }

    Component.onCompleted: refresh()

    Timer {
        id: rotationTimer
        interval: ConfigService.wallpaperRotateMinutes * 60000
        running: ConfigService.wallpaperRotateMinutes > 0 && root.wallpapers.length > 0
        repeat: true
        onTriggered: {
            if (root.wallpapers.length > 1) {
                let randomIndex = Math.floor(Math.random() * root.wallpapers.length);
                let randomWallpaper = root.wallpapers[randomIndex].path.replace("file://", "")
                if (randomWallpaper === root.currentWallpaper) {
                    randomIndex = (randomIndex + 1) % root.wallpapers.length
                    randomWallpaper = root.wallpapers[randomIndex].path.replace("file://", "")
                }
                root.setWallpaper(randomWallpaper)
            }
        }
    }
}
