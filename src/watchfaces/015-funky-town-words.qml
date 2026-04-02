// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    anchors.fill: parent

    property string imgPath: "../watchfaces-img/funky-town-words-"

    Item {
        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        // OpacityMask clips square SVGs to circle on round screens — layer disabled on square screens for zero cost
        Item {
            id: imageWrapper

            anchors.fill: parent
            layer.enabled: DeviceSpecs.hasRoundScreen
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: imageWrapper.width
                    height: imageWrapper.height
                    radius: width / 2
                    visible: false
                }
            }

            Image {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                source: imgPath +
                        wallClock.time.toLocaleString(Qt.locale(), "hh am").slice(0, 2) +
                        (nightstandMode.active || displayAmbient ? "-bw.svg" : ".svg")
                sourceSize.width: parent.width
                sourceSize.height: parent.height
            }

            Image {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                visible: use12H.value
                source: imgPath +
                        wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase().slice(0, 2) + ".svg"
                sourceSize.width: parent.width
                sourceSize.height: parent.height
            }
        }

        Text {
            id: minuteDisplay

            anchors {
                bottom: parent.bottom
                bottomMargin: parent.height * .15
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: parent.width * .2
            }
            color: nightstandMode.active || displayAmbient ? "#000" : "#fff"
            font {
                pixelSize: parent.height * .22
                family: "Source Sans Pro"
                styleName: "Light"
            }
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")

            Behavior on text {
                enabled: !displayAmbient

                SequentialAnimation {
                    NumberAnimation { target: minuteDisplay; property: "opacity"; to: 0 }
                    PropertyAction {}
                    NumberAnimation { target: minuteDisplay; property: "opacity"; to: 1 }
                }
            }
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
                property real arcStrokeWidth: .016
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

            Text {
                id: batteryPercent

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.width * .28
                }
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                font {
                    pixelSize: parent.width * .13
                    family: "Source Sans Pro"
                    styleName: "Light"
                }
                text: batteryChargePercentage.percent
            }
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Component.onCompleted: {
            burnInProtectionManager.leftOffset = Qt.binding(function() { return width * (nightstandMode.active ? .05 : .4) })
            burnInProtectionManager.rightOffset = Qt.binding(function() { return width * .05 })
            burnInProtectionManager.topOffset = Qt.binding(function() { return height * (nightstandMode.active ? .05 : .4) })
            burnInProtectionManager.bottomOffset = Qt.binding(function() { return height * .05 })
        }
    }
}
