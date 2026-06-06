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

        Rectangle {
            id: layer2mask

            anchors.centerIn: parent
            width: parent.width * (nightstand ? .86 : 1)
            height: width
            color: displayAmbient ? Qt.rgba(1, 1, 1, .8) : Qt.rgba(0, 0, 0, .8)
            visible: true
            opacity: .0
            layer.enabled: true
            layer.smooth: true
            radius: DeviceSpecs.hasRoundScreen || nightstand ? width : 0
        }

        Rectangle {
            id: _mask

            anchors.fill: layer2mask
            color: Qt.rgba(0, 1, 0, 0)
            visible: true

            Text {
                property real voffset: parent.height * .01

                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .58
                    letterSpacing: -parent.width * .08
                    family: "League Spartan"
                }
                color: Qt.rgba(1, 1, 1, 1)
                y: parent.height / 3 - height / 2 + voffset
                x: -parent.width * .055
                text: if (use12H.value) {
                          wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2).replace(/1/g," 1 ") }
                      else
                          wallClock.time.toLocaleString(Qt.locale(), "HH").replace(/1/g," 1 ")


            }

            Text {
                property real voffset: parent.height * .075

                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .58
                    letterSpacing: -parent.width * .06
                    family: "League Spartan"
                }
                color: Qt.rgba(1, 1, 1, 1)
                y: parent.height / 1.3 - height / 2 + voffset
                x: parent.width*.25
                text: wallClock.time.toLocaleString(Qt.locale(), "<b>mm</b>").replace(/1/g,"&nbsp;1")
            }

            Text {
                renderType: Text.NativeRendering
                anchors {
                    bottom: parent.verticalCenter
                    bottomMargin: -parent.height * .05
                    left: parent.horizontalCenter
                    leftMargin: parent.height * .19
                }
                font {
                    pixelSize: parent.height * .24
                    letterSpacing: -parent.width * .025
                    family: "League Spartan"
                }
                color: Qt.rgba(1, 1, 1, 1)
                visible: !displayAmbient
                text: wallClock.time.toLocaleString(Qt.locale(), "<b>ss</b>").replace(/1/g,"&nbsp;1")
            }

            Text {
                renderType: Text.NativeRendering
                anchors {
                    bottom: parent.verticalCenter
                    bottomMargin: parent.height * .25
                    left: parent.horizontalCenter
                    leftMargin: parent.height * .222
                }
                font {
                    pixelSize: parent.height * .1
                    letterSpacing: -parent.width * .01
                    family: "League Spartan"
                }
                visible: use12H.value
                lineHeight: .9
                color: Qt.rgba(1, 1, 1, 1)
                horizontalAlignment: Text.AlignRight
                text: wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase()
            }

            Text {
                renderType: Text.NativeRendering
                anchors {
                    top: parent.verticalCenter
                    topMargin: parent.height * .02
                    right: parent.horizontalCenter
                    rightMargin: parent.height * .24
                }
                font{
                    pixelSize: parent.height * .24
                    letterSpacing: -parent.width * .025
                    family: "League Spartan"
                }
                lineHeight: .7
                color: Qt.rgba(1, 1, 1, 1)
                horizontalAlignment: Text.AlignRight
                text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b>").toLowerCase()
            }

            Text {
                renderType: Text.NativeRendering
                anchors {
                    top: parent.verticalCenter
                    topMargin: parent.height * .235
                    right: parent.horizontalCenter
                    rightMargin: parent.height * .23
                }
                font {
                    pixelSize: parent.height*.1
                    letterSpacing: -parent.width * .01
                    family: "League Spartan"
                }
                lineHeight: .7
                color: Qt.rgba(1, 1, 1, 1)
                horizontalAlignment: Text.AlignRight
                text: wallClock.time.toLocaleString(Qt.locale(), "MMM").toLowerCase()
            }

            layer.enabled: true
            layer.samplerName: "maskSource"
            layer.effect: ShaderEffect {
                property variant source: layer2mask
                property bool keepInner: displayAmbient
                fragmentShader: "qrc:/shaders/masked-spartan.frag.qsb"
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
                property real arcStrokeWidth: .022
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
                    capStyle: ShapePath.FlatCap
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
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }
    }
}
