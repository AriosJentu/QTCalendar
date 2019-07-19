import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as OldContr
import QtQuick.Dialogs 1.2
import "qrc:/src/client.js" as Client;

Item {

    id: editWindow
    property var currentEvent
    property bool isNewEvent: false
    property string startDateString: ""
    property string endDateString: ""

    MessageDialog {
        id: messageDialog
        text: ""
    }

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

            function getDateString(fromdate) {
                var date = "None"
                if (currentEvent) {
                    var obj = fromdate;

                    if (obj) {
                        var localtz = -(new Date()).getTimezoneOffset()/60;
                        var convTime = Client.convertDateFromToTimezone(obj, localtz, currentEvent.timezone);
                        var tz = Client.getTimezoneStringFromOffset(Client.getTimezoneOffset(currentEvent.timezone))

                        date = convTime.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm") + " " + tz;
                    }
                }
                return date;
            }

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
                        width: viewEditTitle.height*1.2-10
                        height: viewEditTitle.height*1.2-10
                        anchors.right: mainEditRectangle.right
                        anchors.margins: 5

                        onClicked: {
                            mainStackView.push(mainPage);
                            mainStackView.currentItem.setSelectedDate(currentEvent.startTime);
                        }

                        text: Client.ICONS.back
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }

                    RoundButton {

                        id: saveEditButton
                        width: viewEditTitle.height*1.2-10
                        height: viewEditTitle.height*1.2-10
                        anchors.right: closeEditButton.left
                        anchors.margins: 5

                        text: Client.ICONS.save
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {

                            if (currentEvent.startTime > currentEvent.endTime) {

                                messageDialog.text = "You can't set start date later than end date";
                                messageDialog.open();

                            } else {

                                Client.postEventToServer(currentEvent, function() {
                                    mainStackView.push(mainPage);
                                    mainStackView.currentItem.setSelectedDate(currentEvent.startTime);
                                }, function(request) {
                                    messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't post event to server\n" + request.responseText;
                                    messageDialog.open();
                                }, !isNewEvent)
                            }

                        }
                    }
                }
            }

            Component {
                id: startDatePickerComponent

                Rectangle {
                    width: startDatePickerComponent.width
                    height: eventStartObjectLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventStartObjectLabel.font
                            text: eventStartObjectLabel.text
                        }

                        id: eventStartObjectLabel
                        height: metricElement.height*1.5
                        wrapMode: Label.Wrap

                        text: {
                            "<b>Start event at:</b> " + startDateString;
                        }
                    }

                    RoundButton {
                        id: eventPickerButton

                        width: eventStartObjectLabel.height*1.4
                        height: eventStartObjectLabel.height*1.4
                        anchors.margins: 10
                        x: viewEditEventList.width - width

                        text: Client.ICONS.picker
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
                    height: eventEndObjectLabel.height + 10

                    Label {

                        TextMetrics {
                            id: metricElement
                            font: eventEndObjectLabel.font
                            text: eventEndObjectLabel.text
                        }

                        id: eventEndObjectLabel
                        height: metricElement.height*1.5
                        wrapMode: Label.Wrap

                        text: {
                            "<b>End event at:</b> " + endDateString;
                        }
                    }

                    RoundButton {
                        id: eventPickerButton

                        width: eventEndObjectLabel.height*1.4
                        height: eventEndObjectLabel.height*1.4
                        anchors.margins: 10
                        x: viewEditEventList.width - width

                        text: Client.ICONS.picker
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
                        wrapMode: Label.Wrap

                        text: {
                            var repeats = "None"

                            if (currentEvent && currentEvent.reprule) {
                                repeats = currentEvent.reprule;
                            }

                            "<b>Repeat event:</b> " + Client.convertRRuleToReadableString(repeats);
                        }
                    }

                    RoundButton {
                        id: eventRepeatEditorButton

                        width: repeatEventLabel.height*1.4
                        height: repeatEventLabel.height*1.4
                        anchors.margins: 10
                        x: viewEditEventList.width - width

                        text: Client.ICONS.edit_evt
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(editRuleView);
                            mainStackView.currentItem.loadEvent(currentEvent, isNewEvent);
                        }
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

                            placeholderText: "Event name"

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
                    }

                    ComboBox {

                        width: viewEditEventList.width - x - 10
                        height: eventTimezoneLabel.height + 10
                        anchors.left: eventTimezoneLabel.right

                        property var array: []

                        id: eventTimezonesCombobox
                        model: {
                            array = Client.getListOfTimezones()
                            array[0]
                        }
                        currentIndex: {
                            var tzindex = "GMT";
                            if (currentEvent && currentEvent.timezone) {
                                tzindex = currentEvent.timezone;
                            }
                            Client.getTimezoneIndex(tzindex);
                        }

                        onCurrentIndexChanged: {
                            currentEvent.timezone = Client.getTimezoneStringFromOffset(array[1][currentIndex].offset)
                            startDateString = test.getDateString(currentEvent.startTime);
                            endDateString = test.getDateString(currentEvent.endTime);
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
                        wrapMode: Label.Wrap

                        text: {

                            var location = "Unknown"
                            if (currentEvent && currentEvent.location) {
                                location = currentEvent.location;
                            }

                            "<b>Location:</b> " + location;
                        }
                    }


                    RoundButton {
                        id: eventOnMapButton

                        width: eventOnMapLabel.height*1.4
                        height: eventOnMapLabel.height*1.4
                        anchors.margins: 10
                        x: viewEditEventList.width - width

                        text: Client.ICONS.map
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(mapView);
                            mainStackView.currentItem.loadEvent(currentEvent, false, isNewEvent);
                        }
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

            ScrollView {

                width: parent.width-10
                height: parent.height - 10
                anchors.margins: 1
                anchors.fill: parent

                TextArea {

                    text: {
                        var details = "None"
                        if (currentEvent && typeof(currentEvent.details) == "string") {
                            var obj = currentEvent.details
                            details = obj;
                        }
                        details
                    }

                    font.pointSize: 14
                    placeholderText: "Event descriptions"

                    onTextChanged: {
                        if (currentEvent && typeof(currentEvent.details) == "string") {
                            currentEvent.details = text;
                        }
                    }
                }
            }
        }
    }

    function setEvent(modelobj, isnew=false) {
        isNewEvent = isnew;
        currentEvent = modelobj;

        startDateString = test.getDateString(currentEvent.startTime);
        endDateString = test.getDateString(currentEvent.endTime);
    }

    function setNewEvent(date) {
        isNewEvent = true;

        currentEvent = Client.generateEmptyEvent();

        currentEvent.id = 0;
        currentEvent.patrnid = 0;

        currentEvent.startTime = new Date(date);
        currentEvent.endTime = new Date(date);

        startDateString = test.getDateString(currentEvent.startTime);
        endDateString = test.getDateString(currentEvent.endTime);

        currentEvent.timezone = Client.getTimezoneStringFromOffset(-(new Date()).getTimezoneOffset()/60);
    }
}
