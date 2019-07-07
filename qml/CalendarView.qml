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
                    property bool visibility: false;

                    function getVisibilityForCurrentDate() {

                        var request = new XMLHttpRequest();

                        var date = styleData.date;
                        date.setHours(0, 0, 0, 0);
                        var start = eventModel.fromDateToTimestamp(date);
                        date.setHours(23, 59, 59, 999);
                        var ends = eventModel.fromDateToTimestamp(date);

                        var url = "http://planner.skillmasters.ga/api/v1/events/instances";
                        var dat = root.encodeQueryData({"from": start, "to": ends});
                        url = url + dat;


                        request.onreadystatechange = function() {
                            if (request.readyState === 4) {
                                if (request.status === 200) {
                                    var jsonRes = JSON.parse(request.responseText);
                                    visibility = jsonRes.count > 0;
                                } else {
                                    console.log("HTTP Request failed", request.status);
                                }
                            }
                        }

                        request.open("GET", url);
                        request.setRequestHeader("X-Firebase-Auth", "serega_mem");
                        request.send();

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
                        eventsListView.getEventsForCurrentDate();
                        //eventModel.eventsForDate(maincalendar.selectedDate);
                        //console.log("Click")
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

                id: eventsListView
                spacing: 4
                clip: true
                header: eventListHeader
                anchors.fill: parent
                anchors.margins: 10
                model: []
                interactive: true

                Component.onCompleted: {
                    getEventsForCurrentDate()
                }

                function getEventsForCurrentDate() {

                    var array = [];
                    model = array;

                    var request = new XMLHttpRequest();

                    var date = maincalendar.selectedDate;
                    date.setHours(0, 0, 0, 0);
                    var start = eventModel.fromDateToTimestamp(date);
                    date.setHours(23, 59, 59, 999);
                    var ends = eventModel.fromDateToTimestamp(date);

                    var url = "http://planner.skillmasters.ga/api/v1/events/instances";
                    var dat = root.encodeQueryData({"from": start, "to": ends});
                    url = url + dat;

                    request.onreadystatechange = function() {

                        model = array;

                        if (request.readyState === 4) {
                            if (request.status === 200) {

                                var jsonData = JSON.parse(request.responseText).data;
                                //console.log(jsonData.length);
                                //console.log(jsonData);

                                for (var i = 0; i < jsonData.length; i++) {

                                    var element = jsonData[i];

                                    //console.log("Element", element);

                                    var dataArray = {};
                                    var starttime = Number(element.started_at);
                                    var endtime = Number(element.ended_at);

                                    dataArray.id = element.event_id;
                                    dataArray.patrnid = element.pattern_id;
                                    dataArray.startTime = eventModel.toDateFromTimestamp(starttime);
                                    dataArray.endTime = eventModel.toDateFromTimestamp(endtime);

                                    var nrequest = new XMLHttpRequest();
                                    var nurl = "http://planner.skillmasters.ga/api/v1/events/"+dataArray.id;

                                    nrequest.onreadystatechange = function() {
                                        if (nrequest.readyState === 4) {
                                            if (nrequest.status === 200) {

                                                var njsonData = JSON.parse(nrequest.responseText).data[0];
                                                //console.log(nrequest.responseText);

                                                dataArray.name = njsonData.name;
                                                dataArray.details = njsonData.details;
                                                dataArray.owner = njsonData.owner_id;
                                                dataArray.location = njsonData.location;

                                                //console.log("Data:", dataArray, "Here");

                                                if (!(dataArray in array)) {
                                                    array.push(dataArray);
                                                }

                                                model = array;
                                            }
                                        }
                                    }

                                    nrequest.open("GET", nurl);
                                    nrequest.setRequestHeader("X-Firebase-Auth", "serega_mem");
                                    nrequest.send();

                                }
                            } else {
                                console.log("HTTP Request failed", request.readyState, request.status);
                            }

                            //console.log("Array:", array);
                        }
                    }

                    request.open("GET", url);
                    request.setRequestHeader("X-Firebase-Auth", "serega_mem");
                    request.send();

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
