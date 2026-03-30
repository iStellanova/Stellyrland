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

    readonly property string home: Quickshell.env("HOME")
    readonly property string shellDir: Quickshell.shellDir
    readonly property var videoExtensions: ["mp4", "mkv", "webm", "mov"]
    readonly property var imageExtensions: ["jpg", "jpeg", "png", "webp"]

    signal wallpaperChanged(string path, bool isVideo, string framePath)

    function getExtension(filename) {
        return filename.split('.').pop().toLowerCase()
    }

    function isVideoFile(filename) {
        return videoExtensions.indexOf(getExtension(filename)) >= 0
    }

    function isWallpaperFile(filename) {
        let ext = getExtension(filename)
        return imageExtensions.indexOf(ext) >= 0 || videoExtensions.indexOf(ext) >= 0
    }

    function setWallpaper(path) {
        let isVideo = isVideoFile(path)

        currentWallpaper = path
        currentIsVideo = isVideo
        
        let name = path.split('/').pop()
        let framePath = "file://" + root.home + "/.cache/quickshell/wallpapers/" + name + ".png"

        // Trigger extraction and theme generation IMMEDIATELY
        root.finalizeTheming(path)

        root.wallpaperChanged("file://" + path, isVideo, isVideo ? framePath : "")
    }

    function finalizeTheming(path) {
        setThemeProc.run(["bash", root.shellDir + "/scripts/switchwall.sh", path])
    }

    function runProcess(proc, cmd) {
        if (proc.running) {
            proc.running = false
        }
        proc.command = cmd
        proc.running = true
    }

    Process {
        id: setThemeProc
        command: []
        running: false
        function run(args) { root.runProcess(setThemeProc, args) }
    }

    Process {
        id: listProc
        command: ["find", "-L", root.wallpaperDir, "-maxdepth", "1", "-type", "f", "-printf", "%f\n"]
        running: false
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
        batchGenProc.run(["bash", root.shellDir + "/scripts/switchwall.sh", "--all", root.wallpaperDir])
    }

    Process {
        id: batchGenProc
        command: []
        running: false
        function run(args) { root.runProcess(batchGenProc, args) }
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
