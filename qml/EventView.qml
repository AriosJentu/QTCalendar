import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5

Item {

    id: eventWindow
    //anchors.fill: parent

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
                    res = parent.width - parent.spacing;
                }
                res;
            }

            height: {
                var res = parent.height*0.4 - parent.spacing;
                if (parent.width > parent.height) {
                    res = parent.height - parent.spacing;
                }
                res;
            }
            border.color: Qt.darker("#F4F4F4", 1.2)

            Rectangle {
                id: viewEventListHeader
                width: parent.width
                height: viewEventDayLabel.height
                color: "transparent"
                anchors.fill: parent
                anchors.margins: 10

                Row {
                    id: viewEventDayRow
                    width: parent.width
                    height: parent.height
                    spacing: 10

                    Label {
                        id: viewEventDayLabel
                        text: "29"
                        font.pointSize: 35
                    }

                    Column {
                        height: viewEventDayLabel.height
                        anchors.margins: 5

                        Label {
                            id: viewEventStandaloneDayName
                            readonly property var options: { weekday: "long" }
                            text: "Wednesday"
                            font.pointSize: 18
                        }

                        Label {
                            id: viewEventMonthYearName
                            text: "September 2019"
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
                }
            }
        }


        Rectangle {
            width: {
                var res = parent.width*0.5 - parent.spacing;
                if (parent.width < parent.height) {
                    res = parent.width - parent.spacing;
                }
                res;
            }

            height: {
                var res = parent.height*0.6 - parent.spacing;
                if (parent.width > parent.height) {
                    res = parent.height - parent.spacing;
                }
                res;
            }
            border.color: Qt.darker("#F4F4F4", 1.2)

        }

    }

    function setEvent(modelobj) {
        viewEventDayLabel.text = modelobj.startDate.getDate();
        viewEventStandaloneDayName.text = Qt.locale().standaloneDayName(
            modelobj.startDate.getDay(),
            Locale.LongFormat);
        viewEventMonthYearName.text = Qt.locale().standaloneMonthName(
            modelobj.startDate.getMonth())
            + modelobj.startDate.toLocaleDateString(Qt.locale(), " yyyy")
        console.log("Changing titles");
    }

    function sendMessage(message) {
        console.log(message);
    }
}
