import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import org.jentucalendar.calendar 1.0

Item {

    id: editWindow
    property var currentEvent
    property string viewEditTitleText: "Edit event"

    Flow {

        id: editRow
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        layoutDirection: Qt.LeftToRight

        Rectangle {

            id: test
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

            Component {
                id: viewEditEventListHeader

                Rectangle {

                    id: mainEditRectangle

                    width: viewEditEventList.width
                    height: viewEditTitle.height
                    //anchors.fill: parent
                    anchors.margins: 10

                    color: "transparent"

                    Label {
                        id: viewEditTitle
                        text: viewEditTitleText
                        font.pointSize: 32
                    }

                    RoundButton {

                        id: closeEditButton
                        width: viewEditTitle.height
                        height: viewEditTitle.height
                        anchors.right: mainEditRectangle.right
                        anchors.margins: 5

                        onClicked: {
                            mainStackView.push(mainPage);
                            mainStackView.currentItem.setSelectedDate(currentEvent.startDate);
                        }

                        onWindowChanged: {
                            console.log(closeEditButton.x, closeEditButton.y, mainEditRectangle.width, viewEditEventListHeader.width, test.width);
                        }

                        text: ""
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }

                    RoundButton {

                        id: saveEditButton
                        width: viewEditTitle.height
                        height: viewEditTitle.height
                        anchors.right: closeEditButton.left
                        anchors.margins: 5

                        text: ""
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(mainPage);
                            mainStackView.currentItem.setSelectedDate(currentEvent.startDate);
                        }
                    }
                }
            }

            Component {
                id: startDatePickerComponent

                Rectangle {
                    height: eventObjectLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventObjectLabel.font
                            text: eventObjectLabel.text
                        }

                        id: eventObjectLabel
                        verticalAlignment: Text.AlignVCenter;
                        height: metricElement.height*1.5

                        text: {
                            var date = "None"
                            if (currentEvent) {
                                var obj = currentEvent.startDate

                                if (obj) {
                                    date = obj.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm");
                                }
                            }

                            "Start event at: \t" + date;
                        }

                        font.bold: true
                        font.pixelSize: 18
                    }

                    RoundButton {
                        id: eventPickerButton

                        width: eventObjectLabel.height
                        height: eventObjectLabel.height
                        anchors.margins: 10
                        anchors.left: eventObjectLabel.right

                        text: ""
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }
                }
            }

            Component {
                id: endDatePickerComponent

                Rectangle {
                    height: eventObjectLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventObjectLabel.font
                            text: eventObjectLabel.text
                        }

                        id: eventObjectLabel
                        verticalAlignment: Text.AlignVCenter;
                        height: metricElement.height*1.5

                        text: {
                            var date = "None"
                            if (currentEvent) {
                                var obj = currentEvent.endDate

                                if (obj.toString() !== "Invalid Date") {
                                    console.log("I'm here with", obj.toString())
                                    date = obj.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm");
                                }
                            }

                            "End event at: \t" + date;
                        }

                        font.bold: true
                        font.pixelSize: 18
                    }

                    RoundButton {
                        id: eventPickerButton

                        width: eventObjectLabel.height
                        height: eventObjectLabel.height
                        anchors.margins: 10
                        anchors.left: eventObjectLabel.right

                        text: ""
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }
                }
            }

            Component {
                id: repeatorSwitcherComponent

                Rectangle {
                    height: repeatEventLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: repeatEventLabel.font
                            text: repeatEventLabel.text
                        }

                        id: repeatEventLabel
                        height: metricElement.height*1.5

                        text: "Repeat event: "

                        font.bold: true
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter;
                    }
                }
            }

            Component {
                id: eventNameComponent

                Rectangle {
                    height: eventNameLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventNameLabel.font
                            text: eventNameLabel.text
                        }

                        id: eventNameLabel
                        height: metricElement.height

                        text: "Name: "

                        font.bold: true
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter;
                    }
                }
            }

            ListView {
                id: viewEditEventList
                spacing: 4
                clip: true

                header: viewEditEventListHeader
                anchors.fill: parent
                anchors.margins: 10

                model: editBlocksModel

                delegate: Rectangle {
                    width: viewEditEventList.width
                    height: eventObjectLoader.height + 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 10

                    Loader {
                        id: eventObjectLoader
                        sourceComponent: switch(index) {
                            case 0: return eventNameComponent

                            case 1: return startDatePickerComponent
                            case 2: return endDatePickerComponent

                            case 3: return repeatorSwitcherComponent
                        }
                    }
                }
                /*
                delegate: Component{
                    Loader {
                        sourceComponent: switch(index) {
                            case 0: return eventNameComponent

                            case 1:
                            case 2: return datePickerComponent

                            case 3: return repeatorSwitcherComponent
                        }
                    }
                }
                */

            }

            ListModel {
                id: editBlocksModel

                ListElement {index: 0}
                ListElement {index: 1}
                ListElement {index: 2}
                ListElement {index: 3}
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
        }
    }

    function setEvent(modelobj) {
        viewEditTitleText = "Edit event";
        currentEvent = modelobj;
    }

    function setNewEvent(date) {
        viewEditTitleText = "New event";
        currentEvent = eventModel.createEvent();
        currentEvent.startDate = date;
    }

    function setNewUpdatableEvent(modelobj) {
        viewEditTitleText = "New event";
        currentEvent = modelobj;
    }
}
