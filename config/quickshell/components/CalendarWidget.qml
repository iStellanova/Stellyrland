import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services

Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property date currentDate: new Date()
    property int currentMonth: currentDate.getMonth()
    property int currentYear: currentDate.getFullYear()

    property int todayDate: new Date().getDate()
    property int todayMonth: new Date().getMonth()
    property int todayYear: new Date().getFullYear()

    property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    property var dayNames: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    function daysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfMonth(month, year) {
        return new Date(year, month, 1).getDay();
    }

    function prevMonth() {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }

        calendarStack.replaceEnter = slideLeftEnter
        calendarStack.replaceExit = slideLeftExit
        calendarStack.replace(monthGridComponent, { "monthVal": currentMonth, "yearVal": currentYear })
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }

        calendarStack.replaceEnter = slideRightEnter
        calendarStack.replaceExit = slideRightExit
        calendarStack.replace(monthGridComponent, { "monthVal": currentMonth, "yearVal": currentYear })
    }

    // Transitions
    Transition {
        id: slideRightEnter
        NumberAnimation { property: "x"; from: calendarStack.width; to: 0; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
    }
    Transition {
        id: slideRightExit
        NumberAnimation { property: "x"; from: 0; to: -calendarStack.width; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
    }

    Transition {
        id: slideLeftEnter
        NumberAnimation { property: "x"; from: -calendarStack.width; to: 0; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
    }
    Transition {
        id: slideLeftExit
        NumberAnimation { property: "x"; from: 0; to: calendarStack.width; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
    }

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            
            ShadowText {
                text: root.monthNames[root.currentMonth] + " " + root.currentYear
                font.pixelSize: 14
                font.family: Services.Colors.fontFamily
                font.weight: Font.DemiBold
                color: Services.Colors.mainText
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                implicitWidth: 24; implicitHeight: 24
                radius: 6
                color: prevMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                ShadowText {
                    anchors.centerIn: parent
                    text: "󰅁"
                    font.pixelSize: 16
                    font.family: Services.Colors.fontFamily
                    color: Services.Colors.mainText
                }

                MouseArea {
                    id: prevMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                }
            }

            Rectangle {
                implicitWidth: 24; implicitHeight: 24
                radius: 6
                color: nextMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                ShadowText {
                    anchors.centerIn: parent
                    text: "󰅂"
                    font.pixelSize: 16
                    font.family: Services.Colors.fontFamily
                    color: Services.Colors.mainText
                }

                MouseArea {
                    id: nextMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
                }
            }
        }

        // Days of week
        GridLayout {
            columns: 7
            columnSpacing: 4
            rowSpacing: 4
            Layout.fillWidth: true

            Repeater {
                model: root.dayNames
                delegate: Item {
                    Layout.fillWidth: true
                    implicitHeight: 24
                    
                    ShadowText {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 11
                        font.family: Services.Colors.fontFamily
                        font.weight: Font.DemiBold
                        color: Services.Colors.dim
                    }
                }
            }
        }

        StackView {
            id: calendarStack
            Layout.fillWidth: true
            clip: true
            implicitHeight: 180 // enough for 6 rows
            
            initialItem: monthGridComponent
            Component.onCompleted: {
                if (currentItem) {
                    currentItem.monthVal = root.currentMonth
                    currentItem.yearVal = root.currentYear
                }
            }

            replaceEnter: Transition {}
            replaceExit: Transition {}
        }

        Component {
            id: monthGridComponent
            
            GridLayout {
                width: calendarStack.width
                columns: 7
                columnSpacing: 4
                rowSpacing: 4
                
                property int monthVal: root.currentMonth
                property int yearVal: root.currentYear

                Repeater {
                    model: {
                        var items = [];
                        var firstDay = root.firstDayOfMonth(parent.monthVal, parent.yearVal);
                        var numDays = root.daysInMonth(parent.monthVal, parent.yearVal);
                        
                        for (var i = 0; i < firstDay; i++) items.push("");
                        for (var d = 1; d <= numDays; d++) items.push(d.toString());
                        
                        return items;
                    }
                    
                    delegate: Rectangle {
                        required property string modelData
                        
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 8
                        
                        property bool isToday: modelData !== "" && 
                                              parseInt(modelData) === root.todayDate && 
                                              parent.monthVal === root.todayMonth && 
                                              parent.yearVal === root.todayYear
                                              
                        property bool isValidDay: modelData !== ""

                        color: isToday ? Qt.rgba(Services.Colors.primary.r, Services.Colors.primary.g, Services.Colors.primary.b, 0.2) : (dayMouseArea.containsMouse && isValidDay ? Qt.rgba(1, 1, 1, 0.1) : "transparent")
                        
                        ShadowText {
                            anchors.centerIn: parent
                            text: parent.modelData
                            font.pixelSize: 12
                            font.family: Services.Colors.fontFamily
                            font.weight: parent.isToday ? Font.Bold : Font.Normal
                            color: parent.isToday ? Services.Colors.primary : Services.Colors.mainText
                            visible: parent.isValidDay
                        }

                        MouseArea {
                            id: dayMouseArea
                            anchors.fill: parent
                            hoverEnabled: parent.isValidDay
                            cursorShape: parent.isValidDay ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                }
            }
        }
    }
}
