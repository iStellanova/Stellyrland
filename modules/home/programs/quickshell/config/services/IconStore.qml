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

    function getIndexerCommand() {
        let home = Quickshell.env("HOME")
        let user = Quickshell.env("USER")
        let baseTheme = root.iconTheme.replace("-Dark","").replace("-Light","")
        let dirs = [
            home + "/.local/share/icons/" + root.iconTheme,
            "/usr/share/icons/" + root.iconTheme,
            home + "/.nix-profile/share/icons/" + root.iconTheme,
            "/etc/profiles/per-user/" + user + "/share/icons/" + root.iconTheme,
            "/run/current-system/sw/share/icons/" + root.iconTheme,
            home + "/.local/share/icons/" + baseTheme,
            "/usr/share/icons/" + baseTheme,
            home + "/.nix-profile/share/icons/" + baseTheme,
            "/etc/profiles/per-user/" + user + "/share/icons/" + baseTheme,
            "/run/current-system/sw/share/icons/" + baseTheme,
            home + "/.local/share/icons/hicolor",
            "/usr/share/icons/hicolor",
            home + "/.nix-profile/share/icons/hicolor",
            "/etc/profiles/per-user/" + user + "/share/icons/hicolor",
            "/run/current-system/sw/share/icons/hicolor",
            "/usr/share/pixmaps",
            home + "/.local/share/icons/Colloid",
            "/usr/share/icons/Colloid"
        ]
        
        let uniqueDirs = dirs.filter((v, i, a) => a.indexOf(v) === i)
        let dirList = uniqueDirs.join(" ")
        
        return "for d in " + dirList + "; do [ -d \"$d\" ] && find -L \"$d\" -maxdepth 4 \\( -name '*.svg' -o -name '*.png' \\); done | sort -u"
    }

    Process {
        id: indexer
        command: ["bash", "-c", root.getIndexerCommand()]
        
        // We do a robust, targeted search for app icons in the selected theme and its base.
        // Using a shell loop ensures we handle missing directories gracefully.
        // command: [
        //     "bash", "-c", 
        //     "for d in " + 
        //     "~/.local/share/icons/" + root.iconTheme + " " +
        //     "/usr/share/icons/" + root.iconTheme + " " +
        //     "~/.local/share/icons/" + root.iconTheme.replace("-Dark","").replace("-Light","") + " " +
        //     "/usr/share/icons/" + root.iconTheme.replace("-Dark","").replace("-Light","") + " " +
        //     "~/.local/share/icons/hicolor " +
        //     "/usr/share/icons/hicolor " +
        //     "/usr/share/pixmaps " +
        //     "~/.local/share/icons/Colloid " +
        //     "/usr/share/icons/Colloid; " +
        //     "do [ -d \"$d\" ] && find -L \"$d\" -maxdepth 4 \\( -name '*.svg' -o -name '*.png' \\); done | sort -u"
        // ]
        
        property var newMap: ({})

        stdout: SplitParser {
            onRead: data => {
                let path = data.trim()
                if (!path) return
                
                let lastSlash = path.lastIndexOf("/")
                let filename = path.substring(lastSlash + 1)
                let name = filename.substring(0, filename.lastIndexOf("."))
                let isSymbolic = name.endsWith("-symbolic")
                let baseName = (isSymbolic ? name.substring(0, name.length - 9) : name).toLowerCase()
                
                let existing = indexer.newMap[baseName]
                
                // Prioritization logic:
                // 1. Prefer colourful icons over symbolic ones for the same base name.
                // 2. Prefer SVGs over PNGs.
                // 3. Prefer the actual iconTheme over fallbacks.
                // 4. Boost status/panel icons as they are rare and often what's missing.
                
                let score = 0
                if (!isSymbolic) score += 100
                if (path.endsWith(".svg")) score += 50
                if (path.includes("/" + root.iconTheme + "/")) score += 200
                if (path.includes("/status/") || path.includes("/panel/") || path.includes("/devices/")) score += 300
                if (path.includes("/apps/")) score += 50
                
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
        
        let target = name.toString()
        
        // Handle image://icon/ protocol by extracting the icon name
        if (target.startsWith("image://icon/")) {
            target = target.substring(13)
        } else if (target.startsWith("/") || target.includes("://")) {
            // Already a valid full URL or absolute path, return it immediately
            return target.startsWith("/") ? "file://" + target : target
        }
        
        // Handle overrides
        let resolvedName = root.getOverride(target).toLowerCase()
        
        // Check our theme index
        let themedPath = root.iconMap[resolvedName]
        if (themedPath) return themedPath
        
        // Special case for Roblox/Sober if not indexed
        if (resolvedName === "org.vinegarhq.sober") {
             themedPath = root.iconMap["sober"] || root.iconMap["roblox"]
             if (themedPath) return themedPath
        }
        
        // Fallback to system provider. We return the name so Image { source: icon } works
        // but it will likely still show checkerboard if system also fails.
        return "image://icon/" + resolvedName
    }

    function getOverride(name) {
        let lower = name.toLowerCase()
        if (lower === "zen" || lower === "zenbrowser" || lower === "zen-browser") return "zen"
        if (lower === "zed" || lower === "zeditor" || lower === "dev.zed.zed") return "zed"
        if (lower === "spotify") return "spotify-client"
        if (lower.includes("firefox")) return "firefox"
        if (lower.includes("librewolf")) return "librewolf"
        if (lower === "discord") return "discord"
        if (lower === "sober" || lower === "roblox") return "org.vinegarhq.Sober"
        return name
    }

    Component.onCompleted: root.updateTheme()
}
