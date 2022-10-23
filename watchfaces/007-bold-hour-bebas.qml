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

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    id: rootitem

    anchors.fill: parent

    Item {
        id: scaleContent

        anchors.centerIn: parent
        width: parent.width * (nightstandMode.active ? .8 : 1)
        height: width

        Canvas {
            id: minuteArc

            property real centerX: parent.width / 2
            property real centerY: parent.height / 2

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative
            visible: !displayAmbient && !nightstandMode.active
            onPaint: {
                var ctx = getContext("2d")
                var rot = (wallClock.time.getMinutes() -15 ) * 6
                ctx.reset()
                ctx.lineWidth = parent.width*.0031
                var gradient = ctx.createConicalGradient (centerX, centerY, 90 * .01745)
                    gradient.addColorStop(1 - (wallClock.time.getMinutes() / 60), Qt.rgba(1, 1, 1, .4))
                    gradient.addColorStop(1 - (wallClock.time.getMinutes() / 60 / 6), Qt.rgba(1, 1, 1, 0))
                var gradient2 = ctx.createConicalGradient (centerX, centerY, 90 * .01745)
                    gradient2.addColorStop(1 - (wallClock.time.getMinutes() / 60), Qt.rgba(1, 1, 1, .5))
                    gradient2.addColorStop(1 - (wallClock.time.getMinutes() / 60 / 6), Qt.rgba(1, 1, 1, .01))
                ctx.fillStyle = gradient
                ctx.strokeStyle = gradient2
                ctx.beginPath()
                ctx.arc(centerX, centerY, width / 2.75, -90 * .017453, rot * .017453, false);
                ctx.lineTo(centerX, centerY);
                ctx.fill()
                ctx.stroke()
            }
        }

        Text {
            id: hourDisplay

            renderType: Text.NativeRendering
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            font {
                pixelSize: parent.height * .87
                family: "BebasKai"
                styleName:"Bold"
            }
            color: Qt.rgba(1, 1, 1, .9)
            opacity: .9
            style: Text.Outline;
            styleColor: Qt.rgba(0, 0, 0, .2)
            horizontalAlignment: Text.AlignHCenter
            text: if (use12H.value) {
                      wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) }
                  else
                      wallClock.time.toLocaleString(Qt.locale(), "HH")
        }

        Canvas {
            id: minuteCircle

            property int minute: 0
            property real rotM: (wallClock.time.getMinutes() - 15) / 60
            property real centerX: parent.width / 2
            property real centerY: parent.height / 2
            property real minuteX: centerX+Math.cos(rotM * 2 * Math.PI) * width / 2.75
            property real minuteY: centerY+Math.sin(rotM * 2 * Math.PI) * height / 2.75

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative
            onPaint: {
                var ctx = getContext("2d")
                var rot1 = (0 -15 ) * 6 * .01745
                var rot2 = (60 -15 ) * 6 * .01745
                ctx.reset()
                ctx.lineWidth = 3
                ctx.fillStyle = Qt.rgba(.184, .184, .184, .95)
                ctx.beginPath()
                ctx.moveTo(minuteX, minuteY)
                ctx.arc(minuteX, minuteY, width / 8.6, rot1, rot2, false);
                ctx.lineTo(minuteX, minuteY);
                ctx.fill();
            }
        }

        Text {
            id: minuteDisplay

            property real rotM: (wallClock.time.getMinutes() - 15) / 60
            property real centerX: parent.width / 2 - width / 2
            property real centerY: parent.height / 2 - height / 2

            font {
                pixelSize: parent.height / 5.24
                family: "BebasKai"
                styleName:'Condensed'
            }
            color: "white"
            opacity: 1.00
            //smooth: true
            //antialiasing: true
            x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .364
            y: centerY+Math.sin(rotM * 2 * Math.PI) * parent.width * .364
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")
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
            property real arcStrokeWidth: .04
            property real scalefactor: .5 - (arcStrokeWidth / 2)
            property real chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: [ "red", "yellow", Qt.rgba(.318, 1, .051, .9)]

            anchors.fill: parent
            //smooth: true
            //antialiasing: true

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

    MceBatteryState {
        id: batteryChargeState
    }

    MceCableState {
        id: mceCableState
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()

            if(minuteCircle.minute !== minute) {
                minuteCircle.minute = minute
                minuteCircle.requestPaint()
                minuteArc.requestPaint()
            }
        }
    }

    Component.onCompleted: {
        var hour = wallClock.time.getHours()
        var minute = wallClock.time.getMinutes()

        minuteCircle.minute = minute
        minuteCircle.requestPaint()
        minuteArc.requestPaint()

        burnInProtectionManager.widthOffset = Qt.binding(function() { return width * .3})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height * .3})
    }
}
