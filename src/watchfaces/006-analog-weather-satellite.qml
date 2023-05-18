/*
 * Copyright (C) 2023 - Timo Könnecke <github.com/eLtMosen>
 *               2022 - Darrel Griët <dgriet@gmail.com>
 *               2022 - Ed Beroset <github.com/beroset>
 *               2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *               2012 - Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
 *                      Aleksey Mikhailichenko <a.v.mich@gmail.com>
 *                      Arto Jalkanen <ajalkane@gmail.com>
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

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

    // Radian per degree used by all canvas arcs
    property real rad: .01745

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
    property string customRed: "#DB5461" // Indian Red
    property string customBlue: "#1E96FC" // Dodger Blue
    property string customGreen: "#26C485" // Ocean Green
    property string customOrange: "#FFC600" // Mikado Yellow
    property string boxColor: "#E8DCB9" // Dutch White
    property string switchColor: "#A2D6F9" // Uranian Blue

    // Set day to use in the weatherBox to today.
    property int dayNb: 0

    function kelvinToTemperatureString(kelvin) {
        var celsius = (kelvin - 273);
        if(!useFahrenheit.value)
            return celsius + "°";
        else
            return Math.round(((celsius) * 9 / 5) + 32) + "°";
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
            visible: dockMode.active
            layer {
                enabled: true
                samples: 4
                smooth: true
                textureSize: Qt.size(dockMode.width * 2, dockMode.height * 2)
            }

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                // radius of arc is scalefactor * height or width
                property real arcStrokeWidth: 0.016
                property real scalefactor: 0.39 - (arcStrokeWidth / 2)
                property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: [ "red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: dockMode

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: dockMode.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.MiterJoin
                    startX: width / 2
                    startY: height * ( 0.5 - chargeArc.scalefactor)

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
                font {
                    pixelSize: dockMode.width * .15
                    family: "Noto Sans"
                    styleName: "Condensed Light"
                }
                visible: dockMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline; styleColor: "#80000000"
                text: batteryChargePercentage.percent
            }
        }

        Item {
            id: dialBox

            anchors.fill: parent

            // Slight dropshadow under all Items.
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 1
                verticalOffset: 1
                radius: 6.0
                samples: 13
                color: Qt.rgba(0, 0, 0, .7)
            }

            Repeater {
                    model: 60

                    Rectangle {
                        id: minuteStrokes

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
                            angle: (index) * 6
                        }
                    }
                }

            Repeater {
                // Hour numerals. hourModeSwitch toggles the 12/24hour display.
                model: 12

                Text {
                    id: hourNumbers

                    property real rotM: ((index * 5) - 15) / 60
                    property real centerX: root.width / 2 - width / 2
                    property real centerY: root.height / 2 - height / 2

                    antialiasing : true
                    font {
                        pixelSize: root.height * .06
                        family: "Noto Sans"
                        styleName: "Bold"
                    }
                    x: centerX + Math.cos(rotM * 2 * Math.PI) * root.width * .46
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * root.width * .46
                    color: hourSVG.toggle24h && index === 0 ? customGreen : "white"
                    opacity: inactiveContentOpacity
                    text: (index === 0 ? 12 : index)

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: index === 6 ?
                                   0 :
                                   ([4, 5, 7, 8].includes(index)) ?
                                       (index * 30) + 180 :
                                       index * 30
                    }
                }
            }

            Item {
                // Wrapper for digital time related objects. Hour, minute and AP following units setting.
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
                    font {
                        pixelSize: digitalBox.width * .46
                        family: "Noto Sans"
                        styleName: "Regular"
                        letterSpacing: -digitalBox.width * .001
                    }
                    color: "#ccffffff"
                    text: if (use12H.value) {
                              wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2)}
                          else
                              wallClock.time.toLocaleString(Qt.locale(), "HH")
                }

                Text {
                    id: digitalMinutes

                    anchors {
                        left: digitalHour.right
                        bottom: digitalHour.bottom
                        leftMargin: digitalBox.width * .01
                    }
                    font {
                        pixelSize: digitalBox.width * .46
                        family: "Noto Sans"
                        styleName: "Light"
                        letterSpacing: -digitalBox.width * .001
                    }
                    color: "#ddffffff"
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
                    font {
                        pixelSize: digitalBox.width * 0.14
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }
                    visible: use12H.value
                    color: "#ddffffff"
                    text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
                }
            }

            Item {
                // Wrapper for weather related elements. Contains a weatherIcon and maxTemp display.
                // "No weather data" text is shown when no data is available.
                // ConfigurationValue depends on Nemo.Configuration 1.0
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

                // Work around for the beta release here. Currently catching for -273° string to display the no data message.
                // Plan is to use the commented check. But the result is always false like used now. Likely due to timestamp0 expecting a listview or delegate?
                property bool weatherSynced: kelvinToTemperatureString(maxTemp.value) !== "-273°" //availableDays(timestampDay0.value*1000) > 0

                Canvas {
                    id: weatherArc

                    anchors.fill: weatherBox
                    opacity: inactiveArcOpacity
                    smooth: true
                    visible: !dockMode.active
                    renderStrategy : Canvas.Cooperative
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.lineWidth = outerArcLineWidth
                        ctx.lineCap="round"
                        ctx.strokeStyle = "#33ffffff"
                        ctx.beginPath()
                        ctx.arc(weatherBox.width / 2,
                                weatherBox.height / 2,
                                weatherBox.width * .43,
                                270 * rad,
                                360,
                                false);
                        ctx.stroke()
                        ctx.closePath()
                        ctx.beginPath()
                        ctx.fillStyle = "#22ffffff"
                        ctx.arc(weatherBox.width / 2,
                                weatherBox.height / 2,
                                weatherBox.width * .43,
                                270 * rad,
                                360,
                                false);
                        ctx.strokeStyle = boxColor
                        ctx.lineWidth = innerArcLineWidth
                        ctx.stroke()
                        ctx.fill()
                        ctx.closePath()
                    }
                }

                Icon {
                    // WeatherIcons depends on import 'weathericons.js' as WeatherIcons
                    id: iconDisplay

                    anchors {
                        centerIn: weatherBox
                        verticalCenterOffset: -parent.height * .155
                    }
                    width: weatherBox.width * .42
                    height: width
                    opacity: activeContentOpacity
                    visible: weatherBox.weatherSynced
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
                    text: weatherBox.weatherSynced ? kelvinToTemperatureString(maxTemp.value) : "NO<br>WEATHER<br>DATA"
                }
            }

            Item {
                // Wrapper for date related objects, day name, day number and month short code.
                id: dayBox

                anchors {
                    centerIn: dialBox
                    horizontalCenterOffset: !dockMode.active ? boxPosition : boxPosition * .78
                }
                width: boxSize
                height: width

                Canvas {
                    id: dayArc

                    anchors.fill: dayBox
                    opacity: inactiveArcOpacity
                    smooth: true
                    visible: !dockMode.active
                    renderStrategy : Canvas.Cooperative
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.beginPath()
                        ctx.fillStyle = "#22ffffff"
                        ctx.arc(dayBox.width / 2,
                                dayBox.height / 2,
                                dayBox.width * .43,
                                270 * rad,
                                360,
                                false);
                        ctx.strokeStyle = boxColor
                        ctx.lineWidth = innerArcLineWidth
                        ctx.stroke()
                        ctx.fill()
                        ctx.closePath()
                        ctx.lineWidth = outerArcLineWidth
                        ctx.lineCap="round"
                        ctx.strokeStyle = "#33ffffff"
                        ctx.beginPath()
                        ctx.arc(dayBox.width / 2,
                                dayBox.height / 2,
                                dayBox.width * .43,
                                270 * rad,
                                360,
                                false);
                        ctx.stroke()
                        ctx.closePath()
                    }
                }

                Text {
                    id: dayName

                    anchors {
                        centerIn: dayBox
                        verticalCenterOffset: -dayBox.width * .25
                    }
                    font {
                        pixelSize: dayBox.width * .14
                        family: "Barlow"
                        styleName: "Bold"
                    }
                    color: "#ffffffff"
                    opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
                    text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 3).toUpperCase()
                }

                Text {
                    id: dayNumber

                    anchors {
                        centerIn: dayBox
                    }
                    font {
                        pixelSize: dayBox.width * .38
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }
                    color: "#ffffffff"
                    opacity: activeContentOpacity
                    text: wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()
                }

                Text {
                    id: monthName

                    anchors {
                        centerIn: dayBox
                        verticalCenterOffset: dayBox.width * .25
                    }
                    font {
                        pixelSize: dayBox.width * .14
                        family: "Barlow"
                        styleName: "Bold"
                    }
                    color: "#ffffffff"
                    opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
                    text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase()
                }
            }

            Item {
                // Wrapper for the battery related elements
                // MceBatteryLevel and MceBatteryState depend on Nemo.Mce 1.0
                id: batteryBox

                property int value: batteryChargePercentage.percent

                onValueChanged: batteryArc.requestPaint()

                anchors {
                    centerIn: dialBox
                    verticalCenterOffset: boxPosition
                }
                width: boxSize
                height: width
                visible: !dockMode.active

                Canvas {
                    id: batteryArc

                    anchors.fill: batteryBox
                    opacity: activeArcOpacity
                    smooth: true
                    renderStrategy : Canvas.Cooperative
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.beginPath()
                        ctx.fillStyle = "#22ffffff"
                        ctx.arc(batteryBox.width / 2,
                                batteryBox.height / 2,
                                batteryBox.width * .43,
                                270 * rad,
                                360,
                                false);
                        ctx.strokeStyle = "#77ffffff"
                        ctx.lineWidth = innerArcLineWidth
                        ctx.stroke()
                        ctx.fill()
                        ctx.closePath()
                        ctx.lineWidth = outerArcLineWidth
                        ctx.lineCap="round"
                        ctx.strokeStyle = batteryBox.value < 30 ?
                                    customRed :
                                    batteryBox.value < 60 ?
                                        customOrange :
                                        customGreen
                        ctx.beginPath()
                        ctx.arc(batteryBox.width / 2,
                                batteryBox.height / 2,
                                batteryBox.width * .43,
                                270 * rad,
                                ((batteryBox.value/100*360)+270) * rad,
                                false
                                );
                        ctx.stroke()
                        ctx.closePath()
                    }
                }

                Icon {
                    id: batteryIcon

                    name: "ios-flash"
                    visible: batteryChargeState.value === MceBatteryState.Charging
                    anchors {
                        centerIn: batteryBox
                        verticalCenterOffset: -batteryBox.height * .26
                    }
                    width: batteryBox.width * .25
                    height: width
                    opacity: inactiveContentOpacity
                }

                Text {
                    id: batteryDisplay

                    anchors {
                        centerIn: batteryBox
                    }
                    font {
                        pixelSize: batteryBox.width * .38
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }
                    color: "#ffffffff"
                    opacity: activeContentOpacity
                    text: batteryBox.value
                }

                Text {
                    id: chargeText

                    anchors {
                        centerIn: batteryBox
                        verticalCenterOffset: batteryBox.width * .25
                    }
                    font {
                        pixelSize: batteryBox.width * .14
                        family: "Barlow"
                        styleName: "Bold"
                    }
                    color: "#ffffffff"
                    opacity: inactiveContentOpacity
                    text: "%"
                }
            }
        }

        Item {
            // Wrapper for the analog hands
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
                antialiasing: true
                smooth: true

                transform: Rotation {
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                    angle: hourSVG.toggle24h ?
                               (wallClock.time.getHours() * 15) + (wallClock.time.getMinutes() * .25) :
                               (wallClock.time.getHours() * 30) + (wallClock.time.getMinutes() * .5)
                }

                layer {
                    enabled: true
                    samples: 4
                    smooth: true
                    textureSize: Qt.size(root.width * 2, root.height * 2)
                    // DropShadow depends on import QtGraphicalEffects 1.15
                    effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        samples: 17
                        color: Qt.rgba(0, 0, 0, .2)
                    }
                }
            }

            Image {
                id: minuteSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                source: imgPath + "minute.svg"
                antialiasing: true
                smooth: true

                transform: Rotation {
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                    angle: (wallClock.time.getMinutes() * 6) + (wallClock.time.getSeconds() * 6 / 60)
                }

                layer {
                    enabled: true
                    samples: 4
                    smooth: true
                    textureSize: Qt.size(root.width * 2, root.height * 2)
                    effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 5
                        verticalOffset: 5
                        radius: 10.0
                        samples: 21
                        color: Qt.rgba(0, 0, 0, .2)
                    }
                }
            }

            Image {
                id: secondSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                source: imgPath + "second.svg"
                antialiasing: true
                smooth: true
                visible: !displayAmbient && !dockMode.active

                transform: Rotation {
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                    angle: wallClock.time.getSeconds() * 6

                    Behavior on angle {
                        enabled: !displayAmbient && !nightstand
                        RotationAnimation {
                            duration: 1000
                            direction: RotationAnimation.Clockwise
                        }
                    }
                }

                layer {
                    enabled: true
                    samples: 4
                    smooth: true
                    textureSize: Qt.size(root.width * 2, root.height * 2)
                    effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 5
                        verticalOffset: 5
                        radius: 10.0
                        samples: 21
                        color: Qt.rgba(0, 0, 0, .2)
                    }
                }
            }
        }
    }
}
