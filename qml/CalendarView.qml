import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2
import "qrc:/src/server.js" as Server;

Item {

    id: calendarWindow
    //anchors.fill: parent

    MessageDialog {
        id: messageDialog
        title: "Server Error"
        text: ""
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
                    property bool visibility: false;

                    function getVisibilityForCurrentDate() {                        
                        Server.getVisibilityForDate(styleData.date, function(cnt) {
                            visibility = cnt > 0
                        }, Server.basicErrorFunc);
                    }


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
                                eventsListView.getEventsForCurrentDate();
                            }

                            visibility = false;
                            getVisibilityForCurrentDate();

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

                        visible: visibility
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
                    width: parent.height*1.2-10
                    height: parent.height*1.2-10
                    anchors.right: parent.right
                    anchors.margins: 5

                    text: Server.ICONS.new_evt
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        mainStackView.push(editPage);
                        mainStackView.currentItem.setNewEvent(maincalendar.selectedDate);
                    }
                }

                RoundButton {
                    id: gotoTodayButton
                    width: parent.height*1.2-10
                    height: parent.height*1.2-10
                    anchors.right: addEventButton.left
                    anchors.margins: 5

                    text: Server.ICONS.today
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked:  maincalendar.selectedDate = new Date()
                }

                RoundButton {
                    id: refreshDatabase
                    width: parent.height*1.2-10
                    height: parent.height*1.2-10
                    anchors.right: gotoTodayButton.left
                    anchors.margins: 5

                    text: Server.ICONS.refresh
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: eventsListView.getEventsForCurrentDate()
                }

                RoundButton {
                    id: accountInfo
                    width: parent.height*1.2-10
                    height: parent.height*1.2-10
                    anchors.right: refreshDatabase.left
                    anchors.margins: 5

                    text: Server.ICONS.account
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    enabled: false

                    onClicked: {
                        mainStackView.push(loginView);
                        mainStackView.currentItem.setSelectedDate(maincalendar.selectedDate);
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

            ListView {

                id: eventsListView
                spacing: 4
                clip: true
                header: eventListHeader
                anchors.fill: parent
                anchors.margins: 10
                model: []
                interactive: true

                function getEventsForCurrentDate() {

                    Server.getEventsForDate(maincalendar.selectedDate, function(array) {
                        if (array.length > 0) {

                            var ldate = array[0].selectedDate.toLocaleString(maincalendar.locale, "yyyy-MM-dd");
                            var rdate = maincalendar.selectedDate.toLocaleString(maincalendar.locale, "yyyy-MM-dd");

                            if (ldate !== rdate) {
                                console.log("Loaded incorrect date");
                                return;
                            }
                        }

                        model = array
                    }, function(request) {
                        messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't get list of events";
                        messageDialog.open();
                    });
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

                                    var localtz = -(new Date()).getTimezoneOffset()/60;
                                    var startTime = Server.convertDateFromToTimezone(modelData.startTime, localtz, modelData.timezone);
                                    var endTime = Server.convertDateFromToTimezone(modelData.endTime, localtz, modelData.timezone);
                                    var tz = " "+Server.getTimezoneStringFromOffset(Server.getTimezoneOffset(modelData.timezone));

                                    if (Server.getTimezoneOffset(modelData.timezone) === localtz) {
                                        tz = "";
                                    }

                                    "&nbsp;&nbsp;<b>From:</b> " + startTime.toLocaleString(maincalendar.locale, "yyyy-MM-dd HH:mm") + tz + "<br/>" +
                                    "&nbsp;&nbsp;<b>To:</b> " + endTime.toLocaleString(maincalendar.locale, "yyyy-MM-dd HH:mm") + tz;
                                }
                                font.italic: true
                                font.pointSize: 11
                            }
                        }


                        MouseArea {

                            width: parent.width
                            height: parent.height
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onPressAndHold: {
                                contextMenu.popup();
                                currentEventRectangle.hoverColor = "#EEEEEE"
                            }

                            onClicked: {

                                if (mouse.button === Qt.RightButton) {
                                    contextMenu.popup();
                                    currentEventRectangle.hoverColor = "#EEEEEE";
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
                                        modelData.selectedDate = maincalendar.selectedDate;
                                        mainStackView.push(editPage);
                                        mainStackView.currentItem.setEvent(modelData);
                                    }
                                }
                                MenuItem {
                                    text: "Delete"
                                    onTriggered: {
                                        Server.deleteEventFromServer(modelData, function() {
                                            console.log("Event successfully removed");
                                            eventsListView.getEventsForCurrentDate();
                                        }, function(request) {
                                            messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't remove event";
                                            messageDialog.open();
                                        });
                                    }
                                }
                                onClosed: {
                                    currentEventRectangle.hoverColor = "transparent";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function setSelectedDate(date) {
        maincalendar.selectedDate = date;
        eventsListView.getEventsForCurrentDate();
    }
}
