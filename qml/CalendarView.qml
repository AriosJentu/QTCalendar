import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import org.jentucalendar.calendar 1.0

Item {

    id: calendarWindow
    //anchors.fill: parent

    function setSelectedDate(date) {
        maincalendar.selectedDate = date;
    }



    Flow {
        id: row
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        layoutDirection: Qt.LeftToRight

        Calendar {
            id: maincalendar
            width: {
                var res = parent.width*0.5 - parent.spacing;
                if (parent.width < parent.height) {
                    res = parent.width;
                }
                res;
            }

            height: {
                var res = parent.height*0.5 - parent.spacing;
                if (parent.width > parent.height) {
                    res = parent.height;
                }
                res;
            }
            frameVisible: true
            weekNumbersVisible: true

            selectedDate: new Date()
            focus: true

            style: CalendarStyle {
                dayDelegate: Item {

                    readonly property color currentDateColor: "#84C391"
                    readonly property color selectedDateColor: "#4F9EE0"

//                    property bool visibility: false;

//                    Component.onCompleted: {
//                        eventModel.eventsForDate(styleData.date);
//                        eventModel.eventsAvailable.connect(setVisible);
//                        console.log("Searching for", styleData.date)
//                    }

//                    function setVisible(result) {
//                        visibility = result.length > 0;
//                        //console.log(result.length);
//                        console.log("Here for", styleData.date, result.length);
//                    }

                    Rectangle {
                        id: dateDelegateRect
                        anchors.fill: parent

                        color: {
                            var color = "#FFFFFF";

                            var date1 = Qt.formatDateTime(new Date(), "yyMMdd")
                            var date2 = Qt.formatDateTime(styleData.date, "yyMMdd")

                            if (!styleData.visibleMonth) {
                                color = "#EEEEEE"
                            }

                            if (date1 === date2) {
                                color = currentDateColor;
                            }

                            if (styleData.selected) {
                                color = selectedDateColor;
                            }

                            color;
                        }
                    }

                    Rectangle {
                        property real alpha: 0
                        id: transparentSelection
                        anchors.fill: parent
                        color: Qt.hsla(0, 0, 0, alpha)

                    }

                    Image {

                        visible: false
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 0
                        width: 12
                        height: width
                        source: "qrc:/assets/event.png"
                    }

                    Label {
                        id: dayDelegateText
                        text: styleData.date.getDate()
                        color: {
                            var color = "#333333";

                            var date1 = Qt.formatDateTime(new Date(), "yyMMdd")
                            var date2 = Qt.formatDateTime(styleData.date, "yyMMdd")

                            if (styleData.selected || date1 === date2) {
                                color = "#FFFFFF"
                            }
                            color;
                        }
                        anchors.centerIn: parent

                    }
                }
            }
        }

        Component {
            id: eventListHeader

            Rectangle {

                width: parent.width
                height: eventDayLabel.height

                Row {

                    id: eventDayRow
                    width: parent.width
                    height: parent.height
                    spacing: 10

                    Label {
                        id: eventDayLabel
                        text: maincalendar.selectedDate.getDate()
                        font.pointSize: 35
                    }

                    Column {
                        height: eventDayLabel.height
                        anchors.margins: 5

                        Label {
                            readonly property var options: { weekday: "long" }
                            text: Qt.locale().standaloneDayName(
                                maincalendar.selectedDate.getDay(),
                                Locale.LongFormat)
                            font.pointSize: 18
                        }

                        Label {
                            text: Qt.locale().standaloneMonthName(maincalendar.selectedDate.getMonth())
                                  + maincalendar.selectedDate.toLocaleDateString(Qt.locale(), " yyyy")
                            font.pointSize: 12
                        }
                    }

                }

                RoundButton {
                    id: addEventButton
                    width: parent.height-10
                    height: parent.height-10
                    anchors.right: parent.right
                    anchors.margins: 5

                    text: ""
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        mainStackView.push(editPage);
                        mainStackView.currentItem.setNewEvent(maincalendar.selectedDate);
                    }
                }

                RoundButton {
                    id: gotoTodayButton
                    width: parent.height-10
                    height: parent.height-10
                    anchors.right: addEventButton.left
                    anchors.margins: 5

                    text: ""
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        maincalendar.selectedDate = new Date();
                    }
                }

                RoundButton {
                    id: refreshDatabase
                    width: parent.height-10
                    height: parent.height-10
                    anchors.right: gotoTodayButton.left
                    anchors.margins: 5

                    text: ""
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        eventModel.eventsForDate(maincalendar.selectedDate);
                        console.log("Click")
                    }
                }
            }
        }

        Rectangle {
            width: {
                var res = parent.width*0.5 - parent.spacing;
                if (parent.width < parent.height) {
                    res = parent.width;
                }
                res;
            }

            height: {
                var res = parent.height*0.5 - parent.spacing;
                if (parent.width > parent.height) {
                    res = parent.height;
                }
                res;
            }
            border.color: Qt.darker("#F4F4F4", 1.2)

            ListView {

                property var array: [];

                id: eventsListView
                spacing: 4
                clip: true
                header: eventListHeader
                anchors.fill: parent
                anchors.margins: 10
                model: {
                    array;
                    //console.log("Update here")
                }
                interactive: true

                Component.onCompleted: {
                    eventModel.eventsAvailable.connect(setEvents);
                    //console.log("Update");
                }

                function setEvents(result) {
                    array = result;
                    //console.log("Here", result.length)
                }

                delegate: Rectangle {
                    width: eventsListView.width
                    height: eventItemColumn.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#EEEEEE"
                    }

                    Rectangle {
                        property string hoverColor: "transparent"
                        id: currentEventRectangle
                        width: parent.width
                        height: parent.height
                        color: hoverColor

                        Column {
                            id: eventItemColumn
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            height: timeLabel.height + nameLabel.height + 8

                            Label {
                                id: nameLabel
                                width: parent.width
                                wrapMode: Text.Wrap
                                text: modelData.name
                                font.bold: true
                            }

                            Label {
                                id: timeLabel
                                width: parent.width
                                wrapMode: Text.Wrap
                                text: {
                                    "Start: " + modelData.startTime.toLocaleString(maincalendar.locale, "yyyy-MM-dd HH:MM") + "\t" +
                                    "End: " + modelData.endTime.toLocaleString(maincalendar.locale, "yyyy-MM-dd HH:MM");
                                }
                                font.italic: true
                            }
                        }


                        MouseArea {

                            width: parent.width
                            height: parent.height
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onEntered: {
                                currentEventRectangle.hoverColor = "#EEEEEE";
                            }
                            onExited: {
                                currentEventRectangle.hoverColor = "transparent";
                            }
                            onPressed: {
                                currentEventRectangle.hoverColor = "#DDDDDD"
                            }
                            onReleased: {
                                currentEventRectangle.hoverColor = "#EEEEEE"
                            }
                            onPressAndHold: {
                                contextMenu.popup();
                                currentEventRectangle.hoverColor = "transparent";
                            }

                            onClicked: {

                                if (mouse.button === Qt.RightButton) {
                                    contextMenu.popup();
                                    currentEventRectangle.hoverColor = "transparent";
                                } else {
                                    mainStackView.push(viewPage);
                                    mainStackView.currentItem.setEvent(modelData);
                                }

                            }

                            Menu {
                                id: contextMenu
                                MenuItem {
                                    text: "Edit"
                                    onTriggered: {
                                        mainStackView.push(editPage);
                                        mainStackView.currentItem.setEvent(modelData);
                                    }
                                }
                                MenuItem {
                                    text: "Delete"
                                    onTriggered: {
                                        console.log("::: Removing event with ID ", modelData.id)
                                        eventModel.removeEvent(modelData.id);
                                        array = eventModel.eventsForDate(maincalendar.selectedDate)
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
