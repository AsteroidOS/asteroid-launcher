// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

/*
 * Based on a fragmentShader example from doc.qt.io. Design is heavily
 * inspired by Jollas "The Bold Font" watchface.
 */

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    id: root

    anchors.fill: parent

    // sq is the largest square that fits on any screen — text and mask geometry reference this
    property real sq: Math.min(width, height)

    // ShaderEffect stencil — numerals are cut from the wallpaper color.
    // This watchface requires a non-black wallpaper to be visible.
    Rectangle {
        id: layer2mask

        anchors.fill: parent
        color: displayAmbient ? Qt.rgba(1, 1, 1, .8) : Qt.rgba(0, 0, 0, .8)
        opacity: .0
        layer.enabled: true
        // nightstand shrinks the visible circle; round screens clip to sq circle; square screens use no radius
        radius: nightstand ? root.sq * .86 : DeviceSpecs.hasRoundScreen ? root.sq : 0
    }

    Rectangle {
        id: _mask

        anchors.fill: parent
        color: Qt.rgba(0, 1, 0, 0)

        // textRoot preserves the square geometry all text items were authored against
        Item {
            id: textRoot

            anchors.centerIn: parent
            width: nightstand ? root.sq * .86 : root.sq
            height: width

            Text {
                property real voffset: parent.height * .01

                renderType: Text.NativeRendering
                color: Qt.rgba(1, 1, 1, 1)
                y: parent.height / 3 - height / 2 + voffset
                x: -parent.width * .055
                font {
                    pixelSize: parent.height * .58
                    letterSpacing: -parent.width * .08
                    family: "League Spartan"
                }
                text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2).replace(/1/g," 1 ") :
                                     wallClock.time.toLocaleString(Qt.locale(), "HH").replace(/1/g," 1 ")
            }

            Text {
                property real voffset: parent.height * .075

                renderType: Text.NativeRendering
                color: Qt.rgba(1, 1, 1, 1)
                y: parent.height / 1.3 - height / 2 + voffset
                x: parent.width * .25
                font {
                    pixelSize: parent.height * .58
                    letterSpacing: -parent.width * .06
                    family: "League Spartan"
                }
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
                visible: !displayAmbient
                color: Qt.rgba(1, 1, 1, 1)
                font {
                    pixelSize: parent.height * .24
                    letterSpacing: -parent.width * .025
                    family: "League Spartan"
                }
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
                visible: use12H.value
                lineHeight: .9
                color: Qt.rgba(1, 1, 1, 1)
                horizontalAlignment: Text.AlignRight
                font {
                    pixelSize: parent.height * .1
                    letterSpacing: -parent.width * .01
                    family: "League Spartan"
                }
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
                lineHeight: .7
                color: Qt.rgba(1, 1, 1, 1)
                horizontalAlignment: Text.AlignRight
                font {
                    pixelSize: parent.height * .24
                    letterSpacing: -parent.width * .025
                    family: "League Spartan"
                }
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
                lineHeight: .7
                color: Qt.rgba(1, 1, 1, 1)
                horizontalAlignment: Text.AlignRight
                font {
                    pixelSize: parent.height * .1
                    letterSpacing: -parent.width * .01
                    family: "League Spartan"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "MMM").toLowerCase()
            }
        }

        layer.enabled: !displayAmbient
        layer.samplerName: "maskSource"
        layer.effect: ShaderEffect {
            property variant source: layer2mask
            property bool keepInner: displayAmbient
            fragmentShader: "
                    varying highp vec2 qt_TexCoord0;
                    uniform highp float qt_Opacity;
                    uniform lowp sampler2D source;
                    uniform lowp sampler2D maskSource;
                    uniform bool keepInner;
                    void main(void) {
                        if (keepInner) {
                            gl_FragColor = texture2D(source, qt_TexCoord0.st) * (texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
                        } else {
                            gl_FragColor = texture2D(source, qt_TexCoord0.st) * (1.0-texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
                        }
                    }
                "
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
            property real arcStrokeWidth: .022
            property real scalefactor: .45 - (arcStrokeWidth / 2)
            property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

            anchors.fill: parent

            ShapePath {
                fillColor: "transparent"
                strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                strokeWidth: parent.height * chargeArc.arcStrokeWidth
                capStyle: ShapePath.FlatCap
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
    }

    MceBatteryLevel {
        id: batteryChargePercentage
    }
}
