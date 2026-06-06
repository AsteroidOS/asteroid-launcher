// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later
// Based on a fragmentShader example from doc.qt.io. Design is heavily
// inspired by Jollas "The Bold Font" watchface.

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import org.asteroid.utils

Item {
    id: faceRoot

    anchors.fill: parent

    Rectangle {
        id: layer2mask

        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.75)
        visible: true
        opacity: 0
        layer.enabled: true
        layer.smooth: true
        radius: DeviceSpecs.hasRoundScreen || nightstand ? faceRoot.width : 0
    }

    Rectangle {
        id: _mask

        anchors.fill: layer2mask
        color: Qt.rgba(0, 1, 0, 0)
        visible: true
        opacity: displayAmbient ? 0.75 : 1
        layer.enabled: !displayAmbient
        layer.samplerName: "maskSource"

        Text {
            property real voffset: parent.height * 0.01

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            y: parent.height / 3 - height / 2 + voffset
            x: -parent.width * 0.055
            text: {
                if (use12H.value) {
                    wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2).replace(/1/g, " 1 ");
                } else {
                    wallClock.time.toLocaleString(Qt.locale(), "HH").replace(/1/g, " 1 ");
                }
            }

            font {
                pixelSize: parent.height * 0.58
                letterSpacing: -parent.width * 0.08
                family: "League Spartan"
            }

        }

        Text {
            property real voffset: parent.height * 0.075

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            y: parent.height / 1.3 - height / 2 + voffset
            x: parent.width * 0.25
            text: wallClock.time.toLocaleString(Qt.locale(), "<b>mm</b>").replace(/1/g, "&nbsp;1")

            font {
                pixelSize: parent.height * 0.58
                letterSpacing: -parent.width * 0.06
                family: "League Spartan"
            }

        }

        Text {
            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            visible: !displayAmbient
            text: wallClock.time.toLocaleString(Qt.locale(), "<b>ss</b>").replace(/1/g, "&nbsp;1")

            anchors {
                bottom: parent.verticalCenter
                bottomMargin: -parent.height * 0.05
                left: parent.horizontalCenter
                leftMargin: parent.height * 0.19
            }

            font {
                pixelSize: parent.height * 0.24
                letterSpacing: -parent.width * 0.025
                family: "League Spartan"
            }

        }

        Text {
            renderType: Text.NativeRendering
            visible: use12H.value
            lineHeight: 0.9
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignRight
            text: wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase()

            anchors {
                bottom: parent.verticalCenter
                bottomMargin: parent.height * 0.25
                left: parent.horizontalCenter
                leftMargin: parent.height * 0.222
            }

            font {
                pixelSize: parent.height * 0.1
                letterSpacing: -parent.width * 0.01
                family: "League Spartan"
            }

        }

        Text {
            renderType: Text.NativeRendering
            lineHeight: 0.7
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignRight
            text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b>").toLowerCase()

            anchors {
                top: parent.verticalCenter
                topMargin: parent.height * 0.02
                right: parent.horizontalCenter
                rightMargin: parent.height * 0.24
            }

            font {
                pixelSize: parent.height * 0.24
                letterSpacing: -parent.width * 0.025
                family: "League Spartan"
            }

        }

        Text {
            renderType: Text.NativeRendering
            lineHeight: 0.7
            color: Qt.rgba(1, 1, 1, 1)
            horizontalAlignment: Text.AlignRight
            text: wallClock.time.toLocaleString(Qt.locale(), "MMM").toLowerCase()

            anchors {
                top: parent.verticalCenter
                topMargin: parent.height * 0.235
                right: parent.horizontalCenter
                rightMargin: parent.height * 0.23
            }

            font {
                pixelSize: parent.height * 0.1
                letterSpacing: -parent.width * 0.01
                family: "League Spartan"
            }

        }

        layer.effect: ShaderEffect {
            property variant source: layer2mask
            property bool keepInner: false

            fragmentShader: "qrc:/shaders/masked-spartan.frag.qsb"
        }

    }

    Item {
        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: parent
            visible: nightstandMode.active

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                // radius of arc is scalefactor * height or width
                property real arcStrokeWidth: 0.022
                property real scalefactor: 0.45 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: parent

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: parent.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.FlatCap
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

        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

    }

}
