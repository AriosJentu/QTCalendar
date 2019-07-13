import QtQuick 2.5
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.5

import QtLocation 5.6
import QtPositioning 5.6

import "qrc:/src/server.js" as Server;

Item {

    id: mapWindow
    property var currentEvent

    Rectangle {

        id: mapElementRow
        anchors.fill: parent
        anchors.margins: 5

        Rectangle {

            id: mapRectFrame

            width: parent.width
            height: parent.height
            border.color: Qt.darker("#F4F4F4", 1.2)

            /*Plugin {
                id: mapPlugin
                name: "osm"


                required: Plugin.AnyMappingFeatures | Plugin.AnyGeocodingFeatures
                PluginParameter { name: "osm.mapping.host"; value: "https://tile.openstreetmap.org/" }
                PluginParameter { name: "osm.geocoding.host"; value: "https://nominatim.openstreetmap.org" }
                PluginParameter { name: "osm.routing.host"; value: "https://router.project-osrm.org/viaroute" }
                PluginParameter { name: "osm.places.host"; value: "https://nominatim.openstreetmap.org/search" }
                PluginParameter { name: "osm.mapping.highdpi_tiles"; value: true }

            }

            GeocodeModel {
                id: geocodeModel
                plugin: mapPlugin
                onStatusChanged: {
                    if ((status == GeocodeModel.Ready) || (status == GeocodeModel.Error))
                        mainMap.geocodeFinished()
                }
                onLocationsChanged:
                {
                    if (count == 1) {
                        mainMap.center.latitude = get(0).coordinate.latitude
                        mainMap.center.longitude = get(0).coordinate.longitude
                    }
                }
            }*/

            Plugin {
                id: mapPlugin
                name: "osm"
            }

            Map {

                id: mainMap
                plugin: mapPlugin
                anchors.fill: parent
                anchors.margins: 2

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
                        font.pixelSize: 30
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
                        text: Server.ICONS.selectedlocation
                        font.family: root.fontAwesome.name
                        font.pixelSize: 30
                        x: -imetricElement.width*3/4
                        y: -imetricElement.height*2/5
                    }
                }

                PositionSource {

                    id: src

                    onPositionChanged: {
                        //var coord = src.position.coordinate;
                        //mainMap.center = coord
                        //mainMap.zoomLevel = 18
                        userLocation.coordinate = src.position.coordinate
                    }
                }
            }

        }
    }
}
