import QtQuick
import QtQuick.Layouts
import "../services" as Services

Rectangle {
    id: root

    // Data properties (Snapshots)
    property string appName: ""
    property string summary: ""
    property string body: ""
    property string iconSource: ""
    property var actions: []
    property string desktopEntry: ""
    property int pid: 0
    property int urgency: 1 // 0=Low, 1=Normal, 2=Critical
    
    // Timer bar properties
    property bool showProgress: false
    property int progressDuration: 0
    property bool isPaused: false
    
    property bool _wasClicked: false
    onProgressDurationChanged: {
        _wasClicked = false;
        _restartTimer();
    }
    onShowProgressChanged: if (showProgress) {
        _wasClicked = false;
        _restartTimer();
    }
    
    // Signals for interactions
    signal action(var action)
    signal dismissed()
    signal expired()
    
    readonly property bool mouseAreaHovered: hoverHandler.hovered

    HoverHandler {
        id: hoverHandler
    }

    implicitHeight: mainLayout.implicitHeight + 24
    height: implicitHeight
    
    radius: 12
    
    color: {
        let base = root.urgency === 2 ? Qt.rgba(Services.Colors.error.r, Services.Colors.error.g, Services.Colors.error.b, 0.05) : Services.Colors.bg
        if (mouseArea.pressed) return Qt.rgba(base.r + 0.1, base.g + 0.1, base.b + 0.1, base.a + 0.1)
        if (hoverHandler.hovered) return Qt.rgba(base.r + 0.05, base.g + 0.05, base.b + 0.05, base.a + 0.05)
        return base
    }
    border.width: 1
    border.color: root.urgency === 2 ? Services.Colors.error : Services.Colors.border

    scale: mouseArea.pressed ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
    Behavior on color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: root._wasClicked = true
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                root.dismissed()
            } else {
                root.action(null)
            }
        }
    }

    visible: (root.summary.trim().length > 0) || (root.body.trim().length > 0) || (root.appName.trim().length > 0)

    ColumnLayout {
        id: mainLayout
        anchors {
            top: parent.top; left: parent.left; right: parent.right
            margins: 12
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Icon
            Rectangle {
                Layout.preferredWidth: 48; Layout.preferredHeight: 48
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: root.iconSource.length > 0
                
                Image {
                    id: iconImage
                    property string failedSource: ""
                    
                    anchors.fill: parent
                    anchors.margins: 4
                    source: {
                        let icon = root.iconSource
                        if (!icon || icon.length === 0) return ""
                        
                        // If it's already a full URI (file://, image://, etc.), use it as is.
                        // Sometimes we get double prefixes or mixed prefixes.
                        if (icon.indexOf("image://icon/image://") === 0) {
                            icon = icon.substring(13)
                        } else if (icon.indexOf("image://icon/file://") === 0) {
                            icon = icon.substring(13)
                        }

                        let finalSrc = ""
                        if (icon.indexOf("://") !== -1) finalSrc = icon
                        else if (icon.indexOf("/") === 0) finalSrc = "file://" + icon
                        else finalSrc = "image://icon/" + icon
                        
                        // Fallback logic for broken DBus images (e.g. from Vesktop)
                        if (iconImage.failedSource === finalSrc) {
                            let fallback = root.desktopEntry || root.appName || ""
                            if (fallback.length > 0) {
                                return "image://icon/" + fallback.toLowerCase()
                            }
                        }
                        
                        return finalSrc
                    }
                    fillMode: Image.PreserveAspectFit
                    asynchronous: false
                    cache: false
                    
                    onStatusChanged: {
                        if (status === Image.Error) {
                            if (source.toString().indexOf("image://qsimage/") === 0) {
                                iconImage.failedSource = source.toString()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Row {
                    id: headerRow
                    Layout.fillWidth: true
                    width: parent.width
                    spacing: 6

                    ShadowText {
                        id: summaryText
                        text: root.summary
                        font.pixelSize: 13
                        font.family: Services.Colors.fontFamily
                        font.weight: Font.Bold
                        color: Services.Colors.mainText
                        elide: Text.ElideRight
                        // Robust width for summary: total width minus dot and app name if they exist
                        width: {
                            if (root.appName.length === 0) return parent.width;
                            let reserved = dotText.width + appNameText.width + (headerRow.spacing * 2);
                            return Math.min(implicitWidth, parent.width - reserved);
                        }
                    }

                    Text {
                        id: dotText
                        text: "•"
                        font.pixelSize: 10
                        font.family: Services.Colors.fontFamily
                        font.weight: Font.DemiBold
                        color: Services.Colors.primaryContainer
                        visible: root.appName.length > 0
                        anchors.verticalCenter: summaryText.verticalCenter
                        width: visible ? implicitWidth : 0
                    }

                    ShadowText {
                        id: appNameText
                        text: root.appName
                        font.pixelSize: 11
                        font.family: Services.Colors.fontFamily
                        font.weight: Font.DemiBold
                        color: Services.Colors.primary
                        width: visible ? Math.min(implicitWidth, 140) : 0
                        elide: Text.ElideRight
                        visible: root.appName.length > 0
                        anchors.verticalCenter: summaryText.verticalCenter
                    }
                }

                ShadowText {
                    id: bodyText
                    Layout.fillWidth: true
                    text: root.body.replace(/\n/g, "<br>")
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    font.family: Services.Colors.fontFamily
                    color: Services.Colors.subtext
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 100
                    elide: Text.ElideRight
                    visible: text.length > 0
                    textFormat: Text.StyledText
                }
            }

        }

        // Actions
        Flow {
            Layout.fillWidth: true
            layoutDirection: Qt.RightToLeft
            spacing: 8
            visible: !!(root.actions && root.actions.length > 0)

            Repeater {
                model: root.actions
                delegate: Rectangle {
                    width: actionText.contentWidth + 16
                    height: 24
                    radius: 6
                    color: actionMouse.containsMouse ? Services.Colors.border : Qt.rgba(1, 1, 1, 0.05)
                    
                    ShadowText {
                        id: actionText
                        anchors.centerIn: parent
                        text: modelData ? modelData.text : ""
                        font.pixelSize: 10
                        font.family: Services.Colors.fontFamily
                        color: Services.Colors.mainText
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.action(modelData)
                    }
                }
            }
        }
    }

    // Dismiss Button
    Rectangle {
        id: closeButton
        width: 24; height: 24
        anchors {
            top: parent.top
            right: parent.right
            margins: 8
        }
        z: 20
        radius: 12
        color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        visible: hoverHandler.hovered || closeMouse.containsMouse
        
        Text {
            anchors.centerIn: parent
            text: "󰅖"
            font.pixelSize: 14
            font.family: Services.Colors.fontFamily
            color: closeMouse.containsMouse ? Services.Colors.red : Services.Colors.dim
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.dismissed()
        }
    }

    function _restartTimer() {
        if (!root.showProgress || root.progressDuration <= 0) return
        progressAnim.stop()
        
        let targetHeight = Math.max(0, root.height - 24)
        progressFill.height = targetHeight
        progressAnim.from = targetHeight
        progressAnim.duration = root.progressDuration
        
        if (!root.isPaused) progressAnim.start()
    }

    onHeightChanged: _restartTimer()
    onIsPausedChanged: {
        if (isPaused) progressAnim.pause()
        else {
            if (progressAnim.paused) progressAnim.resume()
            else _restartTimer()
        }
    }

    // Timer indicator bar
    Rectangle {
        id: progressBar
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 4
        height: Math.max(0, parent.height - 24)
        radius: 2
        color: Qt.rgba(1, 1, 1, 0.1)
        z: 10
        visible: root.showProgress
        
        opacity: root._wasClicked ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        
        Rectangle {
            id: progressFill
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 0
            color: Services.Colors.primary
            radius: 2
            
            NumberAnimation {
                id: progressAnim
                target: progressFill
                property: "height"
                to: 0
                onFinished: root.expired()
            }
        }
    }
}
