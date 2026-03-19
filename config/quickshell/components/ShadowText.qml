import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import "../services" as Services

Text {
    id: root

    color: Services.Colors.mainText
    font.family: Services.Colors.fontFamily
    font.pixelSize: Services.Colors.fontSize
    font.weight: Font.DemiBold
    
    layer.enabled: root.text !== ""
    layer.effect: DropShadow {
        transparentBorder: true
        color: Qt.rgba(0, 0, 0, 0.6)
        radius: Services.Colors.radiusSmall
        samples: 9
    }
}
