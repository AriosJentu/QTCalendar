import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5
import QtQuick.Window 2.10

Window {

    id: root
    visible: true
    minimumWidth: 700
    minimumHeight: 500

    readonly property FontLoader fontAwesome: FontLoader { source: "qrc:/assets/miregular.ttf" }

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

    Component {
        id: selectorView
        SelectorView {}
    }

    Component {
        id: editRuleView
        EditRuleView {}
    }

    Component {
        id: mapView
        MapView {}
    }

    Component {
        id: loginView
        LoginView {}
    }


}
