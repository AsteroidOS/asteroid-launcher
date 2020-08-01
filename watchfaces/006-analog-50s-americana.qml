/*
* Copyright (C) 2018 - Timo Könnecke <el-t-mo@arcor.de>
 *              2017 - Mario Kicherer <dev@kicherer.org>
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

import QtQuick 2.1

Item {
    property var radian: 0.01745

    Canvas {
        z: 0
        id: backCircle
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Threaded
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = Qt.rgba(1, 1, 1, 0.20)
            ctx.beginPath()
            ctx.arc(parent.height/2, parent.width/2, parent.width*0.5, 0*radian, 360*radian, false);
            ctx.fill()
            ctx.closePath()
        }
    }

    Canvas {
        z: 1
        id: hourHand
        property var hour: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0.1, 0.1, 0.1, 0.7)
            ctx.shadowOffsetX = 2
            ctx.shadowOffsetY = 2
            ctx.shadowBlur = 3
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.0031
            ctx.fillStyle = displayAmbient ? Qt.rgba(1, 1, 1, 0.7) : Qt.rgba(0, 0, 0, 1)
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.4)
            ctx.moveTo(parent.width/2+Math.cos(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275,
                       parent.height/2+Math.sin(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275)
            ctx.lineTo(parent.width/2+Math.cos(((hour-3.11 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.26,
                       parent.height/2+Math.sin(((hour-3.11 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.26)
            ctx.lineTo(parent.width/2+Math.cos(((hour-8.68 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.14,
                       parent.height/2+Math.sin(((hour-8.68 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.14)
            ctx.lineTo(parent.width/2+Math.cos(((hour-9.32 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.14,
                       parent.height/2+Math.sin(((hour-9.32 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.14)
            ctx.lineTo(parent.width/2+Math.cos(((hour-2.89 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.26,
                       parent.height/2+Math.sin(((hour-2.89 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.26)
            ctx.lineTo(parent.width/2+Math.cos(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275,
                       parent.height/2+Math.sin(((hour-3 + wallClock.time.getMinutes()/60) / 12) * 2 * Math.PI)*width*0.275)
            ctx.fill()
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
        renderStrategy: Canvas.Threaded
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0.1, 0.1, 0.1, 0.7)
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 2
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.0031
            ctx.fillStyle = displayAmbient ? Qt.rgba(1, 1, 1, 0.7) : Qt.rgba(0, 0, 0, 1)
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.4)
            ctx.moveTo(parent.width/2+Math.cos(((minute - 15)/60) * 2 * Math.PI)*width*0.44,
                       parent.height/2+Math.sin(((minute - 15)/60) * 2 * Math.PI)*width*0.44)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 15.28)/60) * 2 * Math.PI)*width*0.43,
                       parent.height/2+Math.sin(((minute - 15.28)/60) * 2 * Math.PI)*width*0.43)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 43.6)/60) * 2 * Math.PI)*width*0.14,
                       parent.height/2+Math.sin(((minute - 43.6)/60) * 2 * Math.PI)*width*0.14)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 46.4)/60) * 2 * Math.PI)*width*0.14,
                       parent.height/2+Math.sin(((minute - 46.4)/60) * 2 * Math.PI)*width*0.14)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 14.72)/60) * 2 * Math.PI)*width*0.43,
                       parent.height/2+Math.sin(((minute - 14.72)/60) * 2 * Math.PI)*width*0.43)
            ctx.lineTo(parent.width/2+Math.cos(((minute - 15)/60) * 2 * Math.PI)*width*0.44,
                       parent.height/2+Math.sin(((minute - 15)/60) * 2 * Math.PI)*width*0.44)
            ctx.fill()
            ctx.stroke()
            ctx.closePath()
        }
    }

    Canvas {
        z: 4
        id: secondHand
        property var second: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0.5)
            ctx.shadowOffsetX = 4
            ctx.shadowOffsetY = 4
            ctx.shadowBlur = 3
            ctx.strokeStyle = "red"
            ctx.lineWidth = parent.height*0.008
            ctx.beginPath()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(parent.width/2+Math.cos((second - 45)/60 * 2 * Math.PI)*width*0.07,
                    parent.height/2+Math.sin((second - 45)/60 * 2 * Math.PI)*width*0.07)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.022
            ctx.moveTo(parent.width/2+Math.cos((second - 45)/60 * 2 * Math.PI)*width*0.07,
                       parent.height/2+Math.sin((second - 45)/60 * 2 * Math.PI)*width*0.07)
            ctx.lineTo(parent.width/2+Math.cos((second - 45)/60 * 2 * Math.PI)*width*0.16,
                    parent.height/2+Math.sin((second - 45)/60 * 2 * Math.PI)*width*0.16)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.lineWidth = parent.height*0.008
            ctx.fillStyle = "red"
            ctx.arc(parent.width/2, parent.height/2, parent.height*0.012, 0, 2*Math.PI, false)
            ctx.fill()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(parent.width/2+Math.cos((second - 15)/60 * 2 * Math.PI)*width*0.32,
                    parent.height/2+Math.sin((second - 15)/60 * 2 * Math.PI)*width*0.32)
            ctx.stroke()
            ctx.closePath()

        }
    }

    Canvas {
        z: 0
        id: numberStrokes
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Threaded
        property var voffset: -parent.height*0.022
        property var hoffset: -parent.height*0.007
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.lineWidth = parent.height*0.0031
            ctx.fillStyle = displayAmbient ? Qt.rgba(1, 1, 1, 0.8) : Qt.rgba(0.1, 0.1, 0.1, 1)
            ctx.strokeStyle = displayAmbient ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(1, 1, 1, 0.3)
            ctx.textAlign = "center"
            ctx.textBaseline = 'middle';
            ctx.translate(parent.width/2, parent.height/2)
            for (var i=1; i < 13; i++) {
                ctx.beginPath()
                ctx.font = height*0.14 + "px Fyodor"
                ctx.fillText(i,
                             Math.cos((i-3)/12 * 2 * Math.PI)*height*0.375-hoffset,
                             (Math.sin((i-3)/12 * 2 * Math.PI)*height*0.375)-voffset)
                ctx.strokeText(i,
                             Math.cos((i-3)/12 * 2 * Math.PI)*height*0.375-hoffset,
                             (Math.sin((i-3)/12 * 2 * Math.PI)*height*0.375)-voffset)
                ctx.closePath()
            }
        }
    }

    Canvas {
        z: 3
        id: hourStrokes
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        onPaint: {
            var ctx = getContext("2d")

            ctx.lineWidth = parent.width*0.015
            ctx.strokeStyle = Qt.rgba(0.1, 0.1, 0.1, 0.9)
            ctx.translate(parent.width/2, parent.height/2)
            for (var i=0; i < 12; i++) {
                ctx.beginPath()
                ctx.moveTo(0, height*0.44)
                ctx.lineTo(0, height*0.47)
                ctx.stroke()
                ctx.rotate(Math.PI/6)
            }
        }
    }

    Canvas {
        z: 3
        id: minuteStrokes
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = parent.width*0.007
            ctx.strokeStyle = Qt.rgba(0.1, 0.1, 0.1, 0.9)
            ctx.translate(parent.width/2, parent.height/2)
            for (var i=0; i < 60; i++) {
                // do not paint a minute stroke when there is an hour stroke
                if ((i%5) != 0) {
                    ctx.beginPath()
                    ctx.moveTo(0, height*0.45)
                    ctx.lineTo(0, height*0.47)
                    ctx.stroke()
                }
                ctx.rotate(Math.PI/30)
            }
        }
    }

    Text {
        id: monthDisplay
        z: 5
        renderType: Text.NativeRendering
        font.pixelSize: parent.height*0.08
        color: displayAmbient ? Qt.rgba(1, 1, 1, 0.7) : "black"
        font.family: "Fyodor"
        horizontalAlignment: Text.AlignHCenter
        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: parent.width*0.015
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: parent.height*0.195
        }
        text: Qt.formatDate(wallClock.time, "MMM dd")
    }


    Connections {
        target: compositor
        onDisplayAmbientChanged: {
            minuteHand.requestPaint()
            hourHand.requestPaint()
        }
    }

    Connections {
        target: wallClock
        onTimeChanged: {
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
