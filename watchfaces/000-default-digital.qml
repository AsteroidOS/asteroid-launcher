/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
 *               2022 - Darrel Griët <dgriet@gmail.com>
 *               2022 - Ed Beroset <github.com/beroset>
 *               2017 - Florent Revest <revestflo@gmail.com>
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

    function twoDigits(x) {
        if (x<10) return "0" + x;
        else      return x;
    }

    function prepareContext(ctx) {
        ctx.reset()
        ctx.fillStyle = "white"
        ctx.textAlign = "center"
        ctx.textBaseline = 'middle';
        ctx.shadowColor = "black"
        ctx.shadowOffsetX = 0
        ctx.shadowOffsetY = 0
        ctx.shadowBlur = parent.height * .0125
    }

    Item {
        id: watchfaceRoot

        anchors.centerIn: parent
        width: parent.width * (nightstandMode.active ? .86 : 1)
        height: width

        Canvas {
            id: hourCanvas

            property int hour: 0

            anchors.fill: parent
            antialiasing: true
            smooth: true
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                prepareContext(ctx)

                ctx.font = "57 " + height * .36 + "px Roboto"
                ctx.fillText(twoDigits(hour), width * .378, height * .537);
            }
        }

        Canvas {
            id: minuteCanvas

            property int minute: 0

            anchors.fill: parent
            antialiasing: true
            smooth: true
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                prepareContext(ctx)

                ctx.font = "30 " + height * .18 + "px Roboto"
                ctx.fillText(twoDigits(minute), width * .717, height * .473);
            }
        }

        Canvas {
            id: amPmCanvas

            property bool am: false

            anchors.fill: parent
            antialiasing: true
            smooth: true
            renderStrategy: Canvas.Cooperative
            visible: use12H.value

            onPaint: {
                var ctx = getContext("2d")
                prepareContext(ctx)

                ctx.font = "25 " + height / 15 + "px Raleway"
                ctx.fillText(wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP"), width * .894, height * .371);
            }
        }

        Canvas {
            id: dateCanvas

            property int date: 0

            anchors.fill: parent
            antialiasing: true
            smooth: true
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                prepareContext(ctx)
                ctx.font = "25 " + height / 13 + "px Raleway"
                ctx.fillText(wallClock.time.toLocaleString(Qt.locale(), "d MMM"), width * .719, height * .595);
            }
        }
    }

    Item {
        id: nightstandMode

        readonly property bool active: nightstand

        anchors.fill: parent

        layer {
            enabled: true
            samples: 4
            smooth: true
            textureSize: Qt.size(nightstandMode.width * 2, nightstandMode.height * 2)
        }
        visible: nightstandMode.active

        Repeater {
            id: segmentedArc

            property real inputValue: batteryChargePercentage.percent / 100
            property int segmentAmount: 50
            property int start: 0
            property int gap: 6
            property int endFromStart: 360
            property bool clockwise: true
            property real arcStrokeWidth: .055
            property real scalefactor: .45 - (arcStrokeWidth / 2)
            property real chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: [ "red", "yellow", Qt.rgba(.318, 1, .051, .9)]

            model: segmentAmount

            Shape {
                id: segment

                visible: index === 0 ? true : (index/segmentedArc.segmentAmount) < segmentedArc.inputValue

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
                    strokeWidth: parent.height * segmentedArc.arcStrokeWidth
                    capStyle: ShapePath.FlatCap
                    joinStyle: ShapePath.MiterJoin
                    startX: parent.width / 2
                    startY: parent.height * ( .5 - segmentedArc.scalefactor)

                    PathAngleArc {
                        centerX: parent.width / 2
                        centerY: parent.height / 2
                        radiusX: segmentedArc.scalefactor * parent.width
                        radiusY: segmentedArc.scalefactor * parent.height
                        startAngle: -90 + index * (sweepAngle + (segmentedArc.clockwise ? +segmentedArc.gap : -segmentedArc.gap)) + segmentedArc.start
                        sweepAngle: segmentedArc.clockwise ? (segmentedArc.endFromStart / segmentedArc.segmentAmount) - segmentedArc.gap :
                                                             -(segmentedArc.endFromStart / segmentedArc.segmentAmount) + segmentedArc.gap
                        moveToStart: true
                    }
                }
            }
        }
    }

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            var date = wallClock.time.getDate()
            var am = hour < 12
            if(use12H.value) {
                hour = hour % 12
                if (hour === 0) hour = 12;
            }
            if(hourCanvas.hour !== hour) {
                hourCanvas.hour = hour
                hourCanvas.requestPaint()
            } if(minuteCanvas.minute !== minute) {
                minuteCanvas.minute = minute
                minuteCanvas.requestPaint()
            } if(dateCanvas.date !== date) {
                dateCanvas.date = date
                dateCanvas.requestPaint()
            } if(amPmCanvas.am != am) {
                amPmCanvas.am = am
                amPmCanvas.requestPaint()
            }
        }
    }

    Component.onCompleted: {
        var hour = wallClock.time.getHours()
        var minute = wallClock.time.getMinutes()
        var date = wallClock.time.getDate()
        var am = hour < 12
        if(use12H.value) {
            hour = hour % 12
            if (hour === 0) hour = 12
        }
        hourCanvas.hour = hour
        hourCanvas.requestPaint()
        minuteCanvas.minute = minute
        minuteCanvas.requestPaint()
        dateCanvas.date = date
        dateCanvas.requestPaint()
        amPmCanvas.am = am
        amPmCanvas.requestPaint()

        burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .1 : .32)})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .1 : .7)})
    }
}
