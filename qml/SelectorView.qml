import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import "qrc:/src/server.js" as Server;

Item {

    id: editCalendarWindow
    //anchors.fill: parent

    property var currentEvent
    property bool isStartDate: true
    property bool isNewEvent: false

    function loadEvent(event, isStart, isNew) {
        isStartDate = isStart;
        isNewEvent = isNew;
        currentEvent = event;

        selectorcalendar.selectedDate = isStart ? event.startTime : event.endTime;
        selectHourCombo.currentIndex = isStart ? event.startTime.getHours() : event.endTime.getHours();
        selectMinuteCombo.currentIndex = isStart ? event.startTime.getMinutes() : event.endTime.getMinutes();
    }

    function setEventDateTime(date, time) {

        if (isStartDate) {
            currentEvent.startTime = date
            currentEvent.startTime.setHours(selectHourCombo.currentIndex)
            currentEvent.startTime.setMinutes(selectMinuteCombo.currentIndex)
        } else {
            currentEvent.endTime = date
            currentEvent.endTime.setHours(selectHourCombo.currentIndex)
            currentEvent.endTime.setMinutes(selectMinuteCombo.currentIndex)
        }
    }

    function pushInfo() {
        mainStackView.push(editPage);
        if (isNewEvent) {
            mainStackView.currentItem.setNewUpdatableEvent(currentEvent);
        } else {
            mainStackView.currentItem.setEvent(currentEvent);
        }
    }


    Flow {
        id: rowEditMenu
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        layoutDirection: Qt.LeftToRight

        Calendar {
            id: selectorcalendar
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

        Rectangle {

            width: {
                var res = parent.width*0.5;
                if (parent.width < parent.height) {
                    res = parent.width;
                }
                res;
            }

            height: {
                var res = parent.height*0.5;
                if (parent.width > parent.height) {
                    res = parent.height;
                }
                res;
            }

            border.color: Qt.darker("#F4F4F4", 1.2)

            Rectangle {

                id: eventDateTitleRectange

                width: parent.width
                height: eventDateDayLabel.height*2
                anchors.fill: parent
                anchors.margins: 10

                Row {

                    id: eventDateDayRow
                    width: parent.width
                    height: parent.height
                    spacing: 10

                    Label {
                        id: eventDateDayLabel
                        text: selectorcalendar.selectedDate.getDate()
                        font.pointSize: 35
                    }

                    Column {
                        height: eventDateDayLabel.height
                        anchors.margins: 5

                        Label {
                            readonly property var options: { weekday: "long" }
                            text: Qt.locale().standaloneDayName(
                                selectorcalendar.selectedDate.getDay(),
                                Locale.LongFormat)
                            font.pointSize: 18
                        }

                        Label {
                            text: Qt.locale().standaloneMonthName(selectorcalendar.selectedDate.getMonth())
                                  + selectorcalendar.selectedDate.toLocaleDateString(Qt.locale(), " yyyy")
                            font.pointSize: 12
                        }
                    }
                }

                RoundButton {
                    id: cancelDateButton
                    width: eventDateDayLabel.height-10
                    height: eventDateDayLabel.height-10
                    anchors.right: parent.right
                    anchors.margins: 5

                    text: Server.ICONS.back
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: pushInfo()

                }

                RoundButton {
                    id: acceptEventDateButton
                    width: eventDateDayLabel.height-10
                    height: eventDateDayLabel.height-10
                    anchors.right: cancelDateButton.left
                    anchors.margins: 5

                    text: Server.ICONS.accept
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {

                        setEventDateTime(selectorcalendar.selectedDate);
                        pushInfo();
                    }

                }

                Rectangle {

                    width: parent.width
                    height: eventDateDayLabel.height
                    anchors.margins: 10
                    anchors.top: acceptEventDateButton.bottom

                    Label {
                        id: eventDateTimeDayLabel
                        anchors.margins: 10;
                        text: "Select time:\t"
                    }

                    ComboBox {
                        id: selectHourCombo
                        width: eventDateTimeDayLabel.width
                        height: eventDateTimeDayLabel.height+10
                        anchors.left: eventDateTimeDayLabel.right
                        anchors.margins: 10;

                        model: Server.getIntArray(24);
                    }

                    ComboBox {
                        id: selectMinuteCombo
                        width: eventDateTimeDayLabel.width
                        height: eventDateTimeDayLabel.height+10
                        anchors.left: selectHourCombo.right
                        anchors.margins: 10;

                        model: Server.getIntArray(60);
                    }

                }

            }

        }
    }
}
