import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Window 2.10
import org.jentucalendar.calendar 1.0

Window {

    id: root
    visible: true
    minimumWidth: 700
    minimumHeight: 500

    readonly property FontLoader fontAwesome: FontLoader { source: "qrc:/assets/faregular.ttf" }

    EventModel {
        id: eventModel
    }


    StackView {
        id: mainStackView;
        anchors.fill: parent
        initialItem: mainPage
    }

    Component {
        id: mainPage
        CalendarView {}
    }

    Component {
        id: viewPage
        EventView {}
    }

    Component {
        id: editPage
        EditView {}
    }

}
