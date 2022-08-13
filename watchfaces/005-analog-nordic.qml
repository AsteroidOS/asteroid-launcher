/*
* Copyright (C) 2018 - Timo Könnecke <el-t-mo@arcor.de>
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
    property var radian: 0.01745

    Canvas {
        z: 1
        id: hourHand
        property var hour: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.6)
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 4
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.004
            var gradient = ctx.createRadialGradient (parent.width/2,
                                                     parent.height/2,
                                                     0,
                                                     parent.width/2,
                                                     parent.height/2,
                                                     parent.width *0.285)
            gradient.addColorStop(0.1, Qt.rgba(0.2, 0.2, 0.2, 1)) // darker shaft
            gradient.addColorStop(0.4, Qt.rgba(0.4, 0.4, 0.4, 1)) // light gold center
            gradient.addColorStop(0.6, Qt.rgba(0.3, 0.3, 0.3, 1)) // dark gold tip

            ctx.strokeStyle = gradient

            var gradient2 = ctx.createLinearGradient (parent.width/2+Math.cos(((hour-6 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033,
                                                      parent.height/2+Math.sin(((hour-6 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033,
                                                      parent.width/2+Math.cos(((hour+0 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033,
                                                      parent.height/2+Math.sin(((hour+0 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033)
            gradient2.addColorStop(0.35, Qt.rgba(1, 1, 1, 1)) // darker gold
            gradient2.addColorStop(0.5, Qt.rgba(0.7, 0.7, 0.7, 1)) // light gold center
            gradient2.addColorStop(0.65, Qt.rgba(1, 1, 1, 1)) // dark gold tip
            ctx.fillStyle = gradient2
            ctx.moveTo(parent.width/2+Math.cos(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.285,
                       parent.height/2+Math.sin(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.285)
            ctx.lineTo(parent.width/2+Math.cos(((hour-3.12 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275,
                       parent.height/2+Math.sin(((hour-3.12 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275)
            ctx.lineTo(parent.width/2+Math.cos(((hour-6 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033,
                       parent.height/2+Math.sin(((hour-6 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033)
            ctx.lineTo(parent.width/2+Math.cos(((hour+0 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033,
                       parent.height/2+Math.sin(((hour+0 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.033)

            ctx.lineTo(parent.width/2+Math.cos(((hour-2.88 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275,
                       parent.height/2+Math.sin(((hour-2.88 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275)
            ctx.lineTo(parent.width/2+Math.cos(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.285,
                       parent.height/2+Math.sin(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.285)
            ctx.fill()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.0)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.4)
            ctx.lineWidth = parent.height*0.003
            ctx.moveTo(parent.width/2,
                       parent.height/2)
            ctx.lineTo(parent.width/2+Math.cos(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.284,
                       parent.height/2+Math.sin(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.284)
            ctx.stroke()
            ctx.closePath()


        }
    }

    Canvas {
        z: 2
        id: minuteHand
        property var minute: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.6)
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 4
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.004
            var gradient = ctx.createRadialGradient (parent.width/2,
                                                     parent.height/2,
                                                     0,
                                                     parent.width/2,
                                                     parent.height/2,
                                                     parent.width *0.45)
            gradient.addColorStop(0.1, Qt.rgba(0.2, 0.2, 0.2, 1)) // darker shaft
            gradient.addColorStop(0.4, Qt.rgba(0.4, 0.4, 0.4, 1)) // light gold center
            gradient.addColorStop(0.6, Qt.rgba(0.3, 0.3, 0.3, 1)) // dark gold tip

            ctx.strokeStyle = gradient
            var gradient2 = ctx.createLinearGradient (parent.width/2+Math.cos(((minute - 30)/60) * 2 * Math.PI)*width*0.03,
                                                      parent.height/2+Math.sin(((minute - 30)/60) * 2 * Math.PI)*width*0.03,
                                                      parent.width/2+Math.cos(((minute + 0)/60) * 2 * Math.PI)*width*0.03,
                                                      parent.height/2+Math.sin(((minute + 0)/60) * 2 * Math.PI)*width*0.03)
            gradient2.addColorStop(0.35, Qt.rgba(1, 1, 1, 1)) // darker gold
            gradient2.addColorStop(0.5, Qt.rgba(0.7, 0.7, 0.7, 1)) // light gold center
            gradient2.addColorStop(0.65, Qt.rgba(1, 1, 1, 1)) // dark gold tip

            ctx.fillStyle = gradient2
            ctx.moveTo(parent.width/2+Math.cos(((minute - 15)/60) * 2 * Math.PI)*width*0.45,
                       parent.height/2+Math.sin(((minute - 15)/60) * 2 * Math.PI)*width*0.45)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 15.3)/60) * 2 * Math.PI)*width*0.445,
                       parent.height/2+Math.sin(((minute - 15.3)/60) * 2 * Math.PI)*width*0.445)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 30)/60) * 2 * Math.PI)*width*0.03,
                       parent.height/2+Math.sin(((minute - 30)/60) * 2 * Math.PI)*width*0.03)
            ctx.lineTo(parent.width/2+Math.cos(((minute + 0)/60) * 2 * Math.PI)*width*0.03,
                       parent.height/2+Math.sin(((minute + 0)/60) * 2 * Math.PI)*width*0.03)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 14.7)/60) * 2 * Math.PI)*width*0.445,
                       parent.height/2+Math.sin(((minute - 14.7)/60) * 2 * Math.PI)*width*0.445)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 15)/60) * 2 * Math.PI)*width*0.45,
                       parent.height/2+Math.sin(((minute - 15)/60) * 2 * Math.PI)*width*0.45)
            ctx.fill()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.0)
            ctx.stroke()
            ctx.lineWidth = parent.height*0.003
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.4)
            ctx.moveTo(parent.width/2,
                       parent.height/2)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 15)/60) * 2 * Math.PI)*width*0.448,
                       parent.height/2+Math.sin(((minute - 15)/60) * 2 * Math.PI)*width*0.448)
            ctx.stroke()
            ctx.closePath()
        }
    }

    Canvas {
        z: 3
        id: secondHand
        property var second: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.7)
            ctx.shadowOffsetX = 5
            ctx.shadowOffsetY = 5
            ctx.shadowBlur = 3
            ctx.strokeStyle = "red"
            ctx.lineWidth = parent.height*0.01
            ctx.beginPath()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(parent.width/2+Math.cos((second - 45)/60 * 2 * Math.PI)*width*0.15,
                       parent.height/2+Math.sin((second - 45)/60 * 2 * Math.PI)*width*0.15)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.006
            ctx.arc(parent.width/2, parent.height/2, parent.height*0.012, 0, 2*Math.PI, false)
            ctx.fill()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(parent.width/2+Math.cos((second - 15)/60 * 2 * Math.PI)*width*0.45,
                       parent.height/2+Math.sin((second - 15)/60 * 2 * Math.PI)*width*0.45)
            ctx.stroke()
            ctx.closePath()

        }
    }

    Canvas {
        z: 11
        id: nailDot
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.beginPath()
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
            ctx.lineWidth = parent.height*0.0185
            ctx.arc(parent.width/2, parent.height/2, parent.height*0.024, 0, 2*Math.PI, false)
            ctx.stroke()
            ctx.closePath()
        }
    }

    Canvas {
        z: 0
        id: hourStrokes
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")

            ctx.lineWidth = parent.width*0.0093
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.7)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 2
            ctx.translate(parent.width/2, parent.height/2)
            for (var i=0; i < 12; i++) {
                if ( i%3 != 0) {
                    ctx.beginPath()
                    ctx.moveTo(0, height*0.3)
                    ctx.lineTo(0, height*0.42)
                    ctx.stroke()
                }
                ctx.rotate(Math.PI/6)
            }
        }
    }

    Canvas {
        z: 0
        id: minuteStrokes
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = parent.width*0.014
            ctx.lineCap = "round"
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.7)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 2
            ctx.translate(parent.width/2, parent.height/2)
            for (var i=0; i < 60; i++) {

                ctx.beginPath()
                ctx.moveTo(0, height*0.46)
                ctx.lineTo(0, height*0.461)
                ctx.stroke()

                ctx.rotate(Math.PI/30)
            }
        }
    }

    Canvas {
        z: 0
        id: numberStrokes
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative
        property var voffset: -parent.height*0.025
        property var hoffset: parent.height*0.0
        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = Qt.rgba(1, 1, 1, 0.9)
            ctx.lineWidth = parent.height*0.0124
            ctx.font = "0 " + height*0.18 + "px FatCow"
            ctx.textAlign = "center"
            ctx.textBaseline = 'middle';
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.3)
            ctx.translate(parent.width/2, parent.height/2)
            for (var i=0; i < 12; i=i+3) {
                ctx.beginPath()
                ctx.strokeText(i != 0 ? i: 12,
                                        Math.cos((i-3)/12 * 2 * Math.PI)*height*0.346-hoffset,
                                        Math.sin((i-3)/12 * 2 * Math.PI)*height*0.346-voffset)
                ctx.fillText(i != 0 ? i: 12,
                                      Math.cos((i-3)/12 * 2 * Math.PI)*height*0.34-hoffset,
                                      Math.sin((i-3)/12 * 2 * Math.PI)*height*0.34-voffset)

                ctx.closePath()
            }
        }
    }

    Item {
        id: nightstandMode

        readonly property bool active: mceCableState.connected //ready || (nightstandEnabled.value && holdoff)
        //readonly property bool ready: nightstandEnabled.value && mceCableState.connected
        property int batteryPercentChanged: batteryChargePercentage.percent

        anchors.fill: parent
        visible: nightstandMode.active
        layer.enabled: true
        layer.samples: 4

        Shape {
            id: chargeArc

            property real angle: batteryChargePercentage.percent * 360 / 100
            // radius of arc is scalefactor * height or width
            property real arcStrokeWidth: 0.02
            property real scalefactor: 0.471 - (arcStrokeWidth / 2)
            property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: [ "red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

            anchors.fill: parent
            smooth: true
            antialiasing: true

            ShapePath {
                fillColor: "transparent"
                strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                strokeWidth: parent.height * chargeArc.arcStrokeWidth
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.MiterJoin
                startX: width / 2
                startY: height * ( 0.5 - chargeArc.scalefactor)

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

        Icon {
            id: batteryIcon

            name: "ios-battery-charging"
            anchors {
                centerIn: parent
                verticalCenterOffset: -parent.width * 0.16
            }
            visible: nightstandMode.active
            width: parent.width * 0.15
            height: parent.height * 0.15
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
                verticalCenterOffset: parent.width * 0.155
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
            var second = wallClock.time.getSeconds()
            if(secondHand.second != second) {
                secondHand.second = second
                secondHand.requestPaint()
            }if(hourHand.hour != hour) {
                hourHand.hour = hour
            }if(minuteHand.minute != minute) {
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
    }
}
