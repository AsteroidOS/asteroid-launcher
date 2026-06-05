// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes

Item {
    property string imgPath: "../watchfaces-img/funky-town-words-"

    anchors.fill: parent

    Item {
        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height
        Component.onCompleted: {
            burnInProtectionManager.leftOffset = Qt.binding(function() {
                return width * (nightstandMode.active ? 0.05 : 0.4);
            });
            burnInProtectionManager.rightOffset = Qt.binding(function() {
                return width * 0.05;
            });
            burnInProtectionManager.topOffset = Qt.binding(function() {
                return height * (nightstandMode.active ? 0.05 : 0.4);
            });
            burnInProtectionManager.bottomOffset = Qt.binding(function() {
                return height * 0.05;
            });
        }

        Image {
            anchors.centerIn: parent
            source: imgPath + wallClock.time.toLocaleString(Qt.locale(), "hh am").slice(0, 2) + (nightstandMode.active || displayAmbient ? "-bw.svg" : ".svg")
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            width: parent.width
            height: parent.height
        }

        Image {
            anchors.centerIn: parent
            source: imgPath + wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase().slice(0, 2) + ".svg"
            visible: use12H.value
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            width: parent.width
            height: parent.height
        }

        Text {
            id: minuteDisplay

            renderType: Text.NativeRendering
            color: nightstandMode.active || displayAmbient ? "#000" : "#fff"
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")

            anchors {
                bottom: parent.bottom
                bottomMargin: parent.height * 0.15
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: parent.width * 0.2
            }

            font {
                pixelSize: parent.height * 0.22
                family: "Source Sans Pro"
                weight: Font.Light
            }

            Behavior on text {
                enabled: !displayAmbient

                SequentialAnimation {
                    NumberAnimation {
                        target: minuteDisplay
                        property: "opacity"
                        to: 0
                    }

                    PropertyAction {
                    }

                    NumberAnimation {
                        target: minuteDisplay
                        property: "opacity"
                        to: 1
                    }

                }

            }

        }

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: parent
            visible: nightstandMode.active

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                property real arcStrokeWidth: 0.016
                property real scalefactor: 0.45 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: parent

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: parent.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.MiterJoin
                    startX: chargeArc.width / 2
                    startY: chargeArc.height * (0.5 - chargeArc.scalefactor)

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

                renderType: Text.NativeRendering
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                text: batteryChargePercentage.percent

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.width * 0.28
                }

                font {
                    pixelSize: parent.width * 0.13
                    family: "Source Sans Pro"
                    weight: Font.Light
                }

            }

        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

    }

}
