pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // --- State ---
    property string iconTheme: ""
    property var iconMap: ({})
    signal indexUpdated()

    // --- Theme Discovery (Dynamic) ---
    FileView {
        id: gtkSettings
        path: Quickshell.env("HOME") + "/.config/gtk-3.0/settings.ini"
        watchChanges: true
        
        onLoadedChanged: if (loaded) root.updateTheme()
        onFileChanged: {
            this.reload()
            debounceTimer.restart()
        }
    }

    Timer {
        id: debounceTimer
        interval: 500
        onTriggered: root.updateTheme()
    }

    function updateTheme() {
        let match = gtkSettings.text().match(/gtk-icon-theme-name\s*=\s*(.+)/)
        if (match) {
            let theme = match[1].trim()
            if (theme !== root.iconTheme) {
                root.iconTheme = theme
                root.reindex()
            }
        }
    }

    // --- Indexing Logic ---
    function reindex() {
        if (!root.iconTheme || indexer.running) return
        indexer.running = true
    }

    Process {
        id: indexer
        
        // We do a robust, targeted search for app icons in the selected theme and its base.
        // Using a shell loop ensures we handle missing directories gracefully.
        command: [
            "bash", "-c", 
            "for d in " + 
            "~/.local/share/icons/" + root.iconTheme + "/apps " +
            "/usr/share/icons/" + root.iconTheme + "/apps " +
            "~/.local/share/icons/" + root.iconTheme.replace("-Dark","").replace("-Light","") + "/apps " +
            "/usr/share/icons/" + root.iconTheme.replace("-Dark","").replace("-Light","") + "/apps " +
            "~/.local/share/icons/Colloid/apps " +
            "/usr/share/icons/Colloid/apps; " +
            "do [ -d \"$d\" ] && find -L \"$d\" \\( -name '*.svg' -o -name '*.png' \\); done | sort -u"
        ]
        
        property var newMap: ({})

        stdout: SplitParser {
            onRead: data => {
                let path = data.trim()
                if (!path) return
                
                let parts = path.split("/")
                let filename = parts[parts.length - 1]
                let name = filename.substring(0, filename.lastIndexOf("."))
                let isSymbolic = name.endsWith("-symbolic")
                let baseName = isSymbolic ? name.replace("-symbolic", "") : name
                
                let existing = indexer.newMap[baseName]
                
                // Prioritization logic:
                // 1. Prefer colourful icons over symbolic ones for the same base name.
                // 2. Prefer SVGs over PNGs.
                // 3. Prefer the actual iconTheme over fallbacks.
                
                let score = 0
                if (!isSymbolic) score += 100
                if (path.endsWith(".svg")) score += 50
                if (path.includes("/" + root.iconTheme + "/")) score += 200
                
                if (!existing || score > existing.score) {
                    indexer.newMap[baseName] = { path: "file://" + path, score: score }
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                let finalMap = {}
                for (let key in indexer.newMap) {
                    finalMap[key] = indexer.newMap[key].path
                }
                root.iconMap = finalMap
                indexer.newMap = {}
                root.indexUpdated()
                console.log("IconStore: Finalized index with " + Object.keys(root.iconMap).length + " icons for " + root.iconTheme)
            }
        }
    }

    // --- Public API ---
    function getIconPath(name) {
        if (!name) return ""
        
        // Absolute paths
        if (name.startsWith("/")) return "file://" + name
        
        // Handle overrides first
        let resolvedName = root.getOverride(name)
        
        // Check our theme index
        let themedPath = root.iconMap[resolvedName]
        if (themedPath) return themedPath
        
        // Special case for Roblox/Sober if not indexed
        if (resolvedName === "org.vinegarhq.Sober") {
             themedPath = root.iconMap["sober"] || root.iconMap["roblox"]
             if (themedPath) return themedPath
        }
        
        // Fallback to system provider (will eventually trigger Box fallback if system also fails)
        return "image://icon/" + resolvedName
    }

    function getOverride(name) {
        let lower = name.toLowerCase()
        if (lower === "zen") return "zen-browser"
        if (lower === "spotify") return "spotify-client"
        if (lower.includes("firefox")) return "firefox"
        if (lower.includes("librewolf")) return "librewolf"
        if (lower === "discord") return "discord"
        if (lower === "sober" || lower === "roblox") return "org.vinegarhq.Sober"
        return name
    }

    Component.onCompleted: root.updateTheme()
}
