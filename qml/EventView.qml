import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import "qrc:/src/server.js" as Server;

Item {

    id: eventWindow
    //anchors.fill: parent

    property string viewEventDayLabelText: "29"
    property string viewEventStandaloneDayNameText: "Wednesday"
    property string viewEventMonthYearNameText: "September 2019"

    property var currentEvent

    property string dateFormat: "d MMMM yyyy, hh:mm"

    Flow {
        id: eventRow
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        layoutDirection: Qt.LeftToRight

        Rectangle {

            width: {
                var res = parent.width*0.5 - parent.spacing;
                if (parent.width < parent.height) {
                    res = parent.width;
                }
                res;
            }

            height: {
                var res = parent.height*0.4 - parent.spacing;
                if (parent.width > parent.height) {
                    res = parent.height;
                }
                res;
            }
            border.color: Qt.darker("#F4F4F4", 1.2)

            Component {

                id: viewEventListHeader

                Rectangle {

                    width: eventParamsListView.width
                    height: viewEventDayLabel.height
                    //anchors.fill: eventParamsListView
                    anchors.margins: 10

                    color: "transparent"

                    Row {
                        id: viewEventDayRow
                        width: parent.width
                        height: parent.height
                        spacing: 10

                        Label {
                            id: viewEventDayLabel
                            text: viewEventDayLabelText
                            font.pointSize: 35
                        }

                        Column {
                            height: viewEventDayLabel.height
                            anchors.margins: 5

                            Label {
                                id: viewEventStandaloneDayName
                                readonly property var options: { weekday: "long" }
                                text: viewEventStandaloneDayNameText
                                font.pointSize: 18
                            }

                            Label {
                                id: viewEventMonthYearName
                                text: viewEventMonthYearNameText
                                font.pointSize: 12
                            }


                        }
                    }

                    RoundButton {
                        id: closeEventButton
                        width: viewEventDayLabel.height-10
                        height: viewEventDayLabel.height-10
                        anchors.right: viewEventDayRow.right
                        anchors.margins: 5

                        onClicked: {
                            mainStackView.push(mainPage);
                            mainStackView.currentItem.setSelectedDate(currentEvent.selectedDate);
                        }

                        text: Server.ICONS.back
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }

                    RoundButton {
                        id: editEventButton
                        width: viewEventDayLabel.height-10
                        height: viewEventDayLabel.height-10
                        anchors.right: closeEventButton.left
                        anchors.margins: 5

                        text: Server.ICONS.edit_evt
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(editPage);
                            mainStackView.currentItem.setEvent(currentEvent);
                        }
                    }

                    RoundButton {
                        id: deleteEventButton
                        width: viewEventDayLabel.height-10
                        height: viewEventDayLabel.height-10
                        anchors.right: editEventButton.left
                        anchors.margins: 5

                        text: Server.ICONS.remove_evt
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            Server.deleteEventFromServer(currentEvent, function() {
                                console.log("Event successfully removed");
                                mainStackView.push(mainPage);
                                mainStackView.currentItem.setSelectedDate(currentEvent.startTime);
                            }, Server.basicErrorFunc);

                        }
                    }
                }
            }

            ListView {

                id: eventParamsListView
                spacing: 4
                clip: true
                header: viewEventListHeader
                anchors.fill: parent
                anchors.margins: 10

                model: titleListElements

                delegate: Rectangle {
                    width: eventParamsListView.width
                    height: eventTypeValueLabel.height + eventTypeLabel.height + 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 10

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#EEEEEE"
                    }

                    Column {
                        id: currentEventParamsColumn
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.right: parent.right
                        height: eventTypeValueLabel.height + eventTypeLabel.height + 8

                        Label {
                            id: eventTypeLabel
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: type
                            font.bold: true
                        }

                        Label {
                            id: eventTypeValueLabel
                            width: parent.width
                            wrapMode: Text.Wrap
                            text: {
                                if (currentEvent) {

                                    switch (index) {
                                    case 0:
                                        currentEvent.name;
                                        break;
                                    case 1:
                                        currentEvent.startTime.toLocaleString(Qt.locale(), dateFormat);
                                        break;
                                    case 2:
                                        currentEvent.endTime.toLocaleString(Qt.locale(), dateFormat);
                                        break;
                                    case 3:
                                        var repeats = "None"
                                        if (currentEvent && currentEvent.reprule) {
                                            repeats = currentEvent.reprule;
                                        }
                                        repeats;
                                        break;
                                    case 4:
                                        var array = Server.getListOfTimezones();
                                        console.log(currentEvent.timezone);
                                        var tzindex = Server.getTimezoneIndex(currentEvent.timezone);
                                        array[0][tzindex];
                                        break;
                                    case 5:
                                        var location = "Unknown";
                                        if (currentEvent && currentEvent.location) {
                                            location = currentEvent.location;
                                        }
                                        location;
                                        break;
                                    default:
                                        "Event"
                                        break;
                                    }
                                } else {
                                    "None"
                                }
                            }
                        }
                    }
                }
            }

            ListModel {
                id: titleListElements

                ListElement {
                    type: "Name:"
                    index: 0
                }

                ListElement {
                    type: "Start at:"
                    index: 1
                }

                ListElement {
                    type: "Finish at:"
                    index: 2
                }

                ListElement {
                    type: "Repeats:"
                    index: 3
                }

                ListElement {
                    type: "Time Zone:"
                    index: 4
                }

                ListElement {
                    type: "Location:"
                    index: 5
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
                var res = parent.height*0.6;
                if (parent.width > parent.height) {
                    res = parent.height;
                }
                res;
            }
            border.color: Qt.darker("#F4F4F4", 1.2)

            Label {
                id: eventInfoLabel
                width: parent.width
                wrapMode: Text.Wrap
                text: currentEvent ? currentEvent.details : "None"
                anchors.fill: parent
                anchors.margins: 10
            }

        }

    }

    function setEvent(modelobj) {

        currentEvent = modelobj;

        viewEventDayLabelText = modelobj.selectedDate.getDate()

        viewEventStandaloneDayNameText = Qt.locale().standaloneDayName(
            modelobj.selectedDate.getDay(),
            Locale.LongFormat)

        viewEventMonthYearNameText = Qt.locale().standaloneMonthName(
            modelobj.selectedDate.getMonth()) +
            modelobj.selectedDate.toLocaleDateString(Qt.locale(), " yyyy")
    }
}
