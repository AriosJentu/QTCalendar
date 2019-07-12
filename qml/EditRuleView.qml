import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as OldContr
import "qrc:/src/server.js" as Server

Item {

    id: editRuleView

    property var currentEvent
    property bool isNewEvent: false
    property string singleTypeRepeatString: "day"

    function loadEvent(event, isNew) {
        currentEvent = event;
        isNewEvent = isNew;
    }

    function pushInfo() {
        mainStackView.push(editPage);
        mainStackView.currentItem.setEvent(currentEvent, isNewEvent);
    }

    Component {
        id: repeatEveryComponent

        Rectangle {
            anchors.fill: parent
            anchors.margins: 5

            Label {
                TextMetrics {
                    id: metricElement
                    font: editRuleEveryLabel.font
                    text: editRuleEveryLabel.text
                }

                id: editRuleEveryLabel
                text: "Every "
                width: metricElement.width*1.5
                height: metricElement.height*3
                verticalAlignment: Text.AlignVCenter;
            }

            TextField {

                id: repeatEveryTextBox
                width: metricElement.width*2
                height: metricElement.height*3 - 20
                anchors.left: editRuleEveryLabel.right
                y: 10
                text: "0"
                maximumLength: 3
                validator: RegExpValidator{regExp: /[0-9]+/}

                onTextChanged: {

                    if (text[0] === "0" && text.length > 1) {
                        text = text.substring(1);
                    }

                    if (text == "") {
                        text = "0";
                    }
                }
            }

            Label {
                TextMetrics {
                    id: nmetricElement
                    font: editRuleEveryLabel.font
                    text: editRuleEveryLabel.text
                }

                id: editRuleEveryObjectLabel
                text: singleTypeRepeatString + Server.getEnding(Number(repeatEveryTextBox.text))
                width: metricElement.width*1.5
                height: metricElement.height*3
                anchors.left: repeatEveryTextBox.right
                anchors.leftMargin: 10
                verticalAlignment: Text.AlignVCenter;
            }
        }
    }

    Component {
        id: ruleWeeklyComponent

        Rectangle {

            id: loaderWeeklyRectangle

            GroupBox {
                id: gboxWDItems
                title: "By weekdays"

                Column {
                    spacing: 10

                    CheckBox {
                        id: mondayCheckBox
                        text: "Monday"
                        checked: true
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(mondayCheckBox)
                    }

                    CheckBox {
                        id: tuesdayCheckBox
                        text: "Tuesday"
                        checked: false
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(tuesdayCheckBox)
                    }

                    CheckBox {
                        id: wednesdayCheckBox
                        text: "Wednesday"
                        checked: false
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(wednesdayCheckBox)
                    }

                    CheckBox {
                        id: thursdayCheckBox
                        text: "Thursday"
                        checked: false
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(thursdayCheckBox)
                    }

                    CheckBox {
                        id: fridayCheckBox
                        text: "Friday"
                        checked: false
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(fridayCheckBox)
                    }

                    CheckBox {
                        id: saturdayCheckBox
                        text: "Saturday"
                        checked: false
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(saturdayCheckBox)
                    }

                    CheckBox {
                        id: sundayCheckBox
                        text: "Sunday"
                        checked: false
                        onCheckedChanged: gboxWDItems.onCheckingIsEmpty(sundayCheckBox)
                    }

                }

                function isSomethingChecked() {
                    return mondayCheckBox.checked ||
                            tuesdayCheckBox.checked ||
                            wednesdayCheckBox.checked ||
                            thursdayCheckBox.checked ||
                            fridayCheckBox.checked ||
                            saturdayCheckBox.checked ||
                            sundayCheckBox.checked
                }

                function onCheckingIsEmpty(checkbox) {
                    if (!isSomethingChecked()) {
                        checkbox.checked = true
                    }
                }
            }

            Loader {
                id: loaderWeekly
                sourceComponent: repeatEveryComponent
                anchors.top: gboxWDItems.bottom
            }
        }
    }

    Component {

        id: ruleMonthlyComponent

        Rectangle {

            RadioButton {
                id: radioButtonOnMonthDay
                text: "By month day: "
                checked: true
                anchors.margins: 5
            }

            ComboBox {
                id: selectorDayOnMonthDay
                anchors.left: radioButtonOnMonthDay.right
                model: Server.getIntArray(31, false, 1);
                width: radioButtonOnMonthDay.width/2
                anchors.margins: 5
            }

            RadioButton {
                id: radioButtonOnWeekDay
                anchors.top: radioButtonOnMonthDay.bottom
                text: "By week day: "
                anchors.margins: 5
            }

            ComboBox {
                id: selectorOrdinalOnWeekDay
                anchors.top: radioButtonOnMonthDay.bottom
                anchors.left: radioButtonOnWeekDay.right
                model: Server.getOrdinals();
                width: radioButtonOnWeekDay.width
                anchors.margins: 5
            }

            ComboBox {
                id: selectorDaysOnWeekDay
                anchors.top: radioButtonOnMonthDay.bottom
                anchors.left: selectorOrdinalOnWeekDay.right
                model: Server.getWeeks()[0];
                width: radioButtonOnWeekDay.width*1.2
                anchors.margins: 5
            }

            Loader {
                id: loaderWeekly
                sourceComponent: repeatEveryComponent
                anchors.top: radioButtonOnWeekDay.bottom
                anchors.margins: 5
            }
        }
    }

    Component {

        id: ruleYearlyComponent

        Rectangle {

        }
    }

    Rectangle {

        id: editRuleRow
        anchors.fill: parent
        anchors.margins: 5

        Rectangle {

            id: editRowFrame

            width: parent.width
            height: parent.height
            border.color: Qt.darker("#F4F4F4", 1.2)

            ScrollView {
                anchors.fill: parent

                clip: true

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5

                    Label {
                        TextMetrics {
                            id: metricElement
                            font: editRuleRepeatLabel.font
                            text: editRuleRepeatLabel.text
                        }

                        id: editRuleRepeatLabel
                        text: " Repeat"
                        width: metricElement.width*2
                        height: metricElement.height*3
                        verticalAlignment: Text.AlignVCenter;
                    }

                    ComboBox {
                        id: repeatTypeCombobox
                        width: metricElement.width*5
                        height: metricElement.height*3 - 20
                        anchors.left: editRuleRepeatLabel.right
                        y: 10
                        model: Server.getRepeatTypes()
                    }

                    ScrollView {

                        width: parent.width-10
                        height: parent.height - 10
                        anchors.margins: 5
                        anchors.top: repeatTypeCombobox.bottom
                        clip: true

                        Loader {
                            id: ruleLoaderComponent
                            sourceComponent: getCurrentComponent()

                            function getCurrentComponent() {
                                switch(Server.getRepeatTypes()[repeatTypeCombobox.currentIndex]) {
                                     case "Monthly":
                                         singleTypeRepeatString = "month";
                                         return ruleMonthlyComponent
                                     case "Weekly":
                                         singleTypeRepeatString = "week";
                                         return ruleWeeklyComponent
                                    case "Daily":
                                        singleTypeRepeatString = "day";
                                        return repeatEveryComponent
                                    case "Hourly":
                                        singleTypeRepeatString = "hour";
                                        return repeatEveryComponent
                                    default:
                                        return
                                }
                            }
                        }
                    }

                    RoundButton {
                        id: cancelRuleButton
                        width: ruleViewTextForButtonSizes.height-10
                        height: ruleViewTextForButtonSizes.height-10
                        anchors.right: parent.right
                        anchors.margins: 5

                        text: Server.ICONS.back
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: pushInfo()
                    }

                    RoundButton {
                        id: acceptRuleButton
                        width: ruleViewTextForButtonSizes.height-10
                        height: ruleViewTextForButtonSizes.height-10
                        anchors.right: cancelRuleButton.left
                        anchors.margins: 5

                        text: Server.ICONS.accept
                        font.family: root.fontAwesome.name
                        font.pixelSize: 20

                        onClicked: pushInfo()
                    }
                }

            }

        }

        Label {
            id: ruleViewTextForButtonSizes
            text: ""
            font.pointSize: 32
        }
    }
}
