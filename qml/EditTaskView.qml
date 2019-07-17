import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as OldContr
import "qrc:/src/server.js" as Server

Item {

    id: editTaskView

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
                    text: "Edit Task"
                    font.pointSize: 32
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

                }

                TextField {

                    id: taskNameTextField

                    anchors.left: taskNameLabel.right
                    anchors.top: viewTaskTitle.bottom

                    width: parent.width - taskNameLabel.width*1.1
                    height: metricElement.height*2
                    text: ""
                    placeholderText: "Task name"
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

                    text: Server.ICONS.back
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    //onClicked: pushInfo()
                }

                RoundButton {

                    id: acceptTaskButton
                    width: textForButtonSize.height*1.2-10
                    height: textForButtonSize.height*1.2-10
                    anchors.right: cancelTaskButton.left
                    anchors.margins: 5

                    text: Server.ICONS.accept
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    //onClicked: updateEvent()
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
