import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5

import QtLocation 5.6
import QtPositioning 5.6

import "qrc:/src/server.js" as Server;

Item {

    id: mapWindow
    property var currentEvent
    property bool isNewEvent: false
    property bool isViewEvent: false
    property var selectedCoordinate


    function loadEvent(event, isView, isNew) {
        currentEvent = event;
        isNewEvent = isNew;
        isViewEvent = isView;
        getEventCoordinate()
    }

    function getEventCoordinate() {
        if (currentEvent.location !== "") {
            var arr = currentEvent.location.split(", ");
            setEventCoordinateOnMap(QtPositioning.coordinate(Number(arr[0]), Number(arr[1])))
        } else {
            mainMap.center = src.position.coordinate
            mainMap.zoomLevel = 18
        }
    }

    function setEventCoordinateOnMap(coord) {
        mainMap.center = coord
        eventLocation.coordinate = coord
        mainMap.zoomLevel = 18
    }

    function saveCoordinates() {
        if (eventLocation.coordinate.longitude.toString() === "NaN") {
            currentEvent.location = ""
        } else {
            currentEvent.location = eventLocation.coordinate.latitude + ", " + eventLocation.coordinate.longitude
        }

    }

    function pushInfo() {
        if (!isViewEvent) {
            mainStackView.push(editPage);
            mainStackView.currentItem.setEvent(currentEvent, isNewEvent);
        } else {
            mainStackView.push(viewPage);
            mainStackView.currentItem.setEvent(currentEvent);
        }
    }

    Rectangle {

        id: mapElementRow
        anchors.fill: parent
        anchors.margins: 5

        Rectangle {

            id: mapRectFrame

            width: parent.width
            height: parent.height
            border.color: Qt.darker("#F4F4F4", 1.2)

            Plugin {
                id: mapPlugin
                name: "osm"
                PluginParameter {
                     name: "osm.mapping.host";
                     value: "http://a.tile.openstreetmap.org/"
                 }
            }

            Map {

                id: mainMap
                plugin: mapPlugin
                anchors.fill: parent
                anchors.margins: 2
                activeMapType: mainMap.supportedMapTypes[6]

                MapQuickItem {
                    id: userLocation
                    sourceItem: Text {

                        TextMetrics {
                            id: metricElement
                            font: userLocationIcon.font
                            text: userLocationIcon.text
                        }

                        id: userLocationIcon
                        text: Server.ICONS.userlocation
                        font.family: root.fontAwesome.name
                        font.pixelSize: 50
                        color: "blue"
                        x: -metricElement.width*3/4
                        y: -metricElement.height*2/5
                    }
                }

                MapQuickItem {
                    id: eventLocation
                    sourceItem: Text {

                        TextMetrics {
                            id: imetricElement
                            font: eventLocationIcon.font
                            text: eventLocationIcon.text
                        }

                        id: eventLocationIcon
                        text: Server.ICONS.map
                        font.family: root.fontAwesome.name
                        font.pixelSize: 50
                        color: "red"
                        x: -imetricElement.width*3/4
                        y: -imetricElement.height*0.9
                    }
                }

                PositionSource {
                    id: src
                    active: true
                    onPositionChanged: {
                        src.start()
                        userLocation.coordinate = src.position.coordinate
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!isViewEvent) {
                            eventLocation.coordinate = mainMap.toCoordinate(Qt.point(mouse.x,mouse.y))
                        }
                    }
                }
            }

            Rectangle {

                anchors.margins: 5
                anchors.right: parent.right
                anchors.top: parent.top

                RoundButton {
                    id: cancelLocationButton
                    width: locationViewTextForButtonSizes.height*1.2-10
                    height: locationViewTextForButtonSizes.height*1.2-10
                    anchors.right: parent.right
                    anchors.margins: 5

                    text: Server.ICONS.back
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20

                    onClicked: pushInfo()
                }

                RoundButton {

                    id: acceptLocationButton
                    width: locationViewTextForButtonSizes.height*1.2-10
                    height: locationViewTextForButtonSizes.height*1.2-10
                    anchors.right: cancelLocationButton.left
                    anchors.margins: 5

                    text: Server.ICONS.accept
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20
                    visible: !isViewEvent

                    onClicked: {
                        saveCoordinates();
                        pushInfo();
                    }
                }

                RoundButton {

                    id: moveToUserLocationButton
                    width: locationViewTextForButtonSizes.height*1.2-10
                    height: locationViewTextForButtonSizes.height*1.2-10
                    anchors.right: isViewEvent ? cancelLocationButton.left : acceptLocationButton.left
                    anchors.margins: 5

                    text: Server.ICONS.userpos
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20
                    enabled: src.position.coordinate.longitude.toString() !== "NaN"

                    onClicked: {
                        mainMap.center = src.position.coordinate
                        mainMap.zoomLevel = 18
                    }
                }

                RoundButton {

                    id: moveToSelectedLocationButton
                    width: locationViewTextForButtonSizes.height*1.2-10
                    height: locationViewTextForButtonSizes.height*1.2-10
                    anchors.right: moveToUserLocationButton.left
                    anchors.margins: 5

                    text: Server.ICONS.map
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20
                    enabled: eventLocation.coordinate.longitude.toString() !== "NaN"

                    onClicked: {
                        mainMap.center = eventLocation.coordinate
                        mainMap.zoomLevel = 18
                    }
                }

                RoundButton {

                    id: clearLocationButton
                    width: locationViewTextForButtonSizes.height*1.2-10
                    height: locationViewTextForButtonSizes.height*1.2-10
                    anchors.right: moveToSelectedLocationButton.left
                    anchors.margins: 5

                    text: Server.ICONS.remove_evt
                    font.family: root.fontAwesome.name
                    font.pixelSize: 20
                    enabled: eventLocation.coordinate.longitude.toString() !== "NaN"
                    visible: !isViewEvent

                    onClicked: {
                        eventLocation.coordinate.longitude = Number("NaN");
                    }
                }
            }

            Label {
                id: locationViewTextForButtonSizes
                text: ""
                font.pointSize: 32
            }
        }
    }
}
