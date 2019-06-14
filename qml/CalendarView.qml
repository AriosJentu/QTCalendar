import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import org.jentucalendar.calendar 1.0

Item {

    id: calendarWindow
    //anchors.fill: parent

    EventModel {
        id: eventModel
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


                    Rectangle {
                        id: dateDelegateRect
                        anchors.fill: parent

                        color: {
                            var color = "#FFFFFF";

                            var date1 = Qt.formatDateTime(new Date(), "yyMMdd")
                            var date2 = Qt.formatDateTime(styleData.date, "yyMMdd")

                            if (date1 === date2) {
                                color = currentDateColor;
                            }

                            if (styleData.selected) {
                                color = selectedDateColor;
                            }

                            if (!styleData.visibleMonth) {
                                color = "#EEEEEE"
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
                        visible: eventModel.eventsForDate(styleData.date).length > 0
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

                    text: "+"

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
                id: eventsListView
                spacing: 4
                clip: true
                header: eventListHeader
                anchors.fill: parent
                anchors.margins: 10
                model: eventModel.eventsForDate(maincalendar.selectedDate)


                delegate: Rectangle {
                    width: eventsListView.width
                    height: eventItemColumn.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    property variant win;

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
                            }

                            Label {
                                id: timeLabel
                                width: parent.width
                                wrapMode: Text.Wrap
                                text: {
                                    modelData.startDate.toLocaleTimeString(maincalendar.locale, Locale.ShortFormat);
                                }
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
                                    //viewPageEventView.sendMessage("Hello world!");
                                    //viewPageEventView.setEvent(modelData);
                                }

                                //console.log(modelData.startDate);
                                //console.log(modelData.endDate);
                                //console.log(modelData.name);
                                //console.log(modelData.information);
                            }

                            Menu {
                                id: contextMenu
                                MenuItem { text: "Edit" }
                                MenuItem { text: "Delete" }
                            }
                        }

                    }
                }
            }
        }
    }
}
