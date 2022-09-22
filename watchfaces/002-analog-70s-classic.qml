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

    anchors.fill: parent

    property real radian: .01745

    Canvas {
        id: hourStrokes

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !dockMode.active
        onPaint: {
            var ctx = getContext("2d")

            ctx.lineWidth = parent.width * .025
            ctx.strokeStyle = Qt.rgba(1, 1, 1, .9)
            ctx.shadowColor = Qt.rgba(0, 0, 0, .8)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 2
            ctx.translate(parent.width / 2, parent.height / 2)
            for (var i = 0; i < 12; i++) {
                if ((i % 3) == 0) {
                    ctx.beginPath()
                    ctx.moveTo(0, height * .36)
                    ctx.lineTo(0, height * .46)
                    ctx.stroke()
                }
                ctx.rotate(Math.PI / 6)
            }
        }
    }

    Canvas {
        id: min5Strokes

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !dockMode.active
        onPaint: {
            var ctx = getContext("2d")

            ctx.lineWidth = parent.width * .016
            ctx.strokeStyle = Qt.rgba(1, 1, 1, .9)
            ctx.shadowColor = Qt.rgba(0, 0, 0, .8)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 2
            ctx.translate(parent.width / 2, parent.height / 2)
            for (var i = 0; i < 12; i++) {
                if ((i % 3) != 0) {

                    ctx.beginPath()
                    ctx.moveTo(0, height * .41)
                    ctx.lineTo(0, height * .46)
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
        visible: !dockMode.active
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = parent.width * .008
            ctx.strokeStyle = Qt.rgba(1, 1, 1, .7)
            ctx.shadowColor = Qt.rgba(0, 0, 0, .8)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 1
            ctx.translate(parent.width / 2, parent.height / 2)
            for (var i = 0; i < 60; i++) {
                // do not paint a minute stroke when there is an hour stroke
                if ((i % 5) != 0) {
                    ctx.beginPath()
                    ctx.moveTo(0, height * .41)
                    ctx.lineTo(0, height * .46)
                    ctx.stroke()
                }
                ctx.rotate(Math.PI/30)
            }
        }
    }

    Text {
        id: dayDisplay

        property real offset: height * .5

        visible: !dockMode.active
        font.pixelSize: parent.height / 24
        color: Qt.rgba(1, 1, 1, .7)
        font.family: "League Spartan"
        horizontalAlignment: Text.AlignHCenter
        style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, .4)
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -parent.height * .23
        }
        text: Qt.formatDate(wallClock.time, "dddd").toUpperCase()
    }

    Text {
        id: digitalDisplay

        property real offset: height * .6

        visible: !dockMode.active
        color: Qt.rgba(1, 1, 1, .7)
        horizontalAlignment: Text.AlignHCenter
        style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, .4)
        font {
            pixelSize: parent.height / 14
            family: "League Spartan"
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: dayDisplay.bottom
            topMargin: parent.height * .0156
        }
        text: if (use12H.value) {
                  wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) + wallClock.time.toLocaleString(Qt.locale(), ":mm") }
              else
                  wallClock.time.toLocaleString(Qt.locale(), "HH:mm")
    }

    Text {
        id: dateDisplay

        color: Qt.rgba(1, 1, 1, .7)
        horizontalAlignment: Text.AlignHCenter
        style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, .4)
        font {
            pixelSize: parent.height / 10
            family: "League Spartan"
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: parent.height * .164
        }
        text: Qt.formatDate(wallClock.time, "d").toUpperCase()
    }

    Text {
        id: monthDisplay

        color: Qt.rgba(1, 1, 1, .7)
        horizontalAlignment: Text.AlignHCenter
        style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, .4)
        font {
            pixelSize: parent.height / 20
            family: "League Spartan"
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: dateDisplay.bottom
        }
        text: Qt.formatDate(wallClock.time, "MMMM").toUpperCase()
    }

    Text {
        id: batteryPercent

        anchors {
            centerIn: parent
            verticalCenterOffset: -parent.width * .21
        }
        font {
            pixelSize: parent.width / 10
            family: "League Spartan"
        }
        visible: dockMode.active
        color: chargeArc.colorArray[chargeArc.chargecolor]
        style: Text.Outline; styleColor: Qt.rgba(0, 0, 0, .4)
        text: batteryChargePercentage.percent
    }

    Canvas {
        id: hourHand

        property int hour: 0
        property real rotH: (hour - 3 + wallClock.time.getMinutes() / 60) / 12

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.lineCap="round"
            ctx.beginPath()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .8)
            ctx.shadowOffsetX = 2
            ctx.shadowOffsetY = 2
            ctx.shadowBlur = 3
            ctx.lineWidth = parent.width * .034
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
            ctx.moveTo(parent.width / 2,
                       parent.height / 2)
            ctx.lineTo(parent.width / 2 + Math.cos(rotH * 2 * Math.PI) * width * .227,
                       parent.height / 2 + Math.sin(rotH * 2 * Math.PI) * width * .227)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 0
            ctx.lineWidth = parent.width*.015
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
            ctx.moveTo(parent.width / 2 + Math.cos(rotH * 2 * Math.PI) * width * .10,
                       parent.height / 2 + Math.sin(rotH * 2 * Math.PI) * width * .10)
            ctx.lineTo(parent.width / 2 + Math.cos(rotH * 2 * Math.PI) * width * .224,
                       parent.height / 2 + Math.sin(rotH * 2 * Math.PI) * width * .224)
            ctx.stroke()
            ctx.closePath()
        }
    }

    Canvas {
        id: minuteHand

        property int minute: 0
        property real rotM: (minute - 15) / 60

        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.lineCap="round"
            ctx.beginPath()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .8)
            ctx.shadowOffsetX = 1
            ctx.shadowOffsetY = 1
            ctx.shadowBlur = 3
            ctx.lineWidth = parent.width * .034
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1)
            //circle in center
            ctx.arc(parent.width / 2, parent.height / 2, parent.height * .014, 0, 2 * Math.PI, false)
            ctx.moveTo(parent.width / 2,
                       parent.height / 2)
            //outer line
            ctx.lineTo(parent.width / 2 + Math.cos(rotM * 2 * Math.PI) * width * .327,
                    parent.height / 2 + Math.sin(rotM * 2 * Math.PI) * width * .327)
            ctx.stroke()
            ctx.closePath()
            ctx.lineWidth = parent.width * .015
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 1)
            ctx.beginPath()
            ctx.shadowColor = Qt.rgba(0, 0, 0, 0)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 0
            //inner line
            ctx.moveTo(parent.width / 2 + Math.cos(rotM * 2 * Math.PI) * width * .17,
                       parent.height / 2 + Math.sin(rotM * 2 * Math.PI) * width * .17)
            ctx.lineTo(parent.width / 2 + Math.cos(rotM * 2 * Math.PI) * width * .324,
                    parent.height / 2 + Math.sin(rotM * 2 * Math.PI) * width * .324)
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
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0, 0, 0, .7)
            ctx.shadowOffsetX = 1
            ctx.shadowOffsetY = 1
            ctx.shadowBlur = 2
            ctx.strokeStyle = "red"
            ctx.lineWidth = parent.height*.008
            ctx.beginPath()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(parent.width / 2 + Math.cos((second - 45) / 60 * 2 * Math.PI) * width * .1,
                    parent.height / 2 + Math.sin((second - 45) / 60 * 2 * Math.PI) * width * .1)
            ctx.stroke()
            ctx.closePath()
            ctx.beginPath()
            ctx.fillStyle = "red"
            ctx.arc(parent.width / 2, parent.height / 2, parent.height * .012, 0, 2 * Math.PI, false)
            ctx.fill()
            ctx.moveTo(parent.width / 2, parent.height / 2)
            ctx.lineTo(parent.width / 2 + Math.cos((second - 15) / 60 * 2 * Math.PI) * width * .32,
                    parent.height / 2 + Math.sin((second - 15) / 60 * 2 * Math.PI) * width * .32)
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
            ctx.shadowColor = Qt.rgba(0, 0, 0, .8)
            ctx.shadowOffsetX = 1
            ctx.shadowOffsetY = 1
            ctx.shadowBlur = 1
            ctx.fillStyle = Qt.rgba(1, 1, 1, 1)
            ctx.arc(parent.width / 2, parent.height / 2, parent.height * .006, 0, 2 * Math.PI, false)
            ctx.fill()
            ctx.closePath()
        }
    }

    Item {
        id: dockMode

        readonly property bool active: mceCableState.connected //ready || (nightstandEnabled.value && holdoff)
        //readonly property bool ready: nightstandEnabled.value && mceCableState.connected
        property int batteryPercentChanged: batteryChargePercentage.percent

        anchors.fill: parent
        visible: dockMode.active
        layer {
            enabled: true
            samples: 4
            smooth: true
            textureSize: Qt.size(dockMode.width * 2, dockMode.height * 2)
        }

        Shape {
            id: chargeArc

            property real angle: batteryChargePercentage.percent * 360 / 100
            // radius of arc is scalefactor * height or width
            property real arcStrokeWidth: .04
            property real scalefactor: .46 - (arcStrokeWidth / 2)
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
     }
}
