import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import org.jentucalendar.calendar 1.0

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
                            text: {viewEventDayLabelText}
                            font.pointSize: 35
                        }

                        Column {
                            height: viewEventDayLabel.height
                            anchors.margins: 5

                            Label {
                                id: viewEventStandaloneDayName
                                readonly property var options: { weekday: "long" }
                                text: {viewEventStandaloneDayNameText}
                                font.pointSize: 18
                            }

                            Label {
                                id: viewEventMonthYearName
                                text: {viewEventMonthYearNameText}
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
                        }

                        text: "x"
                    }

                    RoundButton {
                        id: editEventButton
                        width: (viewEventDayLabel.height-10)*1.5
                        height: viewEventDayLabel.height-10
                        anchors.right: closeEventButton.left
                        anchors.margins: 5

                        text: "Edit"
                    }

                    RoundButton {
                        id: deleteEventButton
                        width: (viewEventDayLabel.height-10)*2
                        height: viewEventDayLabel.height-10
                        anchors.right: editEventButton.left
                        anchors.margins: 5

                        text: "Delete"

                        onClicked: {
                            console.log("::: Removing event with ID ", currentEvent.id)
                            eventModel.removeEvent(currentEvent.id);
                            mainStackView.push(mainPage);
                            currentEvent = none;
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
                                switch (index) {
                                case 0:
                                    currentEvent.name;
                                    break;
                                case 1:
                                    currentEvent.startDate.toLocaleString(Qt.locale(), dateFormat);
                                    break;
                                case 2:
                                    currentEvent.endDate.toLocaleString(Qt.locale(), dateFormat);
                                    break;
                                default:
                                    "Event"
                                    break;
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
                var res = parent.height*0.6 - parent.spacing;
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
                text: currentEvent.information
                anchors.fill: parent
                anchors.margins: 10
            }

        }

    }

    function setEvent(modelobj) {
        console.log("Changing titles");
        currentEvent = modelobj;
    }
}
