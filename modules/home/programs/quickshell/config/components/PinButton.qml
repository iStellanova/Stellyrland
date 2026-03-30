import QtQuick
import QtQuick.Layouts
import "../services" as Services
import "." as Components

Components.BarButton {
    id: root
    
    property bool pinned: false
    signal toggled()

    buttonWidth: 26
    buttonHeight: 26
    bgRadius: 6
    
    active: pinned
    text: pinned ? "󰐃" : "󰐄"
    fontSize: 14
    textColor: pinned ? Services.Colors.primary : Services.Colors.mainText
    
    // Maintain the unique "only show when hovered or pinned" aesthetic
    opacity: (pinned || hovered) ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 150 } }
    
    onClicked: root.toggled()
}
