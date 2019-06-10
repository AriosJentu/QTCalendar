import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Window 2.10
import org.jentucalendar.calendar 1.0

Window {

    id: root
    visible: true
    minimumWidth: 500
    minimumHeight: 400

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
        EventView {
            id: viewPageEventViewElement
        }
    }

    Component {
        id: testView
        TestView {}

    }
}
