pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var allApps: []
    property var filteredApps: []
    property string searchQuery: ""
    property bool isCategorized: searchQuery.trim() === ""

    property var recentAppExecs: []
    property var recentApps: []

    FileView {
        id: recentAppsFile
        path: Quickshell.env("HOME") + "/.cache/quickshell_recent_apps.json"
        onLoadedChanged: {
            if (loaded) {
                try {
                    let raw = text()
                    if (raw) {
                        root.recentAppExecs = JSON.parse(raw)
                        root.updateRecentApps()
                    }
                } catch(e) {}
            }
        }
    }

    function updateRecentApps() {
        if (!root.allApps || root.allApps.length === 0) return;
        let apps = []
        for (let exec of root.recentAppExecs) {
            let app = root.allApps.find(a => a.exec === exec)
            if (app) apps.push(app)
        }
        root.recentApps = apps
    }
    
    onAllAppsChanged: updateRecentApps()


    
    onSearchQueryChanged: filterApps()

    function filterApps() {
        if (searchQuery.trim() === "") {
            filteredApps = allApps;
            return;
        }

        let query = searchQuery.toLowerCase().trim();
        
        // Relevance Search View:
        let prefixMatches = [];
        let containsMatches = [];
        
        for (let app of allApps) {
            let name = app.name.toLowerCase();
            let exec = app.exec.toLowerCase();
            if (name.startsWith(query)) {
                prefixMatches.push(app);
            } else if (name.includes(query) || exec.includes(query)) {
                containsMatches.push(app);
            }
        }
        
        prefixMatches.sort((a, b) => a.name.localeCompare(b.name));
        containsMatches.sort((a, b) => a.name.localeCompare(b.name));
        
        filteredApps = [...prefixMatches, ...containsMatches];
    }

    property var appBuffer: []
    
    Timer {
        id: batchTimer
        interval: 100
        repeat: false
        onTriggered: {
            let newApps = [...root.allApps];
            let changed = false;
            
            for (let app of root.appBuffer) {
                if (!newApps.some(a => a.name === app.name)) {
                    newApps.push(app);
                    changed = true;
                }
            }
            
            if (changed) {
                newApps.sort((a, b) => a.name.localeCompare(b.name));
                root.allApps = newApps;
                root.filterApps();
            }
            root.appBuffer = [];
        }
    }

    function refresh() {
        appProc.running = true;
    }

    Process {
        id: appProc
        command: ["bash", Quickshell.shellDir + "/scripts/list_apps.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    let app = JSON.parse(data);
                    root.appBuffer.push(app);
                    batchTimer.restart();
                } catch (e) {
                    console.error("Failed to parse app JSON:", data);
                }
            }
        }
    }

    function launch(exec) {
        if (!exec) return;

        let execs = [...root.recentAppExecs]
        let idx = execs.indexOf(exec)
        if (idx !== -1) execs.splice(idx, 1)
        execs.unshift(exec)
        if (execs.length > 10) execs = execs.slice(0, 10)
        
        root.recentAppExecs = execs
        root.updateRecentApps()
        
        let content = JSON.stringify(execs)
        recentAppsFile.setText(content)

        // Prepend hyprctl for cleaner detaching on Hyprland
        let cmd = ["hyprctl", "dispatch", "exec", exec];
        let proc = oneshotFactory.createObject(root, { command: cmd });
        proc.running = true;
    }

    Component {
        id: oneshotFactory
        Process {
            onRunningChanged: if (!running) this.destroy()
        }
    }

}
