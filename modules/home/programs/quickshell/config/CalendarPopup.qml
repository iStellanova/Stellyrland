import Quickshell
import Quickshell.Wayland._WlrLayerShell 0.0
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "services" as Services
import "components" as Components

Components.DrawerPopup {
    id: window

    Components.CalendarWidget {
        id: calendarLayout
        Layout.fillWidth: true
        pinned: window.pinned
        onPinToggled: window.pinned = !window.pinned
    }
}