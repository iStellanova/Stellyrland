import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../services" as Services

Item {
    id: root
    implicitWidth: 310
    implicitHeight: 200

    GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: 8
        cellWidth: 72
        cellHeight: 72
        model: Services.WallpaperService.wallpapers
        clip: true

        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                id: wrapper
                anchors.fill: parent
                anchors.margins: 4
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.1)
                border.width: mouse.containsMouse ? 2 : 1
                border.color: mouse.containsMouse ? Services.Colors.primary : Qt.rgba(1, 1, 1, 0.2)
                
                scale: mouse.pressed ? 0.92 : (mouse.containsMouse ? 1.08 : 1.0)

                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on border.width { NumberAnimation { duration: 150 } }

                Item {
                    anchors.fill: parent
                    anchors.margins: wrapper.border.width
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: wrapper.width; height: wrapper.height
                            radius: wrapper.radius
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(144, 144)
                        opacity: mouse.containsMouse ? 1.0 : 0.85
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    // Subtle highlight overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        opacity: mouse.containsMouse ? 0.1 : 0
                        visible: opacity > 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Services.WallpaperService.setWallpaper(modelData.replace("file://", ""))
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            active: true
        }
    }
}
