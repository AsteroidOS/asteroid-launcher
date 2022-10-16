/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
 *               2022 - Darrel Griët <dgriet@gmail.com>
 *               2022 - Ed Beroset <github.com/beroset>
 *               2017 - Mario Kicherer <dev@kicherer.org>
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

    property real radian: .01745

    anchors.centerIn: parent

    width: parent.width // * (nightstandMode.active ? .9 : 1)
    height: width

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
            property real arcStrokeWidth: .02
            property real scalefactor: .471 - (arcStrokeWidth / 2)
            property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
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

        Icon {
            id: batteryIcon

            name: "ios-battery-charging"
            anchors {
                centerIn: parent
                verticalCenterOffset: -parent.width * .16
            }
            visible: nightstandMode.active
            width: parent.width * .13
            height: parent.height * .13
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
                verticalCenterOffset: parent.width * .155
            }
            font {
                pixelSize: parent.width * .12
                family: "Noto Sans"
                styleName: "ExtraCondensed"
            }
            visible: nightstandMode.active
            color: chargeArc.colorArray[chargeArc.chargecolor]
            style: Text.Outline; styleColor: "#80000000"
            text: batteryChargePercentage.percent
        }
    }

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Canvas {
        id: hourStrokes

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")

            ctx.lineWidth = parent.width*.0093
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
            ctx.shadowColor = Qt.rgba(0, 0, 0, .7)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 2
            ctx.translate(parent.width / 2, parent.height / 2)
            for (var i = 0; i < 12; i++) {
                if ( i % 3 != 0) {
                    ctx.beginPath()
                    ctx.moveTo(0, parent.height * .3)
                    ctx.lineTo(0, parent.height * .42)
                    ctx.stroke()
                }
                ctx.rotate(Math.PI / 6)
            }
        }
    }

    Canvas {
        id: minuteStrokes

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = parent.width * .014
            ctx.lineCap = "round"
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
            ctx.shadowColor = Qt.rgba(0, 0, 0, .7)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 2
            ctx.translate(parent.width / 2, parent.height / 2)
            for (var i = 0; i < 60; i++) {
                ctx.beginPath()
                ctx.moveTo(0, parent.height * .46)
                ctx.lineTo(0, parent.height * .461)
                ctx.stroke()
                ctx.rotate(Math.PI / 30)
            }
        }
    }

    Canvas {
        id: numberStrokes

        property real voffset: -parent.height * .025
        property real hoffset: parent.height * 0

        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = Qt.rgba(1, 1, 1, .9)
            ctx.lineWidth = parent.height * .0124
            ctx.font = "0 " + parent.height * .18 + "px FatCow"
            ctx.textAlign = "center"
            ctx.textBaseline = 'middle';
            ctx.strokeStyle = Qt.rgba(0, 0, 0, .3)
            ctx.translate(parent.width / 2, parent.height / 2)
            for (var i = 0; i < 12; i = i + 3) {
                ctx.beginPath()
                ctx.strokeText(i != 0 ? i: 12,
                                        Math.cos((i - 3) / 12 * 2 * Math.PI) * parent.height * .346 - hoffset,
                                        Math.sin((i - 3) / 12 * 2 * Math.PI) * parent.height * .346 - voffset)
                ctx.fillText(i != 0 ? i: 12,
                                      Math.cos((i - 3) / 12 * 2 * Math.PI) * parent.height * .34 - hoffset,
                                      Math.sin((i - 3) / 12 * 2 * Math.PI) * parent.height * .34 - voffset)
                ctx.closePath()
            }
        }
    }

    Canvas {
        id: hourHand

        property int hour: 0

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .6)
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 4
            ctx.beginPath()
            ctx.lineWidth = parent.height*.004
            var gradient = ctx.createRadialGradient (parent.width / 2,
                                                     parent.height / 2,
                                                     0,
                                                     parent.width / 2,
                                                     parent.height / 2,
                                                     parent.width * .285)
            gradient.addColorStop(.1, Qt.rgba(.2, .2, .2, 1)) // darker shaft
            gradient.addColorStop(.4, Qt.rgba(.4, .4, .4, 1)) // light gold center
            gradient.addColorStop(.6, Qt.rgba(.3, .3, .3, 1)) // dark gold tip

            ctx.strokeStyle = gradient

            var gradient2 = ctx.createLinearGradient (parent.width / 2 + Math.cos(((hour - 6 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033,
                                                      parent.height / 2 + Math.sin(((hour - 6 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033,
                                                      parent.width / 2 + Math.cos(((hour+0 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033,
                                                      parent.height / 2 + Math.sin(((hour+0 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033)
            gradient2.addColorStop(.35, Qt.rgba(1, 1, 1, 1)) // darker gold
            gradient2.addColorStop(.5, Qt.rgba(.7, .7, .7, 1)) // light gold center
            gradient2.addColorStop(.65, Qt.rgba(1, 1, 1, 1)) // dark gold tip
            ctx.fillStyle = gradient2
            ctx.moveTo(parent.width/2+Math.cos(((hour - 3 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .285,
                       parent.height/2+Math.sin(((hour - 3 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .285)
            ctx.lineTo(parent.width/2+Math.cos(((hour - 3.12 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .275,
                       parent.height/2+Math.sin(((hour - 3.12 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .275)
            ctx.lineTo(parent.width/2+Math.cos(((hour - 6 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033,
                       parent.height/2+Math.sin(((hour - 6 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033)
            ctx.lineTo(parent.width/2+Math.cos(((hour + 0 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033,
                       parent.height/2+Math.sin(((hour + 0 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .033)

            ctx.lineTo(parent.width/2+Math.cos(((hour - 2.88 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .275,
                       parent.height/2+Math.sin(((hour - 2.88 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .275)
            ctx.lineTo(parent.width/2+Math.cos(((hour - 3 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .285,
                       parent.height/2+Math.sin(((hour - 3 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .285)
            ctx.fill()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .0)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.strokeStyle = Qt.rgba(0, 0, 0, .4)
            ctx.lineWidth = parent.height * .003
            ctx.moveTo(parent.width / 2,
                       parent.height / 2)
            ctx.lineTo(parent.width / 2 + Math.cos(((hour-3 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .284,
                       parent.height / 2 + Math.sin(((hour-3 + wallClock.time.getMinutes() / 60) / 12) * 2 * Math.PI) * width * .284)
            ctx.stroke()
            ctx.closePath()
        }
    }

    Canvas {
        id: minuteHand

        property int minute: 0

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .6)
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 4
            ctx.beginPath()
            ctx.lineWidth = parent.height*.004
            var gradient = ctx.createRadialGradient (parent.width / 2,
                                                     parent.height / 2,
                                                     0,
                                                     parent.width / 2,
                                                     parent.height / 2,
                                                     parent.width * .45)
            gradient.addColorStop(.1, Qt.rgba(.2, .2, .2, 1)) // darker shaft
            gradient.addColorStop(.4, Qt.rgba(.4, .4, .4, 1)) // light gold center
            gradient.addColorStop(.6, Qt.rgba(.3, .3, .3, 1)) // dark gold tip

            ctx.strokeStyle = gradient
            var gradient2 = ctx.createLinearGradient (parent.width / 2 + Math.cos(((minute - 30) / 60) * 2 * Math.PI) * width * .03,
                                                      parent.height / 2 + Math.sin(((minute - 30) / 60) * 2 * Math.PI) * width * .03,
                                                      parent.width / 2 + Math.cos(((minute + 0) / 60) * 2 * Math.PI) * width * .03,
                                                      parent.height / 2 + Math.sin(((minute + 0) / 60) * 2 * Math.PI) * width * .03)
            gradient2.addColorStop(.35, Qt.rgba(1, 1, 1, 1)) // darker gold
            gradient2.addColorStop(.5, Qt.rgba(.7, .7, .7, 1)) // light gold center
            gradient2.addColorStop(.65, Qt.rgba(1, 1, 1, 1)) // dark gold tip

            ctx.fillStyle = gradient2
            ctx.moveTo(parent.width / 2 + Math.cos(((minute - 15) / 60) * 2 * Math.PI) * width * .45,
                       parent.height / 2 + Math.sin(((minute - 15) / 60) * 2 * Math.PI) * width * .45)
            ctx.lineTo(parent.width / 2 + Math.cos(((minute - 15.3) / 60) * 2 * Math.PI) * width * .445,
                       parent.height / 2 + Math.sin(((minute - 15.3) / 60) * 2 * Math.PI) * width * .445)
            ctx.lineTo(parent.width / 2 + Math.cos(((minute - 30) / 60) * 2 * Math.PI) * width * .03,
                       parent.height / 2 + Math.sin(((minute - 30) / 60) * 2 * Math.PI) * width * .03)
            ctx.lineTo(parent.width / 2 + Math.cos(((minute + 0) / 60) * 2 * Math.PI) * width * .03,
                       parent.height / 2 + Math.sin(((minute + 0) / 60) * 2 * Math.PI) * width * .03)
            ctx.lineTo(parent.width / 2 + Math.cos(((minute - 14.7) / 60) * 2 * Math.PI) * width * .445,
                       parent.height / 2 + Math.sin(((minute - 14.7) / 60) * 2 * Math.PI) * width * .445)
            ctx.lineTo(parent.width / 2 + Math.cos(((minute - 15) / 60) * 2 * Math.PI) * width * .45,
                       parent.height / 2 + Math.sin(((minute - 15) / 60) * 2 * Math.PI) * width * .45)
            ctx.fill()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .0)
            ctx.stroke()
            ctx.lineWidth = parent.height * .003
            ctx.strokeStyle = Qt.rgba(0, 0, 0, .4)
            ctx.moveTo(parent.width / 2,
                       parent.height / 2)
            ctx.lineTo(parent.width / 2 + Math.cos(((minute - 15)/60) * 2 * Math.PI) * width * .448,
                       parent.height / 2 + Math.sin(((minute - 15)/60) * 2 * Math.PI) * width * .448)
            ctx.stroke()
            ctx.closePath()
        }
    }

    Canvas {
        id: secondHand

        property int second: 0

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !displayAmbient && !nightstandMode.active

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .7)
            ctx.shadowOffsetX = 5
            ctx.shadowOffsetY = 5
            ctx.shadowBlur = 3
            ctx.strokeStyle = "red"
            ctx.lineWidth = parent.height * .01
            ctx.beginPath()
            ctx.moveTo(parent.width / 2, parent.height / 2)
            ctx.lineTo(parent.width / 2 + Math.cos((second - 45) / 60 * 2 * Math.PI) * width * .15,
                       parent.height / 2 + Math.sin((second - 45) / 60 * 2 * Math.PI) * width * .15)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.lineWidth = parent.height * .006
            ctx.arc(parent.width / 2, parent.height / 2, parent.height * .012, 0, 2 * Math.PI, false)
            ctx.fill()
            ctx.moveTo(parent.width / 2, parent.height / 2)
            ctx.lineTo(parent.width / 2 + Math.cos((second - 15) / 60 * 2 * Math.PI) * width * .45,
                       parent.height / 2 + Math.sin((second - 15) / 60 * 2 * Math.PI) * width * .45)
            ctx.stroke()
            ctx.closePath()

        }
    }

    Canvas {
        id: nailDot

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.beginPath()
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
            ctx.lineWidth = parent.height * .0185
            ctx.arc(parent.width / 2, parent.height / 2, parent.height * .024, 0, 2 * Math.PI, false)
            ctx.stroke()
            ctx.closePath()
        }
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            var second = wallClock.time.getSeconds()
            if(secondHand.second !== second) {
                secondHand.second = second
                secondHand.requestPaint()
            }if(hourHand.hour !== hour) {
                hourHand.hour = hour
            }if(minuteHand.minute !== minute) {
                minuteHand.minute = minute
                minuteHand.requestPaint()
                hourHand.requestPaint()
            }
        }
    }

    Component.onCompleted: {
        var hour = wallClock.time.getHours()
        var minute = wallClock.time.getMinutes()
        var second = wallClock.time.getSeconds()
        secondHand.second = second
        secondHand.requestPaint()
        minuteHand.minute = minute
        minuteHand.requestPaint()
        hourHand.hour = hour
        hourHand.requestPaint()
        burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .11 : .06)})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .11 : .06)})
    }
}
