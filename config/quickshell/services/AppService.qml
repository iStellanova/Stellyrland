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
    
    onSearchQueryChanged: filterApps()

    function filterApps() {
        if (searchQuery.trim() === "") {
            // Alphabetical View: Sort by Name
            let apps = [...allApps];
            apps.sort((a, b) => a.name.localeCompare(b.name));
            filteredApps = apps;
            return;
        }

        let query = searchQuery.toLowerCase().trim();
        
        // Relevance Search View:
        let prefixMatches = [];
        let containsMatches = [];
        
        for (let app of allApps) {
            let name = app.name.toLowerCase();
            if (name.startsWith(query)) {
                prefixMatches.push(app);
            } else if (name.includes(query)) {
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
                root.allApps = newApps;
                root.allAppsChanged();
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
        launchProc.command = ["bash", "-c", exec + " & disown"];
        launchProc.running = true;
    }

    Process {
        id: launchProc
        command: ["true"]
        running: false
    }
}
