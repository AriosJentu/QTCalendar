import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5

Item {

    id: editWindow

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
                        width: viewEditTitle.height*1.5
                        height: viewEditTitle.height
                        anchors.right: mainEditRectangle.right
                        anchors.margins: 5

                        onClicked: {
                            mainStackView.push(mainPage);
                        }

                        onWindowChanged: {
                            console.log(closeEditButton.x, closeEditButton.y, mainEditRectangle.width, viewEditEventListHeader.width, test.width);
                        }

                        text: "Cancel"
                    }

                    RoundButton {
                        id: saveEditButton
                        width: viewEditTitle.height*1.5
                        height: viewEditTitle.height
                        anchors.right: closeEditButton.left
                        anchors.margins: 5

                        text: "Save"
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
}
