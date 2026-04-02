// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2017 Mario Kicherer <dev@kicherer.org>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    anchors.fill: parent

    Item {
        id: rootitem

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        // Static background circle — plain Rectangle replaces Canvas
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: Qt.rgba(1, 1, 1, .20)
            visible: !displayAmbient
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
                property real arcStrokeWidth: .04
                property real scalefactor: .482 - (arcStrokeWidth / 2)
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

            Text {
                id: batteryPercent

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.width * .17
                }
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline
                styleColor: "#80000000"
                font {
                    pixelSize: parent.width * .14
                    family: "Fyodor"
                }
                text: batteryChargePercentage.percent
            }
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        // Hour numerals — static, paints once only
        Canvas {
            id: numberStrokes

            property real voffset: -parent.height * .022
            property real hoffset: -parent.height * .007

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.lineWidth = parent.height * .0031
                ctx.fillStyle = displayAmbient ? Qt.rgba(1, 1, 1, .7) : Qt.rgba(.1, .1, .1, 1)
                ctx.strokeStyle = displayAmbient ? Qt.rgba(1, 1, 1, .3) : Qt.rgba(1, 1, 1, .4)
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                ctx.translate(parent.width / 2, parent.height / 2)
                for (var i = 1; i < 13; i++) {
                    ctx.beginPath()
                    ctx.font = height * .14 + "px Fyodor"
                    ctx.fillText(i,
                                 Math.cos((i - 3) / 12 * 2 * Math.PI) * height * .375 - hoffset,
                                 (Math.sin((i - 3) / 12 * 2 * Math.PI) * height * .375) - voffset)
                    ctx.strokeText(i,
                                   Math.cos((i - 3) / 12 * 2 * Math.PI) * height * .375 - hoffset,
                                   (Math.sin((i - 3) / 12 * 2 * Math.PI) * height * .375) - voffset)
                    ctx.closePath()
                }
            }
        }

        // Hour strokes — static, paints once only
        Canvas {
            id: hourStrokes

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = parent.width * .015
                ctx.strokeStyle = Qt.rgba(.1, .1, .1, .9)
                ctx.translate(parent.width / 2, parent.height / 2)
                for (var i = 0; i < 12; i++) {
                    ctx.beginPath()
                    ctx.moveTo(0, height * .44)
                    ctx.lineTo(0, height * .47)
                    ctx.stroke()
                    ctx.rotate(Math.PI / 6)
                }
            }
        }

        // Minute strokes — static, paints once only
        Canvas {
            id: minuteStrokes

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                ctx.lineWidth = parent.width * .007
                ctx.strokeStyle = Qt.rgba(.1, .1, .1, .9)
                ctx.translate(parent.width / 2, parent.height / 2)
                for (var i = 0; i < 60; i++) {
                    if ((i % 5) !== 0) {
                        ctx.beginPath()
                        ctx.moveTo(0, height * .45)
                        ctx.lineTo(0, height * .47)
                        ctx.stroke()
                    }
                    ctx.rotate(Math.PI / 30)
                }
            }
        }

        Text {
            id: monthDisplay

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: parent.width * .015
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: parent.height * .195
            }
            renderType: Text.NativeRendering
            color: displayAmbient ? Qt.rgba(1, 1, 1, .7) : "black"
            horizontalAlignment: Text.AlignHCenter
            font {
                pixelSize: parent.height * .08
                family: "Fyodor"
            }
            text: Qt.formatDate(wallClock.time, "MMM dd")
        }

        Canvas {
            id: hourHand

            property int hour: 0
            property int minute: 0

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.shadowColor = Qt.rgba(.1, .1, .1, .7)
                ctx.shadowOffsetX = 2
                ctx.shadowOffsetY = 2
                ctx.shadowBlur = 3
                ctx.beginPath()
                ctx.lineWidth = parent.height * .0031
                ctx.fillStyle = displayAmbient ? Qt.rgba(1, 1, 1, .9) : Qt.rgba(0, 0, 0, 1)
                ctx.strokeStyle = Qt.rgba(1, 1, 1, .4)
                ctx.moveTo(parent.width / 2 + Math.cos(((hour - 3 + minute / 60) / 12) * 2 * Math.PI) * width * .275,
                           parent.height / 2 + Math.sin(((hour - 3 + minute / 60) / 12) * 2 * Math.PI) * width * .275)
                ctx.lineTo(parent.width / 2 + Math.cos(((hour - 3.11 + minute / 60) / 12) * 2 * Math.PI) * width * .26,
                           parent.height / 2 + Math.sin(((hour - 3.11 + minute / 60) / 12) * 2 * Math.PI) * width * .26)
                ctx.lineTo(parent.width / 2 + Math.cos(((hour - 8.68 + minute / 60) / 12) * 2 * Math.PI) * width * .14,
                           parent.height / 2 + Math.sin(((hour - 8.68 + minute / 60) / 12) * 2 * Math.PI) * width * .14)
                ctx.lineTo(parent.width / 2 + Math.cos(((hour - 9.32 + minute / 60) / 12) * 2 * Math.PI) * width * .14,
                           parent.height / 2 + Math.sin(((hour - 9.32 + minute / 60) / 12) * 2 * Math.PI) * width * .14)
                ctx.lineTo(parent.width / 2 + Math.cos(((hour - 2.89 + minute / 60) / 12) * 2 * Math.PI) * width * .26,
                           parent.height / 2 + Math.sin(((hour - 2.89 + minute / 60) / 12) * 2 * Math.PI) * width * .26)
                ctx.lineTo(parent.width / 2 + Math.cos(((hour - 3 + minute / 60) / 12) * 2 * Math.PI) * width * .275,
                           parent.height / 2 + Math.sin(((hour - 3 + minute / 60) / 12) * 2 * Math.PI) * width * .275)
                ctx.fill()
                ctx.stroke()
                ctx.closePath()
            }
        }

        Canvas {
            id: minuteHand

            property int minute: 0

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.shadowColor = Qt.rgba(.1, .1, .1, .7)
                ctx.shadowOffsetX = 3
                ctx.shadowOffsetY = 3
                ctx.shadowBlur = 2
                ctx.beginPath()
                ctx.lineWidth = parent.height * .0031
                ctx.fillStyle = displayAmbient ? Qt.rgba(1, 1, 1, .9) : Qt.rgba(0, 0, 0, 1)
                ctx.strokeStyle = Qt.rgba(1, 1, 1, .4)
                ctx.moveTo(parent.width / 2 + Math.cos(((minute - 15) / 60) * 2 * Math.PI) * width * .44,
                           parent.height / 2 + Math.sin(((minute - 15) / 60) * 2 * Math.PI) * width * .44)
                ctx.lineTo(parent.width / 2 + Math.cos(((minute - 15.28) / 60) * 2 * Math.PI) * width * .43,
                           parent.height / 2 + Math.sin(((minute - 15.28) / 60) * 2 * Math.PI) * width * .43)
                ctx.lineTo(parent.width / 2 + Math.cos(((minute - 43.6) / 60) * 2 * Math.PI) * width * .14,
                           parent.height / 2 + Math.sin(((minute - 43.6) / 60) * 2 * Math.PI) * width * .14)
                ctx.lineTo(parent.width / 2 + Math.cos(((minute - 46.4) / 60) * 2 * Math.PI) * width * .14,
                           parent.height / 2 + Math.sin(((minute - 46.4) / 60) * 2 * Math.PI) * width * .14)
                ctx.lineTo(parent.width / 2 + Math.cos(((minute - 14.72) / 60) * 2 * Math.PI) * width * .43,
                           parent.height / 2 + Math.sin(((minute - 14.72) / 60) * 2 * Math.PI) * width * .43)
                ctx.lineTo(parent.width / 2 + Math.cos(((minute - 15) / 60) * 2 * Math.PI) * width * .44,
                           parent.height / 2 + Math.sin(((minute - 15) / 60) * 2 * Math.PI) * width * .44)
                ctx.fill()
                ctx.stroke()
                ctx.closePath()
            }
        }

        Canvas {
            id: secondHand

            property int second: 0

            anchors.fill: parent
            renderStrategy: Canvas.Cooperative
            visible: !displayAmbient

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.shadowColor = Qt.rgba(0, 0, 0, .5)
                ctx.shadowOffsetX = 4
                ctx.shadowOffsetY = 4
                ctx.shadowBlur = 3
                ctx.strokeStyle = "red"
                ctx.lineWidth = parent.height * .008
                ctx.beginPath()
                ctx.moveTo(parent.width / 2, parent.height / 2)
                ctx.lineTo(parent.width / 2 + Math.cos((second - 45) / 60 * 2 * Math.PI) * width * .07,
                           parent.height / 2 + Math.sin((second - 45) / 60 * 2 * Math.PI) * width * .07)
                ctx.stroke()
                ctx.closePath()
                ctx.beginPath()
                ctx.lineWidth = parent.height * .022
                ctx.moveTo(parent.width / 2 + Math.cos((second - 45) / 60 * 2 * Math.PI) * width * .07,
                           parent.height / 2 + Math.sin((second - 45) / 60 * 2 * Math.PI) * width * .07)
                ctx.lineTo(parent.width / 2 + Math.cos((second - 45) / 60 * 2 * Math.PI) * width * .16,
                           parent.height / 2 + Math.sin((second - 45) / 60 * 2 * Math.PI) * width * .16)
                ctx.stroke()
                ctx.closePath()
                ctx.beginPath()
                ctx.lineWidth = parent.height * .008
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

        Connections {
            target: compositor
            function onDisplayAmbientChanged() {
                minuteHand.requestPaint()
                hourHand.requestPaint()
                numberStrokes.requestPaint()
            }
        }

        Connections {
            target: wallClock
            function onTimeChanged() {
                var hour = wallClock.time.getHours()
                var minute = wallClock.time.getMinutes()
                var second = wallClock.time.getSeconds()
                if (secondHand.second !== second) {
                    secondHand.second = second
                    secondHand.requestPaint()
                }
                if (hourHand.hour !== hour) {
                    hourHand.hour = hour
                }
                if (minuteHand.minute !== minute) {
                    minuteHand.minute = minute
                    hourHand.minute = minute
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
            hourHand.minute = minute
            hourHand.requestPaint()
        }
    }
}
