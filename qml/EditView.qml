import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import org.jentucalendar.calendar 1.0

Item {

    id: editWindow
    property var currentEvent

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

            Rectangle {

                id: viewEditEventListHeader
                width: parent.width
                anchors.fill: parent
                anchors.margins: 10

                Rectangle {

                    id: mainEditRectangle

                    width: viewEditEventListHeader.width
                    height: viewEditTitle.height
                    anchors.fill: viewEditEventListHeader
                    anchors.margins: 10

                    color: "transparent"

                    Label {
                        id: viewEditTitle
                        text: "Edit event"
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
        viewEditTitle.text = "Edit event";
        currentEvent = modelobj;
    }

    function setNewEvent(date) {
        viewEditTitle.text = "New event";
    }
}
