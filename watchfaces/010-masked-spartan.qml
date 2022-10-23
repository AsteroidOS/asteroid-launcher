/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
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

    Rectangle {
        id: layer2mask

        width: parent.width
        height: width
        color: displayAmbient ? Qt.rgba(1, 1, 1, .8) : Qt.rgba(0, 0, 0, .8)
        visible: true
        opacity: .0
        layer.enabled: true
        layer.smooth: true
        radius: DeviceInfo.hasRoundScreen ? width : 0
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

        readonly property bool active: mceCableState.connected //ready || (nightstandEnabled.value && holdoff)
        //readonly property bool ready: nightstandEnabled.value && mceCableState.connected
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
            property real arcStrokeWidth: .03
            property real scalefactor: .5 - (arcStrokeWidth / 2)
            property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
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
                startX: width / 2
                startY: height * ( .5 - chargeArc.scalefactor)

                PathAngleArc {
                    centerX: parent.width / 2
                    centerY: parent.height / 2
                    radiusX: chargeArc.scalefactor * parent.width
                    radiusY: chargeArc.scalefactor * parent.height
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
