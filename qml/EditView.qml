import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as OldContr
import "qrc:/src/server.js" as Server;

Item {

    id: editWindow
    property var currentEvent
    property bool isNewEvent: false

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
                        text: isNewEvent ? "New Event" : "Edit Event"
                        font.pointSize: 32
                    }

                    RoundButton {

                        id: closeEditButton
                        width: viewEditTitle.height-10
                        height: viewEditTitle.height-10
                        anchors.right: mainEditRectangle.right
                        anchors.margins: 5

                        onClicked: {
                            mainStackView.push(mainPage);
                            mainStackView.currentItem.setSelectedDate(currentEvent.startTime);
                        }

                        text: Server.ICONS.back
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }

                    RoundButton {

                        id: saveEditButton
                        width: viewEditTitle.height-10
                        height: viewEditTitle.height-10
                        anchors.right: closeEditButton.left
                        anchors.margins: 5

                        text: Server.ICONS.save
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(mainPage);
                            mainStackView.currentItem.setSelectedDate(currentEvent.startTime);
                        }
                    }
                }
            }

            Component {
                id: startDatePickerComponent

                Rectangle {
                    width: startDatePickerComponent.width
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
                                var obj = currentEvent.startTime

                                if (obj) {
                                    date = obj.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm");
                                }
                            }

                            "<b>Start event at:</b> " + date;
                        }
                    }

                    RoundButton {
                        id: eventPickerButton

                        width: eventObjectLabel.height
                        height: eventObjectLabel.height
                        anchors.margins: 10
                        x: viewEditEventList.width - width*2

                        text: Server.ICONS.picker
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(selectorView);
                            mainStackView.currentItem.loadEvent(currentEvent, true, isNewEvent);
                        }
                    }
                }
            }

            Component {
                id: endDatePickerComponent

                Rectangle {
                    width: endDatePickerComponent.width
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
                                var obj = currentEvent.endTime

                                if (obj.toString() !== "Invalid Date") {
                                    date = obj.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm");
                                }
                            }

                            "<b>End event at:</b> " + date;
                        }
                    }

                    RoundButton {
                        id: eventPickerButton

                        width: eventObjectLabel.height
                        height: eventObjectLabel.height
                        anchors.margins: 10
                        x: viewEditEventList.width - width*2

                        text: Server.ICONS.picker
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(selectorView);
                            mainStackView.currentItem.loadEvent(currentEvent, false, isNewEvent);
                        }
                    }
                }
            }

            Component {
                id: repeatorSwitcherComponent

                Rectangle {
                    width: repeatorSwitcherComponent.width
                    height: repeatEventLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: repeatEventLabel.font
                            text: repeatEventLabel.text
                        }

                        id: repeatEventLabel
                        height: metricElement.height*1.5

                        text: {
                            var repeats = "None"

                            if (currentEvent && currentEvent.reprule) {
                                repeats = currentEvent.reprule;
                            }

                            "<b>Repeat event:</b> " + repeats
                        }

                        verticalAlignment: Text.AlignVCenter;
                    }

                    RoundButton {
                        id: eventRepeatEditorButton

                        width: repeatEventLabel.height
                        height: repeatEventLabel.height
                        anchors.margins: 10
                        x: viewEditEventList.width - width*2

                        text: Server.ICONS.edit_evt
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }
                }
            }

            Component {
                id: eventNameComponent

                Rectangle {
                    width: eventNameComponent.width
                    height: eventNameLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventNameLabel.font
                            text: eventNameLabel.text
                        }

                        id: eventNameLabel
                        width: metricElement.width*0.7
                        height: metricElement.height

                        text: "<b>Name:</b>"

                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {

                        width: viewEditEventList.width - x - 10
                        height: eventNameLabel.height + 10
                        anchors.left: eventNameLabel.right
                        color: "grey"

                        TextField {

                            anchors.fill: parent

                            text: {
                                var name = ""
                                if (currentEvent && typeof(currentEvent.name) == "string") {
                                    name = currentEvent.name;
                                }
                                name
                            }

                            onTextChanged: {
                                if (currentEvent && typeof(currentEvent.name) == "string") {
                                    currentEvent.name = text;
                                }
                            }

                            font.pointSize: 12
                        }
                    }
                }
            }

            Component {
                id: eventTimezoneComponent

                Rectangle {
                    width: eventTimezoneComponent.width
                    height: eventTimezoneLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventTimezoneLabel.font
                            text: eventTimezoneLabel.text
                        }

                        id: eventTimezoneLabel
                        width: metricElement.width*0.7
                        height: metricElement.height*1.5

                        text: "<b>Time Zone:</b>"
                        verticalAlignment: Text.AlignVCenter
                    }

                    ComboBox {

                        width: viewEditEventList.width - x - 10
                        height: eventTimezoneLabel.height + 10
                        anchors.left: eventTimezoneLabel.right

                        property var array: []

                        id: eventTimezonesCombobox
                        model: {
                            array = Server.getListOfTimezones()
                            array[0]
                        }
                        currentIndex: {
                            var tzindex = "GMT";
                            if (currentEvent && currentEvent.timezone) {
                                tzindex = currentEvent.timezone;
                            }
                            Server.getTimezoneIndex(tzindex);
                        }

                        onCurrentIndexChanged: {
                            currentEvent.timezone = Server.getTimezoneStringFromOffset(array[1][currentIndex].offset)
                        }
                    }
                }
            }

            Component {
                id: eventOnMapComponent

                Rectangle {
                    width: eventOnMapComponent.width
                    height: eventOnMapLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventOnMapLabel.font
                            text: eventOnMapLabel.text
                        }

                        id: eventOnMapLabel
                        width: metricElement.width*0.7
                        height: metricElement.height*1.5

                        text: {

                            var location = "Unknown"
                            if (currentEvent && currentEvent.location) {
                                location = currentEvent.location;
                            }

                            "<b>Location:</b> " + location;
                        }
                        verticalAlignment: Text.AlignVCenter
                    }


                    RoundButton {
                        id: eventOnMapButton

                        width: eventOnMapLabel.height
                        height: eventOnMapLabel.height
                        anchors.margins: 10
                        x: viewEditEventList.width - width*2

                        text: Server.ICONS.map
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }
                }
            }

            ListView {
                id: viewEditEventList
                spacing: 4
                clip: true

                header: viewEditEventListHeader
                anchors.fill: parent
                anchors.margins: 15

                model: editBlocksModel

                delegate: Rectangle {
                    width: viewEditEventList.width
                    height: eventObjectLoader.height + 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 10

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#EEEEEE"
                    }

                    Loader {
                        id: eventObjectLoader
                        sourceComponent: switch(index) {
                            case 0: return eventNameComponent

                            case 1: return startDatePickerComponent
                            case 2: return endDatePickerComponent

                            case 3: return repeatorSwitcherComponent
                            case 4: return eventTimezoneComponent
                            case 5: return eventOnMapComponent
                        }
                    }
                }
            }

            ListModel {
                id: editBlocksModel

                ListElement {index: 0}
                ListElement {index: 1}
                ListElement {index: 2}
                ListElement {index: 3}
                ListElement {index: 4}
                ListElement {index: 5}
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

            OldContr.TextArea {

                width: parent.width-10
                height: parent.height - 10
                anchors.fill: parent
                anchors.margins: 1

                text: {
                    var details = "None"
                    if (currentEvent && typeof(currentEvent.details) == "string") {
                        var obj = currentEvent.details
                        details = obj;
                    }
                    details
                }

                font.pointSize: 14

                onTextChanged: {
                    if (currentEvent && typeof(currentEvent.details) == "string") {
                        currentEvent.details = text;
                    }
                }

            }
        }
    }

    function setEvent(modelobj) {
        isNewEvent = false;
        currentEvent = modelobj;
    }

    function setNewEvent(date) {
        isNewEvent = true;

        currentEvent = Server.generateEmptyEvent();

        currentEvent.id = 0;
        currentEvent.patrnid = 0;

        currentEvent.startTime = date;
        currentEvent.endTime = date;
    }

    function setNewUpdatableEvent(modelobj) {
        isNewEvent = true;
        currentEvent = modelobj;
    }
}
