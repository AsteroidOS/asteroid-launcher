// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2017 Mario Kicherer <dev@kicherer.org>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

/*
 * Based on analog-precison by Mario Kicherer. Remodeled the arms to arcs
 * and tried hard on font centering and anchor alignment.
 */

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    anchors.fill: parent

    Item {
        id: root

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Rectangle {
            anchors.centerIn: parent
            width: parent.width / 1.3
            height: width
            radius: width * .5
            color: Qt.rgba(0, 0, 0, .2)
        }

        // Second arc — outermost ring, red, declarative sweep from wallClock binding
        Shape {
            id: secondArc

            anchors.fill: parent
            visible: !displayAmbient && !nightstandMode.active

            property real secondAngle: 0

            ShapePath {
                strokeColor: Qt.rgba(.871, .165, .102, .95)
                strokeWidth: root.width * .009375
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.width / 2.2
                    radiusY: root.height / 2.2
                    startAngle: -89.5
                    sweepAngle: secondArc.secondAngle
                }
            }
        }

        // Minute arc — middle ring, orange, declarative sweep from wallClock binding
        Shape {
            id: minuteArc

            anchors.fill: parent
            visible: !displayAmbient && !nightstandMode.active

            property real minuteAngle: 0

            ShapePath {
                strokeColor: Qt.rgba(1, .549, .149, .95)
                strokeWidth: root.width * .01875
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.width / 2.33
                    radiusY: root.height / 2.33
                    startAngle: -88.8
                    sweepAngle: minuteArc.minuteAngle
                }
            }
        }

        // Hour arc — inner ring, gold, start offset at 273.5° aligns arc origin just past 12 o'clock
        Shape {
            id: hourArc

            anchors.fill: parent
            visible: !displayAmbient && !nightstandMode.active

            property real hourAngle: 0

            ShapePath {
                strokeColor: Qt.rgba(.945, .769, .059, .95)
                strokeWidth: root.width * .05
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.width / 2.6
                    radiusY: root.height / 2.6
                    startAngle: 273.5
                    sweepAngle: hourArc.hourAngle
                }
            }
        }

        Text {
            id: hourDisplay

            anchors {
                right: parent.horizontalCenter
                rightMargin: -parent.height * .0938
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: parent.height * .0281
            }
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, .5)
            font {
                pixelSize: parent.height * .375
                family: "Titillium"
                styleName: "Bold"
                letterSpacing: -3
            }
            text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) :
                                 wallClock.time.toLocaleString(Qt.locale(), "HH")
        }

        Text {
            id: minuteDisplay

            anchors {
                top: hourDisplay.top
                topMargin: -parent.height * .015625
                left: hourDisplay.right
                leftMargin: parent.width * .025
            }
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, .5)
            font {
                pixelSize: parent.height * .1375
                styleName: "Semibold"
                letterSpacing: -1
            }
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")
        }

        Text {
            id: secondDisplay

            anchors {
                bottom: hourDisplay.bottom
                bottomMargin: parent.height * .059375
                left: hourDisplay.right
                leftMargin: parent.width * .025
            }
            visible: !displayAmbient
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignHCenter
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, .5)
            font {
                pixelSize: parent.height * .1375
                family: "Titillium"
                styleName: "Thin"
                letterSpacing: -1
            }
            text: wallClock.time.toLocaleString(Qt.locale(), "ss")
        }

        Text {
            id: dowDisplay

            anchors {
                bottom: hourDisplay.top
                left: parent.left
                right: parent.right
            }
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignHCenter
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, .5)
            font {
                pixelSize: parent.height * .084375
                family: "Titillium"
                styleName: "Thin"
            }
            text: wallClock.time.toLocaleString(Qt.locale(), "dddd")
        }

        Text {
            id: dateDisplay

            anchors {
                top: hourDisplay.bottom
                topMargin: -parent.height * .05
                left: parent.left
                right: parent.right
            }
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignHCenter
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, .5)
            font {
                pixelSize: parent.height * .084375
                family: "Titillium"
                styleName: "Thin"
            }
            text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b> MMMM")
        }

        Text {
            id: pmDisplay

            anchors {
                bottom: dowDisplay.top
                bottomMargin: parent.height * .018
                left: parent.left
                right: parent.right
            }
            visible: use12H.value
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignHCenter
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, .5)
            font {
                pixelSize: parent.height * .05
                family: "Titillium"
                styleName: "Semibold"
            }
            text: wallClock.time.toLocaleString(Qt.locale(), "<b>ap</b>")
        }

        Item {
            id: nightstandMode

            readonly property bool active: nightstand
            property int batteryPercentChanged: batteryChargePercentage.percent

            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4
            visible: nightstandMode.active

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                property real arcStrokeWidth: .03
                property real scalefactor: .45 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                anchors.fill: parent

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: parent.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.MiterJoin
                    startX: chargeArc.width / 2
                    startY: chargeArc.height * (.5 - chargeArc.scalefactor)

                    PathAngleArc {
                        centerX: chargeArc.width / 2
                        centerY: chargeArc.height / 2
                        radiusX: chargeArc.scalefactor * chargeArc.width
                        radiusY: chargeArc.scalefactor * chargeArc.height
                        startAngle: -90
                        sweepAngle: chargeArc.angle
                        moveToStart: false
                    }
                }
            }

            Icon {
                id: batteryIcon

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.width * .316
                }
                visible: nightstandMode.active
                width: parent.width * .14
                height: parent.height * .14
                name: "ios-battery-charging"
            }

            ColorOverlay {
                anchors.fill: batteryIcon
                source: batteryIcon
                color: chargeArc.colorArray[chargeArc.chargecolor]
            }

            Text {
                id: batteryPercent

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .324
                }
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline
                styleColor: "#80000000"
                font {
                    pixelSize: parent.width * .09
                    family: "Titillium"
                    styleName: "ExtraCondensed"
                }
                text: batteryChargePercentage.percent + "%"
            }
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Connections {
            target: wallClock
            function onTimeChanged() {
                var h = wallClock.time.getHours()
                var min = wallClock.time.getMinutes()
                var sec = wallClock.time.getSeconds()
                secondArc.secondAngle = Math.max(0, sec * 6 - 0.5)
                minuteArc.minuteAngle = Math.max(0, min * 6 - 1.2)
                hourArc.hourAngle = ((h * 30 + min * 0.5 - 3.5) % 360 + 360) % 360
            }
        }

        Component.onCompleted: {
            var h = wallClock.time.getHours()
            var min = wallClock.time.getMinutes()
            var sec = wallClock.time.getSeconds()
            secondArc.secondAngle = Math.max(0, sec * 6 - 0.5)
            minuteArc.minuteAngle = Math.max(0, min * 6 - 1.2)
            hourArc.hourAngle = ((h * 30 + min * 0.5 - 3.5) % 360 + 360) % 360
            burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .08 : .3) })
            burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .08 : .3) })
        }
    }
}
