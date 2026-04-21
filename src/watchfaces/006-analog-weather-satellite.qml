// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtSensors 5.11
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Configuration 1.0
import Nemo.Mce 1.0
import 'weathericons.js' as WeatherIcons

Item {
    anchors.fill: parent

    property string imgPath: "../watchfaces-img/analog-weather-satellite-"

    // Element sizes, positioning, linewidth and opacity
    property real switchSize: root.width * .1375
    property real boxSize: root.width * .35
    property real switchPosition: root.width * .26
    property real boxPosition: root.width * .25
    property real innerArcLineWidth: root.height * .008
    property real outerArcLineWidth: root.height * .016
    property real activeArcOpacity: !displayAmbient ? .7 : .4
    property real inactiveArcOpacity: !displayAmbient ? .5 : .3
    property real activeContentOpacity: !displayAmbient ? .95 : .6
    property real inactiveContentOpacity: !displayAmbient ? .5 : .3

    // Color definition
    property string customRed: "#DB5461"
    property string customBlue: "#1E96FC"
    property string customGreen: "#26C485"
    property string customOrange: "#FFC600"
    property string boxColor: "#E8DCB9"
    property string switchColor: "#A2D6F9"

    property int dayNb: 0

    function kelvinToTemperatureString(kelvin) {
        var celsius = kelvin - 273
        return !useFahrenheit.value ? celsius + "°" : Math.round((celsius * 9 / 5) + 32) + "°"
    }

    Item {
        id: root

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        MceBatteryState {
            id: batteryChargeState
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Item {
            id: dockMode

            readonly property bool active: nightstand
            property int batteryPercentChanged: batteryChargePercentage.percent

            anchors.fill: root
            layer.enabled: true
            layer.samples: 4
            visible: dockMode.active

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                property real arcStrokeWidth: 0.016
                property real scalefactor: 0.39 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: dockMode

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: dockMode.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.MiterJoin
                    startX: width / 2
                    startY: height * (0.5 - chargeArc.scalefactor)

                    PathAngleArc {
                        centerX: dockMode.width / 2
                        centerY: dockMode.height / 2
                        radiusX: chargeArc.scalefactor * dockMode.width
                        radiusY: chargeArc.scalefactor * dockMode.height
                        startAngle: -90
                        sweepAngle: chargeArc.angle
                        moveToStart: false
                    }
                }
            }

            Text {
                id: batteryDockPercent

                anchors {
                    centerIn: dockMode
                    verticalCenterOffset: dockMode.width * 0.22
                }
                visible: dockMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline
                styleColor: "#80000000"
                font {
                    pixelSize: dockMode.width * .15
                    family: "Noto Sans"
                    styleName: "Condensed Light"
                }
                text: batteryChargePercentage.percent
            }
        }

        Item {
            id: dialBox

            anchors.fill: parent

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 1
                verticalOffset: 1
                radius: 6.0
                samples: 9
                color: Qt.rgba(0, 0, 0, .7)
            }

            Repeater {
                model: 60
                Rectangle {
                    property real rotM: (index - 15) / 60
                    property real centerX: root.width / 2 - width / 2
                    property real centerY: root.height / 2 - height / 2

                    x: centerX + Math.cos(rotM * 2 * Math.PI) * root.width * .46
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * root.width * .46
                    visible: index % 5
                    antialiasing: true
                    color: "#55ffffff"
                    width: root.width * .005
                    height: root.height * .018

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: index * 6
                    }
                }
            }

            Repeater {
                model: 12
                Text {
                    property real rotM: ((index * 5) - 15) / 60
                    property real centerX: root.width / 2 - width / 2
                    property real centerY: root.height / 2 - height / 2

                    x: centerX + Math.cos(rotM * 2 * Math.PI) * root.width * .46
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * root.width * .46
                    antialiasing: true
                    color: hourSVG.toggle24h && index === 0 ? customGreen : "white"
                    opacity: inactiveContentOpacity
                    font {
                        pixelSize: root.height * .06
                        family: "Noto Sans"
                        styleName: "Bold"
                    }
                    text: (index === 0 ? 12 : index)

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: index === 6 ? 0 :
                               ([4, 5, 7, 8].includes(index)) ? (index * 30) + 180 :
                               index * 30
                    }
                }
            }

            Item {
                id: digitalBox

                anchors {
                    centerIn: dialBox
                    verticalCenterOffset: dockMode.active ? -root.width * .21 : -root.width * .29
                }
                width: !dockMode.active ? boxSize : boxSize * .84
                height: width
                opacity: activeContentOpacity

                Text {
                    id: digitalHour

                    anchors {
                        right: digitalBox.horizontalCenter
                        rightMargin: digitalBox.width * .01
                        verticalCenter: digitalBox.verticalCenter
                    }
                    color: "#ccffffff"
                    font {
                        pixelSize: digitalBox.width * .46
                        family: "Noto Sans"
                        styleName: "Regular"
                        letterSpacing: -digitalBox.width * .001
                    }
                    text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) :
                                        wallClock.time.toLocaleString(Qt.locale(), "HH")
                }

                Text {
                    id: digitalMinutes

                    anchors {
                        left: digitalHour.right
                        bottom: digitalHour.bottom
                        leftMargin: digitalBox.width * .01
                    }
                    color: "#ddffffff"
                    font {
                        pixelSize: digitalBox.width * .46
                        family: "Noto Sans"
                        styleName: "Light"
                        letterSpacing: -digitalBox.width * .001
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "mm")
                }

                Text {
                    id: apDisplay

                    anchors {
                        left: digitalMinutes.right
                        leftMargin: digitalBox.width * .09
                        bottom: digitalMinutes.verticalCenter
                        bottomMargin: -digitalBox.width * .22
                    }
                    visible: use12H.value
                    color: "#ddffffff"
                    font {
                        pixelSize: digitalBox.width * 0.14
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
                }
            }

            Item {
                id: weatherBox

                anchors {
                    centerIn: dialBox
                    horizontalCenterOffset: !dockMode.active ? -boxPosition : -boxPosition * .78
                }
                width: boxSize
                height: width

                ConfigurationValue {
                    id: timestampDay0
                    key: "/org/asteroidos/weather/timestamp-day0"
                    defaultValue: 0
                }

                ConfigurationValue {
                    id: useFahrenheit
                    key: "/org/asteroidos/settings/use-fahrenheit"
                    defaultValue: false
                }

                ConfigurationValue {
                    id: owmId
                    key: "/org/asteroidos/weather/day" + dayNb + "/id"
                    defaultValue: 0
                }

                ConfigurationValue {
                    id: maxTemp
                    key: "/org/asteroidos/weather/day" + dayNb + "/max-temp"
                    defaultValue: 0
                }

                property bool weatherSynced: maxTemp.value != 0

                // Static background circle for weather box — fill + inner border ring
                Rectangle {
                    anchors.centerIn: parent
                    width: weatherBox.width * 0.86
                    height: width
                    radius: width / 2
                    antialiasing: true
                    color: "#22ffffff"
                    border.color: boxColor
                    border.width: innerArcLineWidth
                    opacity: inactiveArcOpacity
                    visible: !dockMode.active
                }

                // Outer ring stroke — static full circle
                Shape {
                    anchors.fill: parent
                    opacity: inactiveArcOpacity
                    visible: !dockMode.active

                    ShapePath {
                        strokeColor: "#33ffffff"
                        strokeWidth: outerArcLineWidth
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: weatherBox.width / 2
                            centerY: weatherBox.height / 2
                            radiusX: weatherBox.width * .43
                            radiusY: weatherBox.height * .43
                            startAngle: -90
                            sweepAngle: 360
                        }
                    }
                }

                Icon {
                    id: iconDisplay

                    anchors {
                        centerIn: weatherBox
                        verticalCenterOffset: -parent.height * .155
                    }
                    width: weatherBox.width * .42
                    height: width
                    visible: weatherBox.weatherSynced
                    opacity: activeContentOpacity
                    name: WeatherIcons.getIconName(owmId.value)
                }

                Label {
                    id: maxDisplay

                    anchors {
                        centerIn: weatherBox
                        verticalCenterOffset: weatherBox.height * (weatherBox.weatherSynced ? .155 : 0)
                        horizontalCenterOffset: weatherBox.height * (weatherBox.weatherSynced ? .05 : 0)
                    }
                    width: weatherBox.width
                    height: width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    opacity: activeContentOpacity
                    font {
                        family: "Barlow"
                        styleName: weatherBox.weatherSynced ? "Medium" : "Bold"
                        pixelSize: weatherBox.width * (weatherBox.weatherSynced ? .30 : .14)
                    }
                    text: weatherBox.weatherSynced ? kelvinToTemperatureString(maxTemp.value) :
                                                    "NO<br>WEATHER<br>DATA"
                }
            }

            Item {
                id: dayBox

                anchors {
                    centerIn: dialBox
                    horizontalCenterOffset: !dockMode.active ? boxPosition : boxPosition * .78
                }
                width: boxSize
                height: width

                // Static background circle for day box — fill + inner border ring
                Rectangle {
                    anchors.centerIn: parent
                    width: dayBox.width * 0.86
                    height: width
                    radius: width / 2
                    antialiasing: true
                    color: "#22ffffff"
                    border.color: boxColor
                    border.width: innerArcLineWidth
                    opacity: inactiveArcOpacity
                    visible: !dockMode.active
                }

                // Outer ring stroke — static full circle
                Shape {
                    anchors.fill: parent
                    opacity: inactiveArcOpacity
                    visible: !dockMode.active

                    ShapePath {
                        strokeColor: "#33ffffff"
                        strokeWidth: outerArcLineWidth
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: dayBox.width / 2
                            centerY: dayBox.height / 2
                            radiusX: dayBox.width * .43
                            radiusY: dayBox.height * .43
                            startAngle: -90
                            sweepAngle: 360
                        }
                    }
                }

                Text {
                    id: dayName

                    anchors {
                        centerIn: dayBox
                        verticalCenterOffset: -dayBox.width * .25
                    }
                    color: "#ffffffff"
                    opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
                    font {
                        pixelSize: dayBox.width * .14
                        family: "Barlow"
                        styleName: "Bold"
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 3).toUpperCase()
                }

                Text {
                    id: dayNumber

                    anchors.centerIn: dayBox
                    color: "#ffffffff"
                    opacity: activeContentOpacity
                    font {
                        pixelSize: dayBox.width * .38
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()
                }

                Text {
                    id: monthName

                    anchors {
                        centerIn: dayBox
                        verticalCenterOffset: dayBox.width * .25
                    }
                    color: "#ffffffff"
                    opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
                    font {
                        pixelSize: dayBox.width * .14
                        family: "Barlow"
                        styleName: "Bold"
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase()
                }
            }

            Item {
                id: batteryBox

                property int value: batteryChargePercentage.percent

                anchors {
                    centerIn: dialBox
                    verticalCenterOffset: boxPosition
                }
                width: boxSize
                height: width
                visible: !dockMode.active

                // Static background circle — fill + inner border ring
                Rectangle {
                    anchors.centerIn: parent
                    width: batteryBox.width * 0.86
                    height: width
                    radius: width / 2
                    antialiasing: true
                    color: "#22ffffff"
                    border.color: "#77ffffff"
                    border.width: innerArcLineWidth
                    opacity: activeArcOpacity
                }

                // Battery progress arc — sweepAngle binding updates automatically on battery change
                Shape {
                    anchors.fill: batteryBox
                    opacity: activeArcOpacity

                    ShapePath {
                        strokeColor: batteryBox.value < 30 ? customRed :
                                     batteryBox.value < 60 ? customOrange :
                                     customGreen
                        strokeWidth: outerArcLineWidth
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: batteryBox.width / 2
                            centerY: batteryBox.height / 2
                            radiusX: batteryBox.width * .43
                            radiusY: batteryBox.height * .43
                            startAngle: -90
                            sweepAngle: batteryBox.value / 100 * 360
                        }
                    }
                }

                Icon {
                    id: batteryIcon

                    anchors {
                        centerIn: batteryBox
                        verticalCenterOffset: -batteryBox.height * .26
                    }
                    visible: batteryChargeState.value === MceBatteryState.Charging
                    opacity: inactiveContentOpacity
                    width: batteryBox.width * .25
                    height: width
                    name: "ios-flash"
                }

                Text {
                    id: batteryDisplay

                    anchors.centerIn: batteryBox
                    color: "#ffffffff"
                    opacity: activeContentOpacity
                    font {
                        pixelSize: batteryBox.width * .38
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }
                    text: batteryBox.value
                }

                Text {
                    id: chargeText

                    anchors {
                        centerIn: batteryBox
                        verticalCenterOffset: batteryBox.width * .25
                    }
                    color: "#ffffffff"
                    opacity: inactiveContentOpacity
                    font {
                        pixelSize: batteryBox.width * .14
                        family: "Barlow"
                        styleName: "Bold"
                    }
                    text: "%"
                }
            }
        }

        Item {
            id: handBox

            width: root.width
            height: root.height

            Image {
                id: hourSVG

                property bool toggle24h: false

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                source: imgPath + "hour-12h.svg"

                transform: Rotation {
                    id: hourRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.enabled: true
                layer.samples: 4
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .2)
                }
            }

            Image {
                id: minuteSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                source: imgPath + "minute.svg"

                transform: Rotation {
                    id: minuteRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.enabled: true
                layer.samples: 4
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 5
                    verticalOffset: 5
                    radius: 10.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .2)
                }
            }

            // second hand has no layer — continuous 60fps rotation would force constant recomposite
            Image {
                id: secondSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                visible: !displayAmbient && !dockMode.active
                source: imgPath + "second.svg"

                transform: Rotation {
                    id: secondRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }
            }
        }

        // 16ms sweep timer for continuous second hand — eliminates Behavior catch-up on return
        Timer {
            interval: 16
            repeat: true
            running: !displayAmbient && !dockMode.active && visible

            onTriggered: {
                var now = new Date()
                secondRot.angle = (now.getSeconds() * 1000 + now.getMilliseconds()) * 6 / 1000
            }
        }

        Connections {
            target: wallClock
            function onTimeChanged() {
                var h = wallClock.time.getHours()
                var min = wallClock.time.getMinutes()
                var sec = wallClock.time.getSeconds()
                hourRot.angle = hourSVG.toggle24h ? h * 15 + min * .25 : h * 30 + min * .5
                minuteRot.angle = min * 6 + sec * 6 / 60
            }
        }

        Component.onCompleted: {
            var h = wallClock.time.getHours()
            var min = wallClock.time.getMinutes()
            var sec = wallClock.time.getSeconds()
            hourRot.angle = hourSVG.toggle24h ? h * 15 + min * .25 : h * 30 + min * .5
            minuteRot.angle = min * 6 + sec * 6 / 60
        }
    }
}
