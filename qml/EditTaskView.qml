import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as OldContr
import QtQuick.Dialogs 1.2
import "qrc:/src/client.js" as Client

Item {

    id: editTaskView

    property var currentTask
    property var currentEvent
    property var isNew

    MessageDialog {
        id: messageDialog
        text: ""
    }

    function setTask(task, event, isNewTask) {
        currentTask = task;
        currentEvent = event;
        isNew = isNewTask;
    }

    function pushInfo() {
        mainStackView.push(viewPage);
        mainStackView.currentItem.setEvent(currentEvent);
    }

    function saveInfo() {
        currentTask.name = taskNameTextField.text;
        currentTask.details = taskDescriptionsTextField.text;
    }

    Rectangle {

        id: editTaskRow
        anchors.fill: parent
        anchors.margins: 5

        Rectangle {

            id: editTaskFrame

            width: parent.width
            height: parent.height
            border.color: Qt.darker("#F4F4F4", 1.2)

            Rectangle {

                anchors.fill: parent
                anchors.margins: 5

                Label {

                    TextMetrics {
                        id: nmetricElement
                        font: viewTaskTitle.font
                        text: viewTaskTitle.text
                    }

                    id: viewTaskTitle
                    width: nmetricElement.width
                    height: nmetricElement.height
                    text: (isNew ? "New" : "Edit") +" Task"
                    font.pointSize: 32
                    anchors.margins: 10
                }

                Label {

                    TextMetrics {
                        id: metricElement
                        font: taskNameLabel.font
                        text: taskNameLabel.text
                    }

                    id: taskNameLabel
                    width: metricElement.width*1.5
                    height: metricElement.height*3
                    text: "Name: "
                    font.bold: true
                    anchors.top: viewTaskTitle.bottom
                    anchors.margins: 10
                    anchors.topMargin: 10

                }

                TextField {

                    id: taskNameTextField

                    anchors.left: taskNameLabel.right
                    anchors.top: viewTaskTitle.bottom

                    width: parent.width - taskNameLabel.width*1.2
                    height: metricElement.height*2
                    text: {
                        if (currentTask && currentTask.name) {
                            currentTask.name;
                        } else {
                            ""
                        }
                    }
                    placeholderText: "Task name"
                    anchors.margins: 10

                    onTextChanged: {
                        if (currentTask && typeof(currentTask.name) == "string") {
                            currentTask.name = text;
                        }
                    }
                }

                Label {

                    TextMetrics {
                        id: mmetricElement
                        font: taskDescriptionsLabel.font
                        text: taskDescriptionsLabel.text
                    }

                    id: taskDescriptionsLabel
                    width: mmetricElement.width*1.3
                    height: mmetricElement.height*3
                    text: "Details: "
                    font.bold: true
                    anchors.top: taskNameTextField.bottom
                    anchors.margins: 10
                    anchors.topMargin: 10
                }

                TextField {

                    id: taskDescriptionsTextField

                    anchors.left: taskDescriptionsLabel.right
                    anchors.top: taskNameTextField.bottom

                    width: parent.width - taskDescriptionsLabel.width*1.2
                    height: metricElement.height*2
                    text: {
                        if (currentTask && currentTask.details) {
                            currentTask.details;
                        } else {
                            "";
                        }

                    }
                    placeholderText: "Task details"
                    anchors.margins: 10

                    onTextChanged: {
                        if (currentTask && typeof(currentTask.details) == "string") {
                            currentTask.details = text;
                        }
                    }
                }

                Label {

                    TextMetrics {
                        id: dmetricElement
                        font: taskDeadlineLabel.font
                        text: taskDeadlineLabel.text
                    }

                    id: taskDeadlineLabel
                    width: dmetricElement.width*1.3
                    height: dmetricElement.height*2
                    text: {

                        var date = "None"
                        if (currentTask) {
                            var obj = currentTask.deadline;

                            if (obj && currentEvent && currentEvent.timezone) {

                                var localtz = -(new Date()).getTimezoneOffset()/60;
                                var convTime = Client.convertDateFromToTimezone(obj, localtz, currentEvent.timezone);
                                var tz = Client.getTimezoneStringFromOffset(Client.getTimezoneOffset(currentEvent.timezone))

                                if (Client.getTimezoneOffset(currentEvent.timezone) === localtz) {
                                    tz = "";
                                }

                                date = convTime.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm") + " " + tz;
                            }
                        }

                        "<b>Deadline:</b> &nbsp;&nbsp;&nbsp;&nbsp;" + date
                    }

                    anchors.top: taskDescriptionsTextField.bottom
                    anchors.margins: 10
                    anchors.topMargin: 20
                }

                RoundButton {
                    id: taskDeadlinePickerButton

                    width: taskDeadlineLabel.height*1.4
                    height: taskDeadlineLabel.height*1.4
                    anchors.margins: 10
                    anchors.top: taskDescriptionsTextField.bottom
                    x: parent.width - width

                    text: Client.ICONS.picker
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        mainStackView.push(selectorView);
                        mainStackView.currentItem.loadTask(currentTask, currentEvent, isNew);
                    }
                }

                Label {

                    TextMetrics {
                        id: zmetricElement
                        font: taskStatusLabel.font
                        text: taskStatusLabel.text
                    }

                    id: taskStatusLabel
                    width: zmetricElement.width*1.4
                    height: zmetricElement.height*2

                    text: "Status:"

                    font.bold: true
                    anchors.top: taskDeadlinePickerButton.bottom
                    anchors.margins: 10
                    anchors.topMargin: 20
                }

                ComboBox {

                    id: taskStatusComboBox

                    width: parent.width - taskStatusLabel.width*1.2
                    height: taskStatusLabel.height*1.2
                    anchors.left: taskStatusLabel.right
                    anchors.top: taskDeadlinePickerButton.bottom

                    model: Client.getTaskReadableStates()
                    anchors.margins: 10

                    currentIndex: {
                        var index = 0
                        if (currentTask && currentTask.status) {
                            console.log(currentTask.status);
                            index = Client.getIndexOfState(currentTask.status);
                        }
                        index;
                    }

                    onCurrentIndexChanged: {
                        if (currentTask && currentTask.status) {
                            currentTask.status = Client.getStateFromIndex(currentIndex);
                            console.log(currentTask.status);
                        }
                    }
                }
            }

            Rectangle {

                anchors.margins: 5
                anchors.right: parent.right
                anchors.top: parent.top

                RoundButton {
                    id: cancelTaskButton
                    width: textForButtonSize.height*1.2-10
                    height: textForButtonSize.height*1.2-10
                    anchors.right: parent.right
                    anchors.margins: 5

                    text: Client.ICONS.back
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: pushInfo()
                }

                RoundButton {

                    id: acceptTaskButton
                    width: textForButtonSize.height*1.2-10
                    height: textForButtonSize.height*1.2-10
                    anchors.right: cancelTaskButton.left
                    anchors.margins: 5

                    text: Client.ICONS.accept
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        saveInfo();
                        Client.postTaskForEventToServer(currentTask, function() {
                            pushInfo();
                        }, function(request) {
                            messageDialog.text = "HTTP Request Failed\nReady State: " + request.readyState + "\nStatus: " + request.status + "\nCan't post task to server";
                            messageDialog.open();
                        }, !isNew);
                    }
                }
            }
        }
    }

    Label {
        id: textForButtonSize
        text: ""
        font.pointSize: 32
    }

}
