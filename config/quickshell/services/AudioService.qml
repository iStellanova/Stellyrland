pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import "."

Singleton {
    id: root

    // ── Properties ──────────────────────────────────────────
    property var micApps: {
        let nodes = Pipewire.nodes.values
        let apps = []
        for (let i = 0; i < nodes.length; i++) {
            let node = nodes[i]
            if (node.properties["media.class"] === "Stream/Input/Audio" && 
                !(node.properties["node.name"] || "").includes("cava")) {
                let name = node.properties["application.name"] || node.properties["node.name"] || "Unknown"
                if (!apps.includes(name)) apps.push(name)
            }
        }
        return apps
    }
    property bool micBusy: micApps.length > 0
    property alias appVolumesModel: appVolumesModel
    ListModel { id: appVolumesModel }
    property var _appVolBusyMap: ({}) 
    property var _pendingAppVolUpdates: ({})

    // Volume and Microphone linked directly to Pipewire
    property alias volume: volumeWrapper.volume
    property alias muted: volumeWrapper.muted
    property alias micMuted: micWrapper.muted
    property bool micOn: !micMuted

    // ── Internal ──────────────────────────────────────────────
    function runCommand(cmd) {
        let proc = oneshotFactory.createObject(root, { command: cmd });
        proc.running = true;
    }

    Component {
        id: oneshotFactory
        Process {
            onRunningChanged: if (!running) this.destroy()
        }
    }

    // ── Simple Volume Wrappers ───────────────────────────────
    QtObject {
        id: volumeWrapper
        property int volume: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
        property bool muted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio.muted : false
    }

    QtObject {
        id: micWrapper
        property bool muted: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio ? Pipewire.defaultAudioSource.audio.muted : true
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource, ...Pipewire.nodes.values]
    }

    // ── App Volume Monitoring ─────────────────────────────
    Process {
        id: appVolumeProc
        command: ["bash", Quickshell.shellDir + "/scripts/get_app_volumes.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let newData = JSON.parse(this.text.trim())
                    let now = Date.now()
                    let pwNodes = Pipewire.nodes
                    let seenIds = {}
                    
                    for (let newItem of newData) {
                        seenIds[newItem.id] = true
                        let nativeNode = root.getAppNode(newItem.id)
                        
                        if (!nativeNode || !nativeNode.audio) {
                            nativeNode = null
                            let targetName = newItem.name.toLowerCase().trim()
                            let nodes = pwNodes.values
                            for (let pwNode of nodes) {
                                if (!pwNode.audio) continue
                                let pwName = (pwNode.properties["node.name"] || pwNode.properties["application.name"] || "").toLowerCase().trim()
                                if (pwName === "") continue
                                if (pwName === targetName || (targetName !== "unknown" && (pwName.includes(targetName) || targetName.includes(pwName)))) {
                                    nativeNode = pwNode
                                    break
                                }
                            }
                        }
                        
                        let busySince = root._appVolBusyMap[newItem.id] || 0
                        let isBusy = (now - busySince < 3000)
                        
                        let idx = -1
                        for (let i = 0; i < appVolumesModel.count; i++) {
                            if (appVolumesModel.get(i).id === newItem.id) {
                                idx = i; break
                            }
                        }
                        
                        if (idx !== -1) {
                            let props = { name: newItem.name, icon: newItem.icon, pwId: nativeNode ? nativeNode.id : -1 }
                            if (!isBusy) {
                                props.volume = newItem.volume
                                props.muted = newItem.muted
                            }
                            appVolumesModel.set(idx, props)
                        } else {
                            newItem.pwId = nativeNode ? nativeNode.id : -1
                            appVolumesModel.append(newItem)
                        }
                    }
                    
                    for (let i = appVolumesModel.count - 1; i >= 0; i--) {
                        if (!seenIds[appVolumesModel.get(i).id]) {
                            appVolumesModel.remove(i)
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse app volumes JSON:", e)
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: appVolumeProc.running = true
    }

    // ── Actions ───────────────────────────────────────────
    function setVolume(v) {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.volume = v / 100
        }
    }

    function toggleMute() {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
        }
    }

    function toggleMic() {
        if (Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.audio) {
            Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted
        }
    }

    function getAppNode(id) {
        if (id === -1) return null
        let nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
            if (nodes[i].id === id) return nodes[i]
        }
        return null
    }

    function setAppVolume(id, v) {
        let map = root._appVolBusyMap
        map[id] = Date.now()
        root._appVolBusyMap = map
        
        let pwId = -1
        for (let i = 0; i < appVolumesModel.count; i++) {
            let item = appVolumesModel.get(i)
            if (item.id === id) {
                appVolumesModel.setProperty(i, "volume", v)
                pwId = item.pwId
                break
            }
        }
        
        let targetNode = null
        if (pwId !== -1) {
            let nodes = Pipewire.nodes.values
            for (let i = 0; i < nodes.length; i++) {
                if (nodes[i].id === pwId) { targetNode = nodes[i]; break }
            }
        }

        if (targetNode && targetNode.audio) {
            targetNode.audio.volume = v / 100
        } else {
            let updates = root._pendingAppVolUpdates
            updates[id] = v
            root._pendingAppVolUpdates = updates
            appVolUpdateTimer.restart()
        }
    }

    Timer {
        id: appVolUpdateTimer
        interval: 50; running: false; repeat: false
        onTriggered: {
            for (let id in _pendingAppVolUpdates) {
                runCommand(["pactl", "set-sink-input-volume", id.toString(), _pendingAppVolUpdates[id] + "%"])
            }
            root._pendingAppVolUpdates = {}
        }
    }

    function toggleAppMute(id) {
        let pwId = -1
        for (let i = 0; i < appVolumesModel.count; i++) {
            let item = appVolumesModel.get(i)
            if (item.id === id) { pwId = item.pwId; break }
        }
        
        let targetNode = null
        if (pwId !== -1) {
            let nodes = Pipewire.nodes.values
            for (let i = 0; i < nodes.length; i++) {
                if (nodes[i].id === pwId) { targetNode = nodes[i]; break }
            }
        }
        
        if (targetNode && targetNode.audio) {
            targetNode.audio.muted = !targetNode.audio.muted
        } else {
            runCommand(["pactl", "set-sink-input-mute", id.toString(), "toggle"])
        }
        appVolumeProc.running = true
    }
}
