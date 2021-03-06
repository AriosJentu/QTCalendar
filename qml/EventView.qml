import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.1
import "qrc:/src/client.js" as Client;

Item {

    id: eventWindow
    //anchors.fill: parent

    property string viewEventDayLabelText: "29"
    property string viewEventStandaloneDayNameText: "Wednesday"
    property string viewEventMonthYearNameText: "September 2019"

    property var currentEvent
    property string sharingToken: ""

    property string dateFormat: "d MMMM yyyy, hh:mm"

    MessageDialog {
        id: messageDialog
        text: ""
    }

    Dialog {
        id: tokenDialog
        title: "Sharing Token"
        standardButtons: StandardButton.Close
        height: tokenField.height*4
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        TextField {
            id: tokenField
            text: sharingToken
            readOnly: true
            selectByMouse: true
        }
    }

    Dialog {
        id: sharingDialog
        title: "Select action for sharing"
        standardButtons: StandardButton.Apply | StandardButton.Cancel
        height: checkRead.height*6
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        onApplied: {
            Client.shareEvent(currentEvent, [checkRead.checked, checkUpdate.checked, checkDelete.checked], function(string) {
                sharingToken = string;
                close();
                tokenDialog.open();
            }, function(request) {
                messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't share event\n" + request.responseText;
                messageDialog.open();
            })
        }

        CheckBox {
            id: checkRead
            text: "Read"
        }

        CheckBox {
            id: checkUpdate
            text: "Update"
            anchors.top: checkRead.bottom
        }

        CheckBox {
            id: checkDelete
            text: "Delete"
            anchors.top: checkUpdate.bottom
        }
    }


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

                        text: Client.ICONS.back
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                    }

                    RoundButton {
                        id: editEventButton
                        width: viewEventDayLabel.height-10
                        height: viewEventDayLabel.height-10
                        anchors.right: closeEventButton.left
                        anchors.margins: 5

                        text: Client.ICONS.edit_evt
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

                        text: Client.ICONS.remove_evt
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            Client.deleteEventFromServer(currentEvent, function() {
                                console.log("Event successfully removed");
                                mainStackView.push(mainPage);
                                mainStackView.currentItem.setSelectedDate(currentEvent.startTime);
                            }, function(request) {
                                messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't remove event\n" + request.responseText;
                                messageDialog.open();
                            });

                        }
                    }

                    RoundButton {
                        id: eventOnMapButton
                        width: viewEventDayLabel.height-10
                        height: viewEventDayLabel.height-10
                        anchors.right: deleteEventButton.left
                        anchors.margins: 5

                        text: Client.ICONS.map
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20
                        enabled: (currentEvent && currentEvent.location) || false

                        onClicked: {
                            mainStackView.push(mapView);
                            mainStackView.currentItem.loadEvent(currentEvent, true, false);
                        }
                    }

                    RoundButton {
                        id: shareEvent
                        width: viewEventDayLabel.height-10
                        height: viewEventDayLabel.height-10
                        anchors.right: eventOnMapButton.left
                        anchors.margins: 5

                        text: Client.ICONS.share
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: sharingDialog.open();
                    }
                }
            }

            Component {
                id: viewTasksListHeader

                Rectangle {

                    width: tasksListView.width
                    height: viewTaskTitle.height
                    anchors.margins: 10

                    Label {
                        id: viewTaskTitle
                        text: "Tasks"
                        font.pointSize: 30
                    }

                    RoundButton {
                        id: addTaskButton
                        width: viewTaskTitle.height*1.3-10
                        height: viewTaskTitle.height*1.3-10
                        anchors.right: parent.right
                        anchors.margins: 5

                        text: Client.ICONS.new_evt
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: {
                            mainStackView.push(editTaskView);
                            mainStackView.currentItem.setTask(Client.generateEmptyTask(currentEvent), currentEvent, true);
                        }
                    }


                    RoundButton {
                        id: refreshTasksButton
                        width: viewTaskTitle.height*1.3-10
                        height: viewTaskTitle.height*1.3-10
                        anchors.right: addTaskButton.left
                        anchors.margins: 5

                        text: Client.ICONS.refresh
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: tasksListView.getTasksForCurrentEvent();
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
                            wrapMode: Label.Wrap
                            text: {
                                if (currentEvent) {

                                    var localtz = -(new Date()).getTimezoneOffset()/60;
                                    var tz = " "+Client.getTimezoneStringFromOffset(Client.getTimezoneOffset(currentEvent.timezone));
                                    var localStartTime = "<br/>&nbsp;&nbsp;" + "<i>" + currentEvent.startTime.toLocaleString(Qt.locale(), dateFormat) + " (Local Time)</i>";
                                    var localEndTime = "<br/>&nbsp;&nbsp;" + "<i>" + currentEvent.endTime.toLocaleString(Qt.locale(), dateFormat) + " (Local Time)</i>";

                                    if (Client.getTimezoneOffset(currentEvent.timezone) === localtz) {
                                        tz = "";
                                        localStartTime = "";
                                        localEndTime = "";
                                    }

                                    switch (index) {
                                    case 0:
                                        "&nbsp;&nbsp;<b></b>" + currentEvent.name;
                                        break;
                                    case 1:
                                        var startTime = Client.convertDateFromToTimezone(currentEvent.startTime, localtz, currentEvent.timezone);
                                        "&nbsp;&nbsp;<b></b>" + startTime.toLocaleString(Qt.locale(), dateFormat) + tz + localStartTime;
                                        break;
                                    case 2:
                                        var endTime = Client.convertDateFromToTimezone(currentEvent.endTime, localtz, currentEvent.timezone);
                                        "&nbsp;&nbsp;<b></b>" + endTime.toLocaleString(Qt.locale(), dateFormat) + tz + localEndTime;
                                        break;
                                    case 3:
                                        var repeats = "None"
                                        if (currentEvent && currentEvent.reprule) {
                                            repeats = currentEvent.reprule;
                                        }
                                        "&nbsp;&nbsp;<b></b>" + Client.convertRRuleToReadableString(repeats);
                                        break;
                                    case 4:
                                        var array = Client.getListOfTimezones();
                                        var tzindex = Client.getTimezoneIndex(currentEvent.timezone);
                                        "&nbsp;&nbsp;<b></b>" + array[0][tzindex] + " ("+currentEvent.timezone+")";
                                        break;
                                    case 5:
                                        var location = "Unknown";
                                        if (currentEvent && currentEvent.location) {
                                            location = currentEvent.location;
                                        }
                                        "&nbsp;&nbsp;<b></b>" + location;
                                        break;
                                    case 6:
                                        "&nbsp;&nbsp;<b></b>" + Client.parseTimeToTypes(currentEvent.duration).join(" ");
                                        break;
                                    case 7:
                                        "&nbsp;&nbsp;<b></b>" + currentEvent.id;
                                        break;
                                    default:
                                        "&nbsp;&nbsp;<b></b>" + "Event"
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

                ListElement {
                    type: "Duration:"
                    index: 6
                }

                ListElement {
                    type: "Event ID:"
                    index: 7
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

            Rectangle {
                id: eventDescriptsElement
                width: parent.width
                height: parent.height*0.2
                border.color: Qt.darker("#F4F4F4", 1.2)

                ScrollView {
                    width: parent.width
                    anchors.margins: 10
                    anchors.fill: parent
                    clip: true

                    Label {
                        id: eventInfoLabel
                        wrapMode: Text.Wrap
                        text: currentEvent ? currentEvent.details : "None"
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height*0.8 - eventRow.spacing
                border.color: Qt.darker("#F4F4F4", 1.2)
                anchors.top: eventDescriptsElement.bottom
                anchors.topMargin: eventRow.spacing

                ListView {

                    id: tasksListView
                    spacing: 4
                    clip: true
                    header: viewTasksListHeader
                    anchors.fill: parent
                    anchors.margins: 10

                    model: []
                    interactive: true

                    function getTasksForCurrentEvent() {
                        Client.getListOfTasksForEvent(currentEvent, function(array) {
                            model = array;
                        }, Client.basicErrorFunc);
                    }

                    delegate: Rectangle {
                        width: tasksListView.width
                        height: taskItemColumn.height
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#EEEEEE"
                        }

                        Rectangle {

                            property string hoverColor: "transparent"
                            id: currentTaskRectangle
                            width: parent.width
                            height: parent.height
                            color: hoverColor

                            Column {
                                id: taskItemColumn
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                height: descrLabel.height + nameLabel.height + deadlineLabel.height + statusLabel.height + 8

                                Label {
                                    id: nameLabel
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                    text: modelData.name
                                    font.bold: true
                                }

                                Label {
                                    id: descrLabel
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                    text: "  "+modelData.details
                                }

                                Label {
                                    id: deadlineLabel
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                    text: {
                                        var localtz = -(new Date()).getTimezoneOffset()/60;
                                        var deadlineTime = Client.convertDateFromToTimezone(modelData.deadline, localtz, currentEvent.timezone);
                                        var tz = " "+Client.getTimezoneStringFromOffset(Client.getTimezoneOffset(currentEvent.timezone));

                                        if (Client.getTimezoneOffset(currentEvent.timezone) === localtz) {
                                            tz = "";
                                        }

                                        "  " + deadlineTime.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm") + tz
                                    }
                                }

                                Label {
                                    id: statusLabel
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                    text: "  " + Client.getReadableStateFromTaskState(modelData.status);
                                    font.italic: true
                                }
                            }

                            MouseArea {

                                width: taskItemColumn.width
                                height: taskItemColumn.height
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onPressAndHold: {
                                    taskContextMenu.popup();
                                    currentTaskRectangle.hoverColor = "#EEEEEE"
                                }

                                onClicked: {

                                    if (mouse.button === Qt.RightButton) {
                                        taskContextMenu.popup();
                                        currentTaskRectangle.hoverColor = "#EEEEEE";
                                    } else {
                                        mainStackView.push(editTaskView);
                                        mainStackView.currentItem.setTask(modelData, currentEvent, false);
                                    }

                                }

                                Menu {
                                    id: taskContextMenu
                                    MenuItem {
                                        text: "Edit"
                                        onTriggered: {
                                            mainStackView.push(editTaskView);
                                            mainStackView.currentItem.setTask(modelData, currentEvent, false);
                                        }
                                    }
                                    MenuItem {
                                        text: "Delete"
                                        onTriggered: {
                                            Client.deleteTaskForEventFromServer(modelData, function() {
                                                console.log("Task successfully removed");
                                                tasksListView.getTasksForCurrentEvent();
                                            }, function(request) {
                                                messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't remove event\n" + request.responseText;
                                                messageDialog.open();
                                            });
                                        }
                                    }

                                    onClosed: {
                                        currentTaskRectangle.hoverColor = "transparent";
                                    }
                                }
                            }
                        }
                    }
                }
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

        tasksListView.getTasksForCurrentEvent();
    }
}
