import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import "../services"

Text {
    id: root

    color: Colors.mainText
    font.family: Colors.fontFamily
    font.pixelSize: Colors.fontSize
    font.weight: Font.DemiBold
    
    layer.enabled: root.text !== ""
    layer.effect: DropShadow {
        transparentBorder: true
        color: Qt.rgba(0, 0, 0, 0.6)
        radius: 4
        samples: 9
    }
}
