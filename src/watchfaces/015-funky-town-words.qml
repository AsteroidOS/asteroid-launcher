// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import org.asteroid.controls
import org.asteroid.utils
import Nemo.Mce

Item {
    anchors.fill: parent

    property string imgPath: "../watchfaces-img/funky-town-words-"

    Item {
        anchors.centerIn: parent

        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Image {
            anchors.centerIn: parent
            source: imgPath +
                    wallClock.time.toLocaleString(Qt.locale(), "hh am").slice(0, 2) +
                    (nightstandMode.active || displayAmbient ? "-bw.svg" : ".svg")
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            width: parent.width
            height: parent.height
        }

        Image {
            anchors.centerIn: parent
            source: imgPath +
                    wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase().slice(0, 2) + ".svg"
            visible: use12H.value
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            width: parent.width
            height: parent.height
        }

        Text {
            id: minuteDisplay

            anchors {
                bottom: parent.bottom
                bottomMargin: parent.height * .15
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: parent.width*.2
            }
            font {
                pixelSize: parent.height * .22
                family: "Source Sans Pro"
                styleName: "Light"
            }
            color: nightstandMode.active || displayAmbient ? "#000" : "#fff"
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
            visible: nightstandMode.active
            layer {
                enabled: true
                samples: 4
                smooth: true
                textureSize: Qt.size(nightstandMode.width * 2, nightstandMode.height * 2)
            }

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                // radius of arc is scalefactor * height or width
                property real arcStrokeWidth: .016
                property real scalefactor: .45 - (arcStrokeWidth / 2)
                property real chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: [ "red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                anchors.fill: parent
                smooth: true
                antialiasing: true

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: parent.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.MiterJoin
                    startX: chargeArc.width / 2
                    startY: chargeArc.height * ( .5 - chargeArc.scalefactor)

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

                font {
                    pixelSize: parent.width * .13
                    family: "Source Sans Pro"
                    styleName: "Light"
                }
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                text: batteryChargePercentage.percent
            }
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        MceBatteryState {
            id: batteryChargeState
        }

        MceCableState {
            id: mceCableState
        }

        Component.onCompleted: {
            burnInProtectionManager.leftOffset = Qt.binding(function() { return width * nightstandMode.active ? .05 : .4})
            burnInProtectionManager.rightOffset = Qt.binding(function() { return width * .05})
            burnInProtectionManager.topOffset = Qt.binding(function() { return height * nightstandMode.active ? .05 : .4})
            burnInProtectionManager.bottomOffset = Qt.binding(function() { return height * .05})
        }
    }
}
