// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import Nemo.Configuration
import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import QtSensors
import org.asteroid.controls
import org.asteroid.utils
import "weathericons.js" as WeatherIcons

Item {
    // Uranian Blue

    property string imgPath: "../watchfaces-img/analog-weather-satellite-"
    // Element sizes, positioning, linewidth and opacity
    property real switchSize: root.width * 0.1375
    property real boxSize: root.width * 0.35
    property real switchPosition: root.width * 0.26
    property real boxPosition: root.width * 0.25
    property real innerArcLineWidth: root.height * 0.008
    property real outerArcLineWidth: root.height * 0.016
    property real activeArcOpacity: !displayAmbient ? 0.7 : 0.4
    property real inactiveArcOpacity: !displayAmbient ? 0.5 : 0.3
    property real activeContentOpacity: !displayAmbient ? 0.95 : 0.6
    property real inactiveContentOpacity: !displayAmbient ? 0.5 : 0.3
    // Color definition
    property string customRed: "#DB5461"
    // Indian Red
    property string customBlue: "#1E96FC"
    // Dodger Blue
    property string customGreen: "#26C485"
    // Ocean Green
    property string customOrange: "#FFC600"
    // Mikado Yellow
    property string boxColor: "#E8DCB9"
    // Dutch White
    property string switchColor: "#A2D6F9"
    // Set day to use in the weatherBox to today.
    property int dayNb: 0

    function kelvinToTemperatureString(kelvin) {
        var celsius = (kelvin - 273);
        if (!useFahrenheit.value)
            return celsius + "°";
        else
            return Math.round(((celsius) * 9 / 5) + 32) + "°";
    }

    anchors.fill: parent

    Item {
        id: root

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height
        Component.onCompleted: {
            var h = wallClock.time.getHours();
            var min = wallClock.time.getMinutes();
            var sec = wallClock.time.getSeconds();
            hourRot.angle = hourSVG.toggle24h ? h * 15 + min * 0.25 : h * 30 + min * 0.5;
            minuteRot.angle = min * 6 + sec * 6 / 60;
        }

        MceBatteryState {
            id: batteryChargeState
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Item {
            id: dockMode

            readonly property bool active: nightstand

            anchors.fill: root
            visible: dockMode.active

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                property real arcStrokeWidth: 0.016
                property real scalefactor: 0.39 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: dockMode

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: dockMode.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.MiterJoin
                    startX: chargeArc.width / 2
                    startY: chargeArc.height * (0.5 - chargeArc.scalefactor)

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

                visible: dockMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline
                styleColor: "#80000000"
                renderType: Text.NativeRendering
                text: batteryChargePercentage.percent

                anchors {
                    centerIn: dockMode
                    verticalCenterOffset: dockMode.width * 0.22
                }

                font {
                    pixelSize: dockMode.width * 0.15
                    family: "Noto Sans"
                    styleName: "Condensed Light"
                }

            }

        }

        Item {
            id: dialBox

            anchors.fill: parent
            // Slight dropshadow under all Items.
            layer.enabled: true

            Repeater {
                model: 60

                Rectangle {
                    id: minuteStrokes

                    property real rotM: (index - 15) / 60
                    property real centerX: root.width / 2 - width / 2
                    property real centerY: root.height / 2 - height / 2

                    x: centerX + Math.cos(rotM * 2 * Math.PI) * root.width * 0.46
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * root.width * 0.46
                    visible: index % 5
                    antialiasing: true
                    color: "#55ffffff"
                    width: root.width * 0.005
                    height: root.height * 0.018

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

                    x: centerX + Math.cos(rotM * 2 * Math.PI) * root.width * 0.46
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * root.width * 0.46
                    antialiasing: true
                    color: hourSVG.toggle24h && index === 0 ? customGreen : "white"
                    opacity: inactiveContentOpacity
                    renderType: Text.NativeRendering
                    text: (index === 0 ? 12 : index)

                    font {
                        pixelSize: root.height * 0.06
                        family: "Noto Sans"
                        styleName: "Bold"
                    }

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: index === 6 ? 0 : ([4, 5, 7, 8].includes(index)) ? (index * 30) + 180 : index * 30
                    }

                }

            }

            Item {
                // Wrapper for digital time related objects. Hour, minute and AP following units setting.
                id: digitalBox

                width: !dockMode.active ? boxSize : boxSize * 0.84
                height: width
                opacity: activeContentOpacity

                anchors {
                    centerIn: dialBox
                    verticalCenterOffset: dockMode.active ? -root.width * 0.21 : -root.width * 0.29
                }

                Text {
                    id: digitalHour

                    color: "#ccffffff"
                    renderType: Text.NativeRendering
                    text: {
                        if (use12H.value) {
                            wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2);
                        } else {
                            wallClock.time.toLocaleString(Qt.locale(), "HH");
                        }
                    }

                    anchors {
                        right: digitalBox.horizontalCenter
                        rightMargin: digitalBox.width * 0.01
                        verticalCenter: digitalBox.verticalCenter
                    }

                    font {
                        pixelSize: digitalBox.width * 0.46
                        family: "Noto Sans"
                        styleName: "Regular"
                        letterSpacing: -digitalBox.width * 0.001
                    }

                }

                Text {
                    id: digitalMinutes

                    color: "#ddffffff"
                    renderType: Text.NativeRendering
                    text: wallClock.time.toLocaleString(Qt.locale(), "mm")

                    anchors {
                        left: digitalHour.right
                        bottom: digitalHour.bottom
                        leftMargin: digitalBox.width * 0.01
                    }

                    font {
                        pixelSize: digitalBox.width * 0.46
                        family: "Noto Sans"
                        styleName: "Light"
                        letterSpacing: -digitalBox.width * 0.001
                    }

                }

                Text {
                    id: apDisplay

                    visible: use12H.value
                    color: "#ddffffff"
                    renderType: Text.NativeRendering
                    text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()

                    anchors {
                        left: digitalMinutes.right
                        leftMargin: digitalBox.width * 0.09
                        bottom: digitalMinutes.verticalCenter
                        bottomMargin: -digitalBox.width * 0.22
                    }

                    font {
                        pixelSize: digitalBox.width * 0.14
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }

                }

            }

            Item {
                // Wrapper for weather related elements. Contains a weatherIcon and maxTemp display.
                // "No weather data" text is shown when no data is available.
                // ConfigurationValue depends on Nemo.Configuration 1.0
                id: weatherBox

                property bool weatherSynced: maxTemp.value != 0

                width: boxSize
                height: width

                anchors {
                    centerIn: dialBox
                    horizontalCenterOffset: !dockMode.active ? -boxPosition : -boxPosition * 0.78
                }

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

                Rectangle {
                    id: weatherArc

                    anchors.centerIn: parent
                    width: parent.width * 0.86
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    opacity: inactiveArcOpacity
                    visible: !dockMode.active

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: outerArcLineWidth
                        border.color: "#33ffffff"
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: innerArcLineWidth
                        border.color: boxColor
                    }

                }

                Icon {
                    id: iconDisplay

                    width: weatherBox.width * 0.42
                    height: width
                    opacity: activeContentOpacity
                    visible: weatherBox.weatherSynced
                    name: WeatherIcons.getIconName(owmId.value)

                    anchors {
                        centerIn: weatherBox
                        verticalCenterOffset: -parent.height * 0.155
                    }

                }

                Label {
                    id: maxDisplay

                    width: weatherBox.width
                    height: width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    opacity: activeContentOpacity
                    renderType: Text.NativeRendering
                    textFormat: Text.StyledText
                    text: weatherBox.weatherSynced ? kelvinToTemperatureString(maxTemp.value) : "NO<br>WEATHER<br>DATA"

                    anchors {
                        centerIn: weatherBox
                        verticalCenterOffset: weatherBox.height * (weatherBox.weatherSynced ? 0.155 : 0)
                        horizontalCenterOffset: weatherBox.height * (weatherBox.weatherSynced ? 0.05 : 0)
                    }

                    font {
                        family: "Barlow"
                        styleName: weatherBox.weatherSynced ? "Medium" : "Bold"
                        pixelSize: weatherBox.width * (weatherBox.weatherSynced ? 0.3 : 0.14)
                    }

                }

            }

            Item {
                // Wrapper for date related objects, day name, day number and month short code.
                id: dayBox

                width: boxSize
                height: width

                anchors {
                    centerIn: dialBox
                    horizontalCenterOffset: !dockMode.active ? boxPosition : boxPosition * 0.78
                }

                Rectangle {
                    id: dayArc

                    anchors.centerIn: parent
                    width: parent.width * 0.86
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    opacity: inactiveArcOpacity
                    visible: !dockMode.active

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: outerArcLineWidth
                        border.color: "#33ffffff"
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: innerArcLineWidth
                        border.color: boxColor
                    }

                }

                Text {
                    id: dayName

                    color: "#ffffffff"
                    opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
                    renderType: Text.NativeRendering
                    text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 3).toUpperCase()

                    anchors {
                        centerIn: dayBox
                        verticalCenterOffset: -dayBox.width * 0.25
                    }

                    font {
                        pixelSize: dayBox.width * 0.14
                        family: "Barlow"
                        styleName: "Bold"
                    }

                }

                Text {
                    id: dayNumber

                    anchors.centerIn: dayBox
                    color: "#ffffffff"
                    opacity: activeContentOpacity
                    renderType: Text.NativeRendering
                    text: wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()

                    font {
                        pixelSize: dayBox.width * 0.38
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }

                }

                Text {
                    id: monthName

                    color: "#ffffffff"
                    opacity: displayAmbient ? inactiveArcOpacity : activeContentOpacity
                    renderType: Text.NativeRendering
                    text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase()

                    anchors {
                        centerIn: dayBox
                        verticalCenterOffset: dayBox.width * 0.25
                    }

                    font {
                        pixelSize: dayBox.width * 0.14
                        family: "Barlow"
                        styleName: "Bold"
                    }

                }

            }

            Item {
                // Wrapper for the battery related elements
                // MceBatteryLevel and MceBatteryState depend on Nemo.Mce 1.0
                id: batteryBox

                property int value: batteryChargePercentage.percent

                width: boxSize
                height: width
                visible: !dockMode.active

                anchors {
                    centerIn: dialBox
                    verticalCenterOffset: boxPosition
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.86
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    opacity: activeArcOpacity
                    border.width: innerArcLineWidth
                    border.color: "#77ffffff"
                }

                Shape {
                    id: batteryArc

                    anchors.fill: parent
                    opacity: activeArcOpacity

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: batteryBox.value < 30 ? customRed : batteryBox.value < 60 ? customOrange : customGreen
                        strokeWidth: outerArcLineWidth
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.MiterJoin
                        startX: batteryArc.width / 2
                        startY: batteryArc.height * (0.5 - 0.43)

                        PathAngleArc {
                            centerX: batteryBox.width / 2
                            centerY: batteryBox.height / 2
                            radiusX: batteryBox.width * 0.43
                            radiusY: batteryBox.height * 0.43
                            startAngle: -90
                            sweepAngle: batteryBox.value / 100 * 360
                            moveToStart: false
                        }

                    }

                }

                Icon {
                    id: batteryIcon

                    name: "ios-flash"
                    visible: batteryChargeState.value === MceBatteryState.Charging
                    width: batteryBox.width * 0.25
                    height: width
                    opacity: inactiveContentOpacity

                    anchors {
                        centerIn: batteryBox
                        verticalCenterOffset: -batteryBox.height * 0.26
                    }

                }

                Text {
                    id: batteryDisplay

                    color: "#ffffffff"
                    opacity: activeContentOpacity
                    renderType: Text.NativeRendering
                    text: batteryBox.value

                    anchors {
                        centerIn: batteryBox
                    }

                    font {
                        pixelSize: batteryBox.width * 0.38
                        family: "Noto Sans"
                        styleName: "Condensed"
                    }

                }

                Text {
                    id: chargeText

                    color: "#ffffffff"
                    opacity: inactiveContentOpacity
                    renderType: Text.NativeRendering
                    text: "%"

                    anchors {
                        centerIn: batteryBox
                        verticalCenterOffset: batteryBox.width * 0.25
                    }

                    font {
                        pixelSize: batteryBox.width * 0.14
                        family: "Barlow"
                        styleName: "Bold"
                    }

                }

            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 1
                verticalOffset: 1
                radius: 6
                samples: 13
                color: Qt.rgba(0, 0, 0, 0.7)
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
                layer.enabled: true

                transform: Rotation {
                    id: hourRot

                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8
                    samples: 9
                    color: Qt.rgba(0, 0, 0, 0.2)
                }

            }

            Image {
                id: minuteSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                source: imgPath + "minute.svg"
                layer.enabled: true

                transform: Rotation {
                    id: minuteRot

                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 5
                    verticalOffset: 5
                    radius: 10
                    samples: 9
                    color: Qt.rgba(0, 0, 0, 0.2)
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

        Timer {
            interval: 16
            repeat: true
            running: !displayAmbient && !dockMode.active && visible
            onTriggered: {
                var now = new Date();
                secondRot.angle = (now.getSeconds() * 1000 + now.getMilliseconds()) * 6 / 1000;
            }
        }

        Connections {
            function onTimeChanged() {
                var h = wallClock.time.getHours();
                var min = wallClock.time.getMinutes();
                var sec = wallClock.time.getSeconds();
                hourRot.angle = hourSVG.toggle24h ? h * 15 + min * 0.25 : h * 30 + min * 0.5;
                minuteRot.angle = min * 6 + sec * 6 / 60;
            }

            target: wallClock
        }

    }

}
