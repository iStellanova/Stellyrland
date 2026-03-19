import QtQuick
import QtQuick.Layouts
import "../services" as Services

Item {
    id: root
    implicitWidth: 310
    implicitHeight: 70

    property var window: null

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: Services.Colors.spacingNormal

        PowerButton {
            icon: "󰌾"
            label: "Lock"
            onClicked: { Services.ShellData.lock(); if (root.window) root.window.closeRequested(); }
            Layout.fillWidth: true
        }

        PowerButton {
            icon: "󰗽"
            label: "Logout"
            onClicked: { Services.ShellData.logout(); if (root.window) root.window.closeRequested(); }
            Layout.fillWidth: true
        }

        PowerButton {
            icon: "󰒲"
            label: "Sleep"
            onClicked: { Services.ShellData.suspend(); if (root.window) root.window.closeRequested(); }
            Layout.fillWidth: true
        }

        PowerButton {
            icon: "󰜉"
            label: (Services.ShellData.powerCountdown > 0 && Services.ShellData.powerActionType === "reboot") 
                   ? Services.ShellData.powerCountdown + "s" : "Reboot"
            active: Services.ShellData.powerCountdown > 0 && Services.ShellData.powerActionType === "reboot"
            onClicked: { Services.ShellData.togglePowerAction("reboot"); }
            Layout.fillWidth: true
        }

        PowerButton {
            icon: "󰐥"
            label: (Services.ShellData.powerCountdown > 0 && Services.ShellData.powerActionType === "shutdown") 
                   ? Services.ShellData.powerCountdown + "s" : "Power"
            accent: Services.Colors.red
            active: Services.ShellData.powerCountdown > 0 && Services.ShellData.powerActionType === "shutdown"
            onClicked: { Services.ShellData.togglePowerAction("shutdown"); }
            Layout.fillWidth: true
        }
    }

    component PowerButton: Rectangle {
        property string icon: ""
        property string label: ""
        property color accent: Services.Colors.primary
        property bool active: false
        property real pulseFactor: 1.0
        signal clicked()

        implicitHeight: 50
        radius: Services.Colors.radiusSmall
        color: (active || btnMouse.containsMouse) ? Qt.rgba(accent.r, accent.g, accent.b, active ? (0.15 * pulseFactor) : 0.15) : "transparent"
        border.width: 1
        border.color: (active || btnMouse.containsMouse) ? Qt.rgba(accent.r, accent.g, accent.b, active ? (0.35 * pulseFactor) : 0.35) : Qt.rgba(1, 1, 1, 0.1)
        scale: active ? (1.0 + (pulseFactor - 1.0) * 0.05) : 1.0

        SequentialAnimation on pulseFactor {
            running: active
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.6; duration: Services.Colors.animSlow; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.6; to: 1.0; duration: Services.Colors.animSlow; easing.type: Easing.InOutSine }
        }

        onActiveChanged: if (!active) pulseFactor = 1.0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Services.Colors.spacingSmall

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: icon
                font.pixelSize: 18
                font.family: Services.Colors.fontFamily
                color: (active || btnMouse.containsMouse) ? accent : Services.Colors.mainText
            }

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: label
                font.pixelSize: 8
                font.family: Services.Colors.fontFamily
                font.weight: Font.DemiBold
                color: (active || btnMouse.containsMouse) ? accent : Services.Colors.dim
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        Behavior on color { enabled: !active; ColorAnimation { duration: Services.Colors.animNormal } }
        Behavior on border.color { enabled: !active; ColorAnimation { duration: Services.Colors.animNormal } }
        Behavior on scale { NumberAnimation { duration: Services.Colors.animNormal; easing.type: Easing.OutCubic } }
    }
}
