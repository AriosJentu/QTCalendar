import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import "qrc:/src/client.js" as Client;

//import QtFirebase 1.0

Item {

    id: loginWindow

    property var curDate;

    function setSelectedDate(date) {
        curDate = date
    }

    /*Auth {
        id: auth
        onCompleted: {
            if(success) {
                if (actionId === Auth.ActionSignIn) {
                    console.log("Auth success");
                } else if (actionId === Auth.ActionRegister) {
                    console.log("Register success");
                } else if (actionId === Auth.ActionSignOut) {
                    console.log("Signed out")
                }
            }
        }
    }*/

    Rectangle {
        id: loginWindowRect

        anchors.fill: parent
        anchors.margins: 5

        Rectangle {

            id: loginWindowFrame

            width: parent.width
            height: parent.height
            border.color: Qt.darker("#F4F4F4", 1.2)

            Rectangle {

                anchors.margins: 5
                anchors.left: parent.left
                anchors.top: parent.top

                RoundButton {
                    id: loginButton
                    text: "Log In"

                    anchors.left: parent.left
                    anchors.margins: 5

                }

                RoundButton {
                    id: registerButton
                    text: "Register"

                    anchors.left: loginButton.right
                    anchors.margins: 5

                }

                RoundButton {
                    id: logoutButton
                    text: "Log Out"

                    anchors.left: registerButton.right
                    anchors.margins: 5

                }
            }

            Rectangle {

                anchors.margins: 5
                anchors.right: parent.right
                anchors.top: parent.top

                RoundButton {
                    id: cancelLoginButton
                    width: buttonSizerElement.height*1.2-10
                    height: buttonSizerElement.height*1.2-10
                    anchors.right: parent.right
                    anchors.margins: 5

                    text: Client.ICONS.back
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: {
                        mainStackView.push(mainPage);
                        mainStackView.currentItem.setSelectedDate(curDate);
                    }
                }
            }
        }

        Label {
            id: buttonSizerElement
            text: ""
            font.pointSize: 32
        }
    }
}
