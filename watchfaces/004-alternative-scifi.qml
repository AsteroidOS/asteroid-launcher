/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
 *               2022 - Darrel Griët <dgriet@gmail.com>
 *               2022 - Ed Beroset <github.com/beroset>
 *               2016 - Florent Revest <revestflo@gmail.com>
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
    id: rootitem

    anchors.fill: parent

    width: parent.width * (nightstandMode.active ? .8 : 1)
    height: width

    function twoDigits(x) {
        if (x<10) return "0"+x;
        else      return x;
    }

    function prepareContext(ctx) {
        ctx.reset()
        ctx.fillStyle = "white"
        ctx.shadowColor = Qt.rgba(0, 0, 0, .80)
        ctx.shadowOffsetX = parent.height * .00625
        ctx.shadowOffsetY = parent.height * .00625
        ctx.shadowBlur = parent.height * .0156
    }

    Canvas {
        id: dowCanvas

        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height * .00625
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"

            var bold = "0 "
            var px = "px "

            var centerX = width * .373
            var centerY = height / 2 * .57
            var verticalOffset = height * .05

            var text;
            text = wallClock.time.toLocaleString(Qt.locale(), "dddd").toUpperCase()

            var fontSize = height * .051
            var fontFamily = "Xolonium"
            ctx.font = bold + fontSize + px + fontFamily;
            ctx.fillText(text, centerX, centerY + verticalOffset);
        }
    }

    Canvas {
        id: hourCanvas

        property int hour: 0

        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.textAlign = "right"
            ctx.textBaseline = "right"

            var bold = "60 "
            var px = "px "

            var centerX = width / 2 * 1.25
            var centerY = height / 2
            var verticalOffset = height * .12

            var text;
            text = twoDigits(hour)

            var fontSize = height * .36
            var fontFamily = "Xolonium"
            ctx.font = bold + fontSize + px + fontFamily;
            ctx.fillText(text, centerX, centerY + verticalOffset);
        }
    }

    Canvas {
        id: minuteCanvas

        property int minute: 0

        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = 3
            ctx.textAlign = "left"
            ctx.textBaseline = "left"

            var thin = "0 "
            var px = "px "

            var centerX = width / 2 * 1.268
            var centerY = height / 2
            var verticalOffset = height * .112

            var text;
            text = wallClock.time.toLocaleString(Qt.locale(), "mm")

            var fontSize = height * .17
            var fontFamily = "Xolonium"
            ctx.font = thin + fontSize + px + fontFamily;
            ctx.fillText(text, centerX, centerY + verticalOffset);
        }
    }

    Canvas {
        id: amPmCanvas

        property bool am: false

        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height*.00625 //2 px on 320x320
            ctx.textAlign = "left"
            ctx.textBaseline = "left"

            var bold = "64 "
            var px = "px "

            var centerX = width / 2 * 1.29
            var centerY = height / 2 * .83
            var verticalOffset = height * .05

            var text;
            text = wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toUpperCase()

            var fontSize = height * .057
            var fontFamily = "Xolonium"
            ctx.font = bold + fontSize + px + fontFamily;
            if(use12H.value) ctx.fillText(text, centerX, centerY + verticalOffset);
        }
    }

    Canvas {
        id: dateCanvas

        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height*.00625
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"

            var thin = "0 "
            var px = "px "

            var centerX = width * .626
            var centerY = height / 2 * 1.27
            var verticalOffset = height * .05

            var text;
            text = wallClock.time.toLocaleString(Qt.locale(), "dd MMMM").toUpperCase()

            var fontSize = height * .051
            var fontFamily = "Xolonium"
            ctx.font = thin + fontSize + px + fontFamily;
            ctx.fillText(text, centerX, centerY + verticalOffset);
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
            property real arcStrokeWidth: .026
            property real scalefactor: .49 - (arcStrokeWidth / 2)
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

        Text {
            id: batteryPercent

            anchors {
                centerIn: parent
                verticalCenterOffset: -parent.width * .3
            }
            font {
                pixelSize: parent.width / 11
                family: "Xolonium"
                styleName: "Bold"
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

    Component.onCompleted: {
        var hour = wallClock.time.getHours()
        var minute = wallClock.time.getMinutes()
        var am = hour < 12
        if(use12H.value) {
            hour = hour % 12
            if (hour === 0) hour = 12
        }
        hourCanvas.hour = hour
        hourCanvas.requestPaint()
        minuteCanvas.minute = minute
        minuteCanvas.requestPaint()
        dateCanvas.requestPaint()
        dowCanvas.requestPaint()
        amPmCanvas.am = am
        amPmCanvas.requestPaint()
        burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .12 : .2)})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .12 : .2)})
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
                dateCanvas.requestPaint()
                dowCanvas.requestPaint()
            } if(amPmCanvas.am != am) {
                amPmCanvas.am = am
                amPmCanvas.requestPaint()
            }
        }
    }

    Connections {
        target: localeManager
        function onChangesObserverChanged() {
            hourCanvas.requestPaint()
            minuteCanvas.requestPaint()
            dateCanvas.requestPaint()
            dowCanvas.requestPaint()
            amPmCanvas.requestPaint()
        }
    }
}
