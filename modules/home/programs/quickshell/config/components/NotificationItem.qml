import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
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
    
    radius: Services.Colors.radiusNormal
    
    color: {
        let base = root.urgency === 2 ? Services.Colors.alpha(Services.Colors.error, 0.05) : Services.Colors.bg
        if (mouseArea.pressed) return Services.Colors.alpha(Qt.color("white"), base.a + 0.1)
        if (hoverHandler.hovered) return Services.Colors.alpha(Qt.color("white"), base.a + 0.05)
        return base
    }
    border.width: 1
    border.color: root.urgency === 2 ? Services.Colors.error : Services.Colors.border

    scale: mouseArea.pressed ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: Services.Colors.animFast; easing.type: Easing.OutBack } }
    Behavior on color { ColorAnimation { duration: Services.Colors.animNormal } }

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
        spacing: Services.Colors.spacingNormal

        RowLayout {
            Layout.fillWidth: true
            spacing: Services.Colors.spacingLarge

            // Icon
            Item {
                Layout.preferredWidth: 48; Layout.preferredHeight: 48
                visible: root.iconSource.length > 0

                // Urgency Glow (MultiEffect)
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: Services.Colors.radiusSmall + 4
                    color: root.urgency === 2 ? Services.Colors.alpha(Services.Colors.error, 0.4) : (root.urgency === 1 ? Services.Colors.alpha(Services.Colors.primary, 0.15) : "transparent")
                    
                    layer.enabled: root.urgency > 0
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blurMax: 16
                        blur: 1.0
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Services.Colors.radiusSmall
                    color: Qt.rgba(1, 1, 1, 0.1)
                    
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
        }

        ColumnLayout {
                Layout.fillWidth: true
                spacing: Services.Colors.spacingSmall

                Row {
                    id: headerRow
                    Layout.fillWidth: true
                    width: parent.width
                    spacing: Services.Colors.spacingSmall

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
            spacing: Services.Colors.spacingNormal
            visible: !!(root.actions && root.actions.length > 0)

            Repeater {
                model: root.actions
                delegate: ActionButton {
                    text: modelData ? modelData.text : ""
                    fontPixelSize: 10
                    implicitHeight: 24
                    baseColor: isHovered ? Services.Colors.border : Qt.rgba(1, 1, 1, 0.05)
                    borderColor: "transparent"
                    textColor: Services.Colors.mainText
                    radius: Services.Colors.radiusSmall
                    onClicked: root.action(modelData)
                }
            }
        }
    }

    // Dismiss Button
    ActionButton {
        id: closeButton
        anchors {
            top: parent.top
            right: parent.right
            margins: 8
        }
        z: 20
        implicitWidth: 24; implicitHeight: 24
        radius: Services.Colors.radiusNormal
        baseColor: "transparent"
        borderColor: "transparent"
        iconColor: isHovered ? Services.Colors.red : Services.Colors.dim
        iconSize: 14
        icon: "󰅖"
        text: ""
        visible: hoverHandler.hovered || isHovered
        onClicked: root.dismissed()
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
        radius: Services.Colors.radiusSmall
        color: Qt.rgba(1, 1, 1, 0.1)
        z: 10
        visible: root.showProgress
        
        opacity: root._wasClicked ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: Services.Colors.animSlow } }
        
        Rectangle {
            id: progressFill
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 0
            color: Services.Colors.primary
            radius: Services.Colors.radiusSmall
            
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
