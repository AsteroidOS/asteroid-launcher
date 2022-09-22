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

    anchors.centerIn: parent

    width: parent.width * (dockMode.active ? .84 : 1)
    height: width
    clip: true

    function twoDigits(x) {
        if (x < 10) return "0" + x;
        else      return x;
    }

    function prepareContext(ctx) {
        ctx.reset()
        ctx.fillStyle = "white"
        ctx.textAlign = "center"
        ctx.textBaseline = 'middle';
        ctx.shadowColor = Qt.rgba(0, 0, 0, .80)
        ctx.shadowOffsetX = parent.height * .00625
        ctx.shadowOffsetY = parent.height * .00625
        ctx.shadowBlur = parent.height * .0156
    }

    Canvas {
        id: hourCanvas
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative

        property int hour: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)

            ctx.font = "60 " + parent.height*.39 + "px Roboto"
            ctx.fillText(twoDigits(hour),
                         parent.width * .5,
                         parent.height * .34);
        }
    }

    Canvas {
        id: minuteCanvas

        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative

        property int minute: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)

            ctx.font = "26 " + parent.height * .38 + "px Roboto"
            ctx.fillText(twoDigits(minute),
                         parent.width * .5,
                         parent.height * .74);
        }
    }

    Canvas {
        id: dateCanvas

        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !dockMode.active

        property int date: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height * .00625 //2 px on 320x320
            ctx.textAlign = "left"
            ctx.textBaseline = "left"
            ctx.font = "60 " + parent.height * .09 + "px Raleway"
            ctx.fillText(wallClock.time.toLocaleString(Qt.locale(), "dd"),
                         parent.width / 10 * 1.75,
                         parent.height * .505);
        }
    }

    Canvas {
        id: monthCanvas

        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !dockMode.active

        property int month: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height * .00625 //2 px on 320x320
            ctx.textAlign = "center"
            ctx.font = "40 " +parent.height * .07 + "px Raleway"
            ctx.fillText(wallClock.time.toLocaleString(Qt.locale(), "MMMM").toUpperCase(),
                         parent.width / 2,
                         parent.height * .509);
        }
    }

    Canvas {
        id: amPmCanvas

        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: use12H.value && !dockMode.active

        property bool am: false

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height * .00625
            ctx.textAlign = "right"
            ctx.textBaseline = "right"
            ctx.font = "72 " +parent.height * .072 + "px Raleway"
            ctx.fillText(wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP").slice(0, 2),
                         parent.width / 10 * 8.3,
                         parent.height * .509);
        }
    }

    Canvas {
        id: secondCanvas

        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderStrategy: Canvas.Cooperative
        visible: !use12H.value && !displayAmbient && !dockMode.active

        property int second: 0

        onPaint: {
            var ctx = getContext("2d")
            prepareContext(ctx)
            ctx.shadowBlur = parent.height * .00625
            ctx.textAlign = "right"
            ctx.textBaseline = "right"
            ctx.font = "60 " +parent.height * .08 + "px Roboto"
            ctx.fillText(twoDigits(second),
                         parent.width / 10 * 8.1,
                         parent.height * .506);
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
            property real arcStrokeWidth: .024
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

        Icon {
            id: batteryIcon

            name: "ios-battery-charging"
            anchors {
                centerIn: parent
                horizontalCenterOffset: -parent.width * .27
            }
            visible: dockMode.active
            width: parent.width * .14
            height: parent.height * .14
        }

        Text {
            id: batteryPercent

            anchors {
                centerIn: parent
                horizontalCenterOffset: parent.width * .285
            }
            font {
                pixelSize: parent.width / 13
                family: "Roboto"
                styleName: "Bold"
            }
            visible: dockMode.active
            color: "#ffffffff"
            style: Text.Outline; styleColor: "#80000000"
            text: batteryChargePercentage.percent + "%"
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
        var second = wallClock.time.getSeconds()
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
        secondCanvas.second = second
        secondCanvas.requestPaint()
        dateCanvas.date = date
        dateCanvas.requestPaint()
        monthCanvas.month = date
        monthCanvas.requestPaint()
        amPmCanvas.am = am
        amPmCanvas.requestPaint()
        burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (dockMode.active ? .12 : .2)})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (dockMode.active ? .12 : .2)})
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            var second = wallClock.time.getSeconds()
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
            } if(secondCanvas.second !== second) {
                secondCanvas.second = second
                secondCanvas.requestPaint()
            } if(dateCanvas.date !== date) {
                dateCanvas.date = date
                dateCanvas.requestPaint()
            } if(monthCanvas.month !== date) {
                monthCanvas.month = date
                monthCanvas.requestPaint()
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
            secondCanvas.requestPaint()
            dateCanvas.requestPaint()
            monthCanvas.requestPaint()
            amPmCanvas.requestPaint()
        }
    }
}
