/*
 * Copyright (C) 2022 - Timo Könnecke <el-t-mo@arcor.de>
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
    function twoDigits(x) {
        if (x<10) return "0"+x;
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
        ctx.shadowBlur = parent.height*0.0125
    }

    Canvas {
        id: hourCanvas
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative

        property var hour: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)

            ctx.font = "57 " + height*0.36 + "px Roboto"
            ctx.fillText(twoDigits(hour), width*0.378, height*0.537);
        }
    }

    Canvas {
        id: minuteCanvas
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative

        property var minute: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)

            ctx.font = "30 " + height * 0.18 + "px Roboto"
            ctx.fillText(twoDigits(minute), width*0.717, height*0.473);
        }
    }

    Canvas {
        id: amPmCanvas
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: use12H.value

        property var am: false

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            var ctx = getContext("2d")

            ctx.font = "25 " + height/15 + "px Raleway"
            ctx.fillText(wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP"), width*0.894, height*0.371);
        }
    }

    Canvas {
        id: dateCanvas
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative

        property var date: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.font = "25 " + height/13 + "px Raleway"
            ctx.fillText(wallClock.time.toLocaleString(Qt.locale(), "d MMM"), width*0.719, height*0.595);
        }
    }

    Item {
        id: nightstandMode

        readonly property bool active: mceCableState.connected //ready || (nightstandEnabled.value && holdoff)
        //readonly property bool ready: nightstandEnabled.value && mceCableState.connected
        property int batteryPercentChanged: batteryChargePercentage.percent

        onBatteryPercentChangedChanged: {
            batteryPercent.requestPaint()
        }

        anchors.fill: parent
        visible: nightstandMode.active
        layer.enabled: true
        layer.samples: 4

        Shape {
            id: chargeArc

            property real angle: batteryChargePercentage.percent * 360 / 100
            // radius of arc is scalefactor * height or width
            property real scalefactor: 0.41
            property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: [ "red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

            anchors.fill: parent
            smooth: true
            antialiasing: true

            ShapePath {
                fillColor: "transparent"
                strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                strokeWidth: parent.height * 0.04
                capStyle: ShapePath.FlatCap
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
                verticalCenterOffset: -parent.height * 0.25
            }
            width: parent.width * 0.13
            height: parent.height * 0.13
        }

        ColorOverlay {
            anchors.fill: batteryIcon
            source: batteryIcon
            color: chargeArc.colorArray[chargeArc.chargecolor]
        }

        Canvas {
            id: batteryPercent
            anchors.fill: parent
            antialiasing: true
            smooth: true
            renderStrategy: Canvas.Cooperative

            onPaint: {
                var ctx = getContext("2d")
                prepareContext(ctx)
                ctx.fillStyle = chargeArc.colorArray[chargeArc.chargecolor]
                ctx.font = "45 " + height * .08 + "px Roboto"
                ctx.fillText(batteryChargePercentage.percent + "%", width*0.5, height*0.75);
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
            var date = wallClock.time.getDate()
            var am = hour < 12
            if(use12H.value) {
                hour = hour % 12
                if (hour == 0) hour = 12;
            }
            if(hourCanvas.hour != hour) {
                hourCanvas.hour = hour
                hourCanvas.requestPaint()
            } if(minuteCanvas.minute != minute) {
                minuteCanvas.minute = minute
                minuteCanvas.requestPaint()
            } if(dateCanvas.date != date) {
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
            if (hour == 0) hour = 12
        }
        hourCanvas.hour = hour
        hourCanvas.requestPaint()
        minuteCanvas.minute = minute
        minuteCanvas.requestPaint()
        dateCanvas.date = date
        dateCanvas.requestPaint()
        amPmCanvas.am = am
        amPmCanvas.requestPaint()

        burnInProtectionManager.widthOffset = Qt.binding(function() { return width*0.32})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height*0.7})
    }
}
