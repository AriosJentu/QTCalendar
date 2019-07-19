import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as OldContr
import "qrc:/src/client.js" as Client

Item {

    id: editRuleView

    property var currentEvent
    property bool isNewEvent: false
    property string singleTypeRepeatString: "day"

    function loadEvent(event, isNew) {

        currentEvent = event;
        isNewEvent = isNew;

        if (event.duration) {
            var rduration = Client.parseTimeToTypes(event.duration)
            durationTextBox.text = rduration[0];
            selectorDurationType.currentIndex = Client.getDurationTypes(rduration[0]).indexOf(rduration[1]);
        }

        parseRRule();
    }

    function pushInfo() {
        mainStackView.push(editPage);
        mainStackView.currentItem.setEvent(currentEvent, isNewEvent);
    }

    function updateEvent() {
        currentEvent.reprule = buildRRuleString()
        console.log(currentEvent.reprule)
        if (currentEvent.reprule) {
            currentEvent.duration = Math.max(1, Number(durationTextBox.text))*Client.getDurationMultiplier(selectorDurationType.model[selectorDurationType.currentIndex]);
            console.log(currentEvent.duration);
        } else {
            currentEvent.duration = 0;
        }

        pushInfo()
    }

    function buildRRuleString() {
        var arr = Client.generateBuilderArray();
        arr.type = repeatTypeCombobox.model[repeatTypeCombobox.currentIndex];
        arr.count = Number(endRepeatingTextBox.text);
        arr = ruleLoaderComponent.item.buildRRule(arr);
        var res = Client.buildRRule(arr);
        return res;
    }

    function parseRRule() {

        var arr = Client.convertRRuleToBuilderArray(currentEvent.reprule);
        repeatTypeCombobox.currentIndex = repeatTypeCombobox.model.indexOf(arr.type);
        endRepeatingTextBox.text = arr.count.toString();

        ruleLoaderComponent.item.parseRRule(arr);
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
                text: singleTypeRepeatString + Client.getEnding(Number(repeatEveryTextBox.text))
                width: metricElement.width*1.5
                height: metricElement.height*3
                anchors.left: repeatEveryTextBox.right
                anchors.leftMargin: 10
                verticalAlignment: Text.AlignVCenter;
            }

            function buildRRule(arr) {
                arr.interval = Math.max(Number(repeatEveryTextBox.text), 1);
                return arr;
            }

            function parseRRule(arr) {
                repeatEveryTextBox.text = arr.interval;
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

            function buildRRule(arr) {

                var comps = [mondayCheckBox, tuesdayCheckBox, wednesdayCheckBox, thursdayCheckBox, fridayCheckBox, saturdayCheckBox, sundayCheckBox]

                for (var k in comps) {
                    if (comps[k].checked) {
                        arr.byday.push(comps[k].text);
                    }
                }

                arr = loaderWeekly.item.buildRRule(arr);

                return arr;
            }

            function parseRRule(arr) {
                var comps = [mondayCheckBox, tuesdayCheckBox, wednesdayCheckBox, thursdayCheckBox, fridayCheckBox, saturdayCheckBox, sundayCheckBox]


                for (var k in comps) {
                    comps[k].checked = arr.byday.indexOf(comps[k].text) >= 0;
                }

                loaderWeekly.item.parseRRule(arr)
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
                model: Client.getIntArray(31, false, 1);
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
                model: Client.getOrdinals();
                width: radioButtonOnWeekDay.width
                anchors.margins: 5
            }

            ComboBox {
                id: selectorDaysOnWeekDay
                anchors.top: radioButtonOnMonthDay.bottom
                anchors.left: selectorOrdinalOnWeekDay.right
                model: Client.getWeeks()[0];
                width: radioButtonOnWeekDay.width*1.2
                anchors.margins: 5
            }

            Loader {
                id: loaderMonthly
                sourceComponent: repeatEveryComponent
                anchors.top: radioButtonOnWeekDay.bottom
                anchors.margins: 5
            }

            function buildRRule(arr) {

                if (radioButtonOnMonthDay.checked) {
                    arr.bymonthday = selectorDayOnMonthDay.model[selectorDayOnMonthDay.currentIndex];
                } else {
                    arr.bysetpos = selectorOrdinalOnWeekDay.model[selectorOrdinalOnWeekDay.currentIndex];
                    arr.byday = [selectorDaysOnWeekDay.model[selectorDaysOnWeekDay.currentIndex]];
                }

                arr = loaderMonthly.item.buildRRule(arr);

                return arr;
            }

            function parseRRule(arr) {

                radioButtonOnMonthDay.checked = (arr.byday.length === 0 && arr.bysetpos === "");
                radioButtonOnWeekDay.checked = !radioButtonOnMonthDay.checked

                if (radioButtonOnMonthDay.checked) {
                    selectorDayOnMonthDay.currentIndex = selectorDayOnMonthDay.model.indexOf(arr.bymonthday);
                } else {
                    selectorOrdinalOnWeekDay.currentIndex = selectorOrdinalOnWeekDay.model.indexOf(arr.bysetpos);
                    selectorDaysOnWeekDay.currentIndex = selectorDaysOnWeekDay.model.indexOf(arr.byday[0]);
                }

                loaderMonthly.item.parseRRule(arr)
            }
        }
    }

    Component {

        id: ruleYearlyComponent

        Rectangle {
            id: ruleYearlyRectangle

            RadioButton {
                id: radioButtonOnYearDay
                text: "On"
                checked: true
                anchors.margins: 5
            }

            ComboBox {
                id: selectorMonthOnYearlyDay
                anchors.left: radioButtonOnYearDay.right
                model: Client.getMonthes();
                width: radioButtonOnYearDay.width*2
                anchors.margins: 5
            }

            ComboBox {
                id: selectorDayOfMonthOnYearlyDay
                anchors.left: selectorMonthOnYearlyDay.right
                model: Client.getIntArray(31, false, 1);
                width: radioButtonOnYearDay.width*1.1
                anchors.margins: 5
            }

            RadioButton {
                id: radioButtonOnSpecialYearDay
                text: "On the"
                anchors.top: radioButtonOnYearDay.bottom
                anchors.margins: 5
            }

            ComboBox {
                id: selectorOrdinalOnYearDay
                anchors.left: radioButtonOnSpecialYearDay.right
                anchors.top: radioButtonOnYearDay.bottom
                model: Client.getOrdinals();
                width: radioButtonOnSpecialYearDay.width*1.1
                anchors.margins: 5
            }

            ComboBox {
                id: selectorDayTypeOnYearDay
                anchors.left: selectorOrdinalOnYearDay.right
                anchors.top: radioButtonOnYearDay.bottom
                model: Client.getWeeks()[0];
                width: radioButtonOnSpecialYearDay.width*1.6
                anchors.margins: 5
            }

            ComboBox {
                id: selectorMonthOnYearDay
                anchors.left: radioButtonOnSpecialYearDay.right
                anchors.top: selectorOrdinalOnYearDay.bottom
                model: Client.getMonthes();
                width: radioButtonOnSpecialYearDay.width*1.6
                anchors.margins: 5
            }

            Label {
                TextMetrics {
                    id: metricElement
                    font: editRuleOfLabel.font
                    text: editRuleOfLabel.text
                }

                id: editRuleOfLabel
                text: "of"
                width: metricElement.width*1.5
                height: metricElement.height*3
                verticalAlignment: Text.AlignVCenter;
                anchors.right: selectorMonthOnYearDay.left
                anchors.top: selectorOrdinalOnYearDay.bottom
            }

            function buildRRule(arr) {

                if (radioButtonOnYearDay.checked) {
                    arr.bymonth = selectorMonthOnYearlyDay.model[selectorMonthOnYearlyDay.currentIndex];
                    arr.bymonthday = Number(selectorDayOfMonthOnYearlyDay.model[selectorDayOfMonthOnYearlyDay.currentIndex]);
                } else {
                    arr.bysetpos = selectorOrdinalOnYearDay.model[selectorOrdinalOnYearDay.currentIndex];
                    arr.byday = [selectorDayTypeOnYearDay.model[selectorDayTypeOnYearDay.currentIndex]];
                    arr.bymonth = selectorMonthOnYearDay.model[selectorMonthOnYearDay.currentIndex];
                }

                return arr;
            }

            function parseRRule(arr) {

                radioButtonOnSpecialYearDay.checked = (arr.bymonthday === 0);
                radioButtonOnYearDay.checked = !radioButtonOnSpecialYearDay.checked;

                if (radioButtonOnYearDay.checked) {
                    selectorMonthOnYearlyDay.currentIndex = selectorMonthOnYearlyDay.model.indexOf(arr.bymonth);
                    selectorDayOfMonthOnYearlyDay.currentIndex = selectorDayOfMonthOnYearlyDay.model.indexOf(arr.bymonthday);
                } else {

                    selectorOrdinalOnYearDay.currentIndex = selectorOrdinalOnYearDay.model.indexOf(arr.bysetpos);
                    selectorDayTypeOnYearDay.currentIndex = selectorDayTypeOnYearDay.model.indexOf(arr.byday[0]);
                    selectorMonthOnYearDay.currentIndex = selectorMonthOnYearDay.model.indexOf(arr.bymonth);
                }
            }
        }
    }

    Component {
        id: emptyComponent;

        Rectangle {
            function buildRRule(arr) {return arr;}
            function parseRRule(arr) {}
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
                    id: mainRectangleForRules
                    anchors.fill: parent
                    anchors.margins: 5

                    Label {
                        TextMetrics {
                            id: metricElement
                            font: editRuleRepeatLabel.font
                            text: editRuleRepeatLabel.text
                        }

                        id: editRuleRepeatLabel
                        text: "Repeat"
                        width: metricElement.width*2
                        height: metricElement.height*3
                        verticalAlignment: Text.AlignVCenter;
                        anchors.margins: 5
                    }

                    ComboBox {
                        id: repeatTypeCombobox
                        width: metricElement.width*4
                        height: metricElement.height*3 - 20
                        anchors.left: editRuleRepeatLabel.right
                        y: 10
                        model: Client.getRepeatTypes()
                        anchors.margins: 5
                    }

                    Label {

                        TextMetrics {
                            id: nmetricElement
                            font: editRuleRepeatLabel.font
                            text: editRuleRepeatLabel.text
                        }

                        id: editRuleEndLabel
                        text: "Ends after"
                        width: nmetricElement.width*2
                        height: nmetricElement.height*3
                        verticalAlignment: Text.AlignVCenter;
                        anchors.top: repeatTypeCombobox.bottom
                        anchors.margins: 5
                        visible: Client.getRepeatTypes()[repeatTypeCombobox.currentIndex] !== "Never"
                    }

                    TextField {

                        id: endRepeatingTextBox
                        width: nmetricElement.width*2
                        height: nmetricElement.height*3 - 20
                        anchors.left: editRuleEndLabel.right
                        anchors.top: repeatTypeCombobox.bottom
                        text: "1"
                        maximumLength: 3
                        validator: RegExpValidator{regExp: /[0-9]+/}
                        anchors.margins: 5
                        anchors.topMargin: 10
                        visible: Client.getRepeatTypes()[repeatTypeCombobox.currentIndex] !== "Never"

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
                            id: mmetricElement
                            font: editRuleEndAnotherLabel.font
                            text: editRuleEndAnotherLabel.text
                        }

                        id: editRuleEndAnotherLabel
                        text: "time" + Client.getEnding(Number(endRepeatingTextBox.text))

                        width: nmetricElement.width*2
                        height: nmetricElement.height*3
                        verticalAlignment: Text.AlignVCenter;

                        anchors.top: repeatTypeCombobox.bottom
                        anchors.left: endRepeatingTextBox.right
                        anchors.leftMargin: 10
                        anchors.margins: 5

                        visible: Client.getRepeatTypes()[repeatTypeCombobox.currentIndex] !== "Never"
                    }

                    Label {

                        TextMetrics {
                            id: gmetricElement
                            font: editRuleDurationLabel.font
                            text: editRuleDurationLabel.text
                        }

                        id: editRuleDurationLabel
                        text: "Duration: "

                        width: gmetricElement.width*2
                        height: gmetricElement.height*3
                        verticalAlignment: Text.AlignVCenter;

                        anchors.top: endRepeatingTextBox.bottom
                        anchors.margins: 5

                        visible: Client.getRepeatTypes()[repeatTypeCombobox.currentIndex] !== "Never"
                    }

                    TextField {

                        id: durationTextBox
                        width: nmetricElement.width*2
                        height: nmetricElement.height*3 - 20
                        anchors.left: endRepeatingTextBox.left
                        anchors.top: endRepeatingTextBox.bottom
                        text: "1"
                        maximumLength: 3
                        validator: RegExpValidator{regExp: /[0-9]+/}
                        anchors.topMargin: 10
                        visible: Client.getRepeatTypes()[repeatTypeCombobox.currentIndex] !== "Never"

                        onTextChanged: {

                            if (text[0] === "0" && text.length > 1) {
                                text = text.substring(1);
                            }

                            if (text == "") {
                                text = "0";
                            }
                        }
                    }

                    ComboBox {
                        id: selectorDurationType
                        anchors.top: endRepeatingTextBox.bottom
                        anchors.left: durationTextBox.right
                        model: Client.getDurationTypes(Number(durationTextBox.text));
                        width: nmetricElement.width*2.5
                        anchors.margins: 5
                        visible: Client.getRepeatTypes()[repeatTypeCombobox.currentIndex] !== "Never"

                    }

                    ScrollView {

                        id: scrollViewElement

                        width: parent.width-10
                        height: parent.height - 10
                        anchors.margins: 5
                        anchors.top: editRuleDurationLabel.bottom
                        clip: true

                        Loader {
                            id: ruleLoaderComponent
                            sourceComponent: getCurrentComponent()

                            onSourceComponentChanged: {
                                if (!currentEvent) {
                                    return;
                                }

                                var arr = Client.convertRRuleToBuilderArray(currentEvent.reprule);
                                if (repeatTypeCombobox.model[repeatTypeCombobox.currentIndex] === arr.type){
                                    item.parseRRule(arr);
                                }
                            }

                            function getCurrentComponent() {
                                switch(Client.getRepeatTypes()[repeatTypeCombobox.currentIndex]) {
                                    case "Yearly":
                                        return ruleYearlyComponent
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
                                        return emptyComponent
                                }                                
                            }

                            function parseRRule(arr) {
                                ruleLoaderComponent.item.parseRRule(arr);
                            }
                        }
                    }


                    Rectangle {

                        anchors.margins: 5
                        anchors.right: parent.right
                        anchors.top: parent.top

                        RoundButton {
                            id: cancelRuleButton
                            width: ruleViewTextForButtonSizes.height*1.2-10
                            height: ruleViewTextForButtonSizes.height*1.2-10
                            anchors.right: parent.right
                            anchors.margins: 5

                            text: Client.ICONS.back
                            font.family: root.fontAwesome.name
                            font.pixelSize: 20

                            onClicked: pushInfo()
                        }

                        RoundButton {

                            id: acceptRuleButton
                            width: ruleViewTextForButtonSizes.height*1.2-10
                            height: ruleViewTextForButtonSizes.height*1.2-10
                            anchors.right: cancelRuleButton.left
                            anchors.margins: 5

                            text: Client.ICONS.accept
                            font.family: root.fontAwesome.name
                            font.pixelSize: 20

                            onClicked: updateEvent()
                        }
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
