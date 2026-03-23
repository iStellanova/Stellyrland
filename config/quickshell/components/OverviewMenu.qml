import Quickshell
import Quickshell.Io
import Quickshell.Wayland._WlrLayerShell 0.0
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services

PanelWindow {
    id: window

    property bool open: false
    property bool showingAllApps: false
    signal closeRequested()

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-overview"
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true; bottom: true; left: true; right: true
    }
    
    color: Qt.rgba(1, 1, 1, 0.01)
    visible: open

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "transparent"
        z: -1
    }

    ListModel { id: windowsModel }
    property var monitorsData: []
    property var workspacesData: []

    Timer {
        id: syncTimer
        interval: 120
        repeat: true
        running: window.open
        onTriggered: if (!dataProc.running) dataProc.running = true
    }

    Process {
        id: dataProc
        command: ["bash", "-c", "echo \"{\\\"monitors\\\": $(hyprctl monitors -j), \\\"workspaces\\\": $(hyprctl workspaces -j), \\\"clients\\\": $(hyprctl clients -j)}\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (!this.text) return
                try {
                    let data = JSON.parse(this.text.trim())
                    if (data.monitors) window.monitorsData = data.monitors
                    if (data.workspaces) window.workspacesData = data.workspaces
                    if (data.clients) {
                        updateWindowsModel(data.clients.filter(w => w.mapped))
                    }
                } catch (e) {
                    console.error("Failed to parse hyprctl data in OverviewMenu:", e)
                }
            }
        }
    }

    function updateWindowsModel(clients) {
        let currentAddresses = {}
        for (let i = 0; i < clients.length; i++) {
            let c = clients[i]
            let addr = c.address.toString()
            currentAddresses[addr] = true
            
            let found = false
            for (let j = 0; j < windowsModel.count; j++) {
                if (windowsModel.get(j).address === addr) {
                    windowsModel.set(j, {
                        address: addr,
                        rectX: c.at[0] || 0,
                        rectY: c.at[1] || 0,
                        rectW: c.size[0] || 0,
                        rectH: c.size[1] || 0,
                        workspaceId: (c.workspace && c.workspace.id) || 0,
                        title: c.title || "",
                        class: c.class || ""
                    })
                    found = true
                    break
                }
            }
            
            if (!found) {
                windowsModel.append({
                    address: addr,
                    rectX: c.at[0] || 0,
                    rectY: c.at[1] || 0,
                    rectW: c.size[0] || 0,
                    rectH: c.size[1] || 0,
                    workspaceId: (c.workspace && c.workspace.id) || 0,
                    title: c.title || "",
                    class: c.class || ""
                })
            }
        }
        
        for (let i = windowsModel.count - 1; i >= 0; i--) {
            if (!currentAddresses[windowsModel.get(i).address]) {
                windowsModel.remove(i)
            }
        }
    }

    onOpenChanged: {
        if (open) {
            if (!dataProc.running) dataProc.running = true
            searchInput.forceActiveFocus()
        } else {
            windowsModel.clear()
            searchInput.text = ""
            Services.AppService.searchQuery = ""
            showingAllApps = false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Services.ShellData.overviewVisible = false
    }

    Item {
        id: contentContainer
        anchors.fill: parent

        opacity: window.open ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }

        scale: window.open ? 1.0 : 1.1
        Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 40
            anchors.bottomMargin: 40
            spacing: 8 // Reduced from 12

            // Search Bar Area
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                // Search Bar
                Rectangle {
                    id: searchBarContainer
                    Layout.preferredWidth: searchInput.text === "" ? 600 : 676
                    Layout.preferredHeight: 60
                    radius: Services.Colors.radiusLarge
                    color: Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.8)
                    border.width: 1.5
                    border.color: Services.Colors.border
                    
                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 15

                        Text {
                            text: "󰍉"
                            font.pixelSize: 22
                            color: Services.Colors.primary
                        }

                        TextField {
                            id: searchInput
                            Layout.fillWidth: true
                            placeholderText: "Search apps..."
                            placeholderTextColor: Qt.rgba(Services.Colors.mainText.r, Services.Colors.mainText.g, Services.Colors.mainText.b, 0.5)
                            color: Services.Colors.mainText
                            font.family: Services.Colors.fontFamily
                            font.pixelSize: 20
                            background: null

                            onTextChanged: {
                                Services.AppService.searchQuery = text
                                if (text !== "") {
                                    appList.currentIndex = 0
                                    window.showingAllApps = false
                                }
                            }

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Escape) {
                                    if (text !== "") {
                                        text = ""
                                    } else if (window.showingAllApps) {
                                        window.showingAllApps = false
                                    } else {
                                        Services.ShellData.overviewVisible = false
                                    }
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Down) {
                                    if (appList.visible) {
                                        appList.currentIndex = (appList.currentIndex + 1) % appList.count
                                        event.accepted = true
                                    }
                                } else if (event.key === Qt.Key_Up) {
                                    if (appList.visible) {
                                        appList.currentIndex = (appList.currentIndex - 1 + appList.count) % appList.count
                                        event.accepted = true
                                    }
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (appList.visible && appList.currentItem) {
                                        appList.currentItem.launch()
                                        event.accepted = true
                                    }
                                }
                            }
                        }
                    }
                }

                // All Apps Button
                Rectangle {
                    id: allAppsBtn
                    Layout.preferredWidth: searchInput.text === "" ? 60 : 0
                    Layout.preferredHeight: 60
                    radius: Services.Colors.radiusLarge
                    color: window.showingAllApps ? Services.Colors.primary : Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.8)
                    border.width: 1.5
                    border.color: window.showingAllApps ? "transparent" : Services.Colors.border
                    clip: true
                    opacity: searchInput.text === "" ? 1.0 : 0.0

                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰀻"
                        font.pixelSize: 24
                        color: window.showingAllApps ? Services.Colors.bg : Services.Colors.mainText
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.showingAllApps = !window.showingAllApps
                        onEntered: if (!window.showingAllApps) allAppsBtn.border.color = Services.Colors.primary
                        onExited: if (!window.showingAllApps) allAppsBtn.border.color = Services.Colors.border
                    }
                }
            }

            // Middle Area (Recent Apps or Search Results)
            Item {
                id: middleArea
                Layout.fillWidth: true
                Layout.fillHeight: searchInput.text !== "" || window.showingAllApps
                Layout.preferredHeight: (searchInput.text === "" && !window.showingAllApps) ? 360 : -1
                clip: true
                
                Behavior on Layout.preferredHeight { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                // Recent Apps Grid
                RecentAppsGrid {
                    id: recentApps
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 760
                    visible: !window.showingAllApps && Services.AppService.recentApps.length > 0
                    opacity: (searchInput.text === "" && !window.showingAllApps) ? 1.0 : 0.0
                    onAppLaunched: Services.ShellData.overviewVisible = false
                    
                    Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal } }
                }

                // Centered Container for Apps & Categories
                Item {
                    id: appsContainer
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: (window.showingAllApps && searchInput.text === "") ? 900 : 760
                    height: parent.height
                    visible: searchInput.text !== "" || window.showingAllApps
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal } }
                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 40

                        // Category Sidebar
                        ListView {
                            id: categorySidebar
                            Layout.preferredWidth: 40
                            Layout.fillHeight: true
                            visible: window.showingAllApps && searchInput.text === ""
                            model: {
                                if (Services.AppService.allApps.length === 0) return [];
                                let chars = [];
                                let apps = Services.AppService.allApps;
                                for (let i = 0; i < apps.length; i++) {
                                    let c = apps[i].name[0].toUpperCase();
                                    if (chars.indexOf(c) === -1) chars.push(c);
                                }
                                return chars;
                            }
                            spacing: 12
                            interactive: true
                            clip: true
                            
                            property string currentSection: {
                                if (appList.hoveredSection !== "") return appList.hoveredSection;
                                if (appList.count === 0) return "";
                                let idx = appList.indexAt(10, appList.contentY + 32);
                                let item = appList.itemAtIndex(idx === -1 ? 0 : idx);
                                return (item && item.sectionName) ? item.sectionName : "";
                            }

                            HoverHandler { id: sidebarHover }

                            property bool isSidebarScrolling: false

                            onContentYChanged: {
                                isSidebarScrolling = true;
                                sidebarHideTimer.restart();
                            }

                            Timer {
                                id: sidebarHideTimer
                                interval: 1500
                                onTriggered: categorySidebar.isSidebarScrolling = false
                            }

                            ScrollBar.vertical: ScrollBar {
                                id: sidebarScrollBar
                                orientation: Qt.Vertical
                                policy: ScrollBar.AlwaysOn
                                
                                contentItem: Rectangle {
                                    implicitWidth: 4
                                    implicitHeight: 100
                                    radius: 2
                                    color: Services.Colors.primary
                                    opacity: (categorySidebar.isSidebarScrolling || sidebarScrollBar.hovered) ? 0.9 : 0
                                    Behavior on opacity { NumberAnimation { duration: 300 } }
                                }
                                
                                background: null
                            }

                            delegate: Text {
                                text: modelData
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: categorySidebar.currentSection === modelData ? 18 : 14
                                font.weight: categorySidebar.currentSection === modelData ? Font.Bold : Font.Medium
                                color: Services.Colors.primary
                                opacity: categorySidebar.currentSection === modelData ? 1.0 : 0.4
                                
                                Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                                Behavior on opacity { NumberAnimation { duration: 200 } }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let apps = Services.AppService.allApps;
                                        for (let i = 0; i < apps.length; i++) {
                                            if (apps[i].name[0].toUpperCase() === modelData) {
                                                appList.positionViewAtIndex(i, ListView.Beginning);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ListView {
                            id: appList
                            Layout.fillWidth: true
                            Layout.preferredWidth: 760
                            Layout.fillHeight: true
                            
                            property string hoveredSection: ""
                            property bool isAnyItemHovered: false
                            property bool isScrolling: false
                            property int lastMouseX: 0
                            property int lastMouseY: 0

                            onContentYChanged: {
                                isScrolling = true;
                                listHideTimer.restart();
                            }

                            Timer {
                                id: listHideTimer
                                interval: 1500
                                onTriggered: appList.isScrolling = false
                            }

                            Timer {
                                id: globalClearHoverTimer
                                interval: 50
                                onTriggered: if (!appList.isAnyItemHovered) appList.hoveredSection = ""
                            }

                            ScrollBar.vertical: ScrollBar {
                                id: listScrollBar
                                orientation: Qt.Vertical
                                policy: ScrollBar.AlwaysOn
                                
                                contentItem: Rectangle {
                                    implicitWidth: 4
                                    implicitHeight: 200
                                    radius: 2
                                    color: Services.Colors.primary
                                    opacity: (appList.isScrolling || listScrollBar.hovered) ? 0.9 : 0
                                    Behavior on opacity { NumberAnimation { duration: 300 } }
                                }
                                
                                background: null
                            }

                            
                            Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                            Behavior on scale { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                            scale: parent.visible ? 1.0 : 0.95

                            model: searchInput.text !== "" ? Services.AppService.filteredApps : Services.AppService.allApps
                            spacing: 8
                            clip: true
                            currentIndex: 0

                            onModelChanged: currentIndex = 0

                            Connections {
                                target: searchInput
                                function onTextChanged() { appList.currentIndex = 0 }
                            }

                            section.property: (searchInput.text === "" && window.showingAllApps) ? "name" : ""
                            section.criteria: ViewSection.FirstCharacter
                            section.delegate: Component {
                                Item {
                                    width: appList.width
                                    height: 32
                                    visible: searchInput.text === "" && window.showingAllApps
                                    
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: section
                                        font.pixelSize: 12
                                        font.weight: Font.Black
                                        font.family: Services.Colors.fontFamily
                                        color: Services.Colors.primary
                                        opacity: 0.6
                                    }
                                }
                            }

                            highlight: Rectangle {
                                z: 2
                                x: 6
                                y: 6
                                width: appList.width - 12
                                height: 52
                                radius: Services.Colors.radiusSmall
                                color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
                                border.width: 1
                                border.color: Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.4)
                                
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 4
                                    height: parent.height - 16
                                    radius: Services.Colors.radiusSmall
                                    color: Services.Colors.primary
                                }
                            }
                            
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 250

                            delegate: Item {
                                id: delegateItem
                                width: appList.width
                                height: 64
                                
                                property bool isCurrent: ListView.isCurrentItem
                                property string sectionName: modelData.name[0].toUpperCase()

                                function launch() {
                                    launchAnimation.start();
                                }

                                SequentialAnimation {
                                    id: launchAnimation
                                    NumberAnimation { target: contentRect; property: "scale"; to: 0.95; duration: Services.Colors.animFast; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: contentRect; property: "scale"; to: 1.0; duration: Services.Colors.animNormal; easing.type: Easing.OutBack }
                                    ScriptAction { 
                                        script: {
                                            Services.AppService.launch(modelData.exec);
                                            Services.ShellData.overviewVisible = false;
                                        }
                                    }
                                }

                                Rectangle {
                                    id: contentRect
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    radius: Services.Colors.radiusSmall
                                    color: "transparent"
                                    border.width: 0
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 20
                                        spacing: 20

                                        AppIcon {
                                            width: 44; height: 44
                                            radius: Services.Colors.radiusSmall
                                            iconBgColor: Qt.rgba(1, 1, 1, 0.08)
                                            fallbackBgColor: Qt.rgba(1, 1, 1, 0.08)
                                            fallbackBorderWidth: 0
                                            scale: isCurrent ? 1.1 : 1.0
                                            iconName: modelData.icon
                                            fallbackText: modelData.name
                                            imageMargins: 6
                                            
                                            Behavior on scale { NumberAnimation { duration: Services.Colors.animSlow; easing.type: Easing.OutBack } }
                                        }

                                        ColumnLayout {
                                            spacing: 2
                                            Text {
                                                text: modelData.name
                                                horizontalAlignment: Text.AlignLeft
                                                font.pixelSize: 18
                                                font.weight: isCurrent ? Font.Bold : Font.DemiBold
                                                color: isCurrent ? Services.Colors.primary : Services.Colors.mainText
                                                font.family: Services.Colors.fontFamily
                                            }
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: " Enter"
                                            Layout.alignment: Qt.AlignRight
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            color: Services.Colors.primary
                                            opacity: isCurrent ? 0.7 : 0
                                            font.family: Services.Colors.fontFamily
                                            
                                            Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal } }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        appList.hoveredSection = modelData.name[0].toUpperCase()
                                        appList.isAnyItemHovered = true
                                    }
                                    onPositionChanged: (mouse) => {
                                        let global = mapToGlobal(mouse.x, mouse.y)
                                        if (Math.abs(global.x - appList.lastMouseX) > 2 || Math.abs(global.y - appList.lastMouseY) > 2) {
                                            appList.currentIndex = index
                                            appList.lastMouseX = global.x
                                            appList.lastMouseY = global.y
                                        }
                                    }
                                    onExited: {
                                        appList.isAnyItemHovered = false
                                        globalClearHoverTimer.restart()
                                    }
                                    onClicked: launch()
                                }
                            }
                        }
                    }
                }
            }

            // Workspace Grid (Hidden when searching/all apps)
            Item {
                id: workspaceContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: searchInput.text === "" && !window.showingAllApps

                GridLayout {
                    id: wsGrid
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.94, 1800)
                    height: Math.min(parent.height * 0.85, 1000)
                    
                    opacity: (searchInput.text === "" && !window.showingAllApps) ? 1.0 : 0.0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                    scale: 1.0

                    readonly property int count: wsRepeater.count || 1
                    
                    columns: {
                        let bestC = 1
                        let maxDim = 0
                        let n = count
                        let w = width
                        let h = height
                        let gap = columnSpacing
                        
                        for (let c = 1; c <= n; c++) {
                            let r = Math.ceil(n / c)
                            let cw = (w - (gap * (c - 1))) / c
                            let ch = (h - (gap * (r - 1))) / r
                            let dim = Math.min(cw, ch)
                            if (dim > maxDim) {
                                maxDim = dim
                                bestC = c
                            }
                        }
                        return bestC
                    }
                    
                    rows: Math.ceil(count / columns)
                    
                    columnSpacing: 48
                    rowSpacing: 48

                    readonly property real cellW: (width - (columnSpacing * (columns - 1))) / columns
                    readonly property real cellH: (height - (rowSpacing * (rows - 1))) / rows
                    readonly property real cellDim: Math.min(cellW, cellH, 600)

                    Repeater {
                        id: wsRepeater
                        model: Hyprland.workspaces

                        delegate: Item {
                            id: wsDelegate
                            required property HyprlandWorkspace modelData
                            
                            Layout.preferredWidth: wsGrid.cellDim
                            Layout.preferredHeight: wsGrid.cellDim
                            Layout.alignment: Qt.AlignCenter
                            
                            readonly property real monW: monMeta ? (monMeta.transform % 2 === 0 ? monMeta.width : monMeta.height) : Services.MonitorService.primaryScreen.width
                            readonly property real monH: monMeta ? (monMeta.transform % 2 === 0 ? monMeta.height : monMeta.width) : Services.MonitorService.primaryScreen.height

                            readonly property real maxInner: wsGrid.cellDim - 24
                            readonly property real innerW: monW >= monH ? maxInner : Math.round(maxInner * (monW / monH))
                            readonly property real innerH: monH > monW ? maxInner : Math.round(maxInner * (monH / monW))
                            
                            readonly property var wsMeta: {
                                for (let w of window.workspacesData) {
                                    if (w.id === modelData.id) return w
                                }
                                return null
                            }
                            
                            readonly property var monMeta: {
                                if (!wsMeta || !wsMeta.monitor) return null
                                for (let m of window.monitorsData) {
                                    if (m.name === wsMeta.monitor) return m
                                }
                                return null
                            }

                            visible: modelData.id > 0

                            Rectangle {
                                id: workspaceBox
                                anchors.centerIn: parent
                                width: innerW + 24
                                height: innerH + 24

                                radius: Services.Colors.radiusLarge
                                color: Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.6)
                                border.width: modelData.active ? 2 : 1
                                border.color: modelData.active ? Services.Colors.primary : Services.Colors.border

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.activate()
                                        Services.ShellData.overviewVisible = false
                                    }
                                    onEntered: workspaceBox.color = Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.8)
                                    onExited: workspaceBox.color = Qt.rgba(Services.Colors.bg.r, Services.Colors.bg.g, Services.Colors.bg.b, 0.6)
                                }

                                Repeater {
                                    model: windowsModel

                                    delegate: Rectangle {
                                        visible: model.workspaceId === wsDelegate.modelData.id

                                        readonly property real scaleX: innerW / (monW || 1)
                                        readonly property real scaleY: innerH / (monH || 1)

                                        x: 12 + (model.rectX - (monMeta ? monMeta.x : 0)) * scaleX
                                        y: 12 + (model.rectY - (monMeta ? monMeta.y : 0)) * scaleY
                                        width: Math.max(model.rectW * scaleX, 4)
                                        height: Math.max(model.rectH * scaleY, 4)

                                        Behavior on x { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                                        Behavior on y { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                                        Behavior on width { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
                                        Behavior on height { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }

                                        radius: 8
                                        color: {
                                            let base = !appIcon.isFallback 
                                                ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.25)
                                                : Qt.rgba(1, 1, 1, 0.2)
                                            return windowMouseArea.containsMouse ? Qt.rgba(base.r, base.g, base.b, base.a + 0.1) : base
                                        }
                                        border.width: windowMouseArea.containsMouse ? 2 : 1
                                        border.color: windowMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)

                                        MouseArea {
                                            id: windowMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            onClicked: {
                                                let addr = model.address.toString()
                                                if (addr.startsWith("0x")) addr = addr.substring(2)
                                                
                                                if (mouse.button === Qt.RightButton) {
                                                    Services.ShellData.runCommand(["hyprctl", "dispatch", "closewindow", "address:0x" + addr])
                                                    
                                                    // Manual remove for instant feedback
                                                    for (let i = 0; i < windowsModel.count; i++) {
                                                        if (windowsModel.get(i).address === model.address) {
                                                            windowsModel.remove(i)
                                                            break
                                                        }
                                                    }
                                                } else {
                                                    Services.ShellData.runCommand(["hyprctl", "dispatch", "focuswindow", "address:0x" + addr])
                                                    Services.ShellData.overviewVisible = false
                                                }
                                            }
                                            onExited: {}
                                        }

                                        AppIcon {
                                            id: appIcon
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width * 0.6, 64)
                                            height: Math.min(parent.height * 0.6, 64)
                                            iconName: model.class
                                            fallbackText: model.class || "󰝚"
                                            iconBgColor: "transparent"
                                            fallbackBgColor: "transparent"
                                            fallbackBorderWidth: 0
                                            iconBorderWidth: 0
                                            opacity: 0.9
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
    }
}
