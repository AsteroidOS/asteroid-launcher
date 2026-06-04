// SPDX-FileCopyrightText: 2022 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Florent Revest <revestflo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import org.asteroid.controls
import org.asteroid.utils
import Nemo.Mce

Item {
    anchors.fill: parent

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

    Item {
        id: root

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Item {
            id: watchfaceRoot

            anchors.centerIn: parent

            width: parent.width * (nightstandMode.active ? .8 : 1)
            height: width

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
                visible: !nightstandMode.active

                property int month: 0
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
                visible: !nightstandMode.active

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
                visible: use12H.value && !nightstandMode.active

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
                visible: !use12H.value && !displayAmbient && !nightstandMode.active

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
        }

        Item {
            id: nightstandMode

            readonly property bool active: nightstand
            property int batteryPercentChanged: batteryChargePercentage.percent

            anchors.fill: parent
            visible: nightstandMode.active

            Repeater {
                id: segmentedArc

                property real inputValue: batteryChargePercentage.percent / 100
                property int segmentAmount: 48
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .05
                property real scalefactor: .46 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: [ "red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                model: segmentAmount

                Shape {
                    id: segment

                    visible: index === 0 ? true : (index/segmentedArc.segmentAmount) < segmentedArc.inputValue

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
                        strokeWidth: root.height * segmentedArc.arcStrokeWidth
                        capStyle: ShapePath.FlatCap
                        joinStyle: ShapePath.MiterJoin
                        startX: root.width / 2
                        startY: root.height * ( .5 - segmentedArc.scalefactor)

                        PathAngleArc {
                            centerX: root.width / 2
                            centerY: root.height / 2
                            radiusX: segmentedArc.scalefactor * root.width
                            radiusY: segmentedArc.scalefactor * root.height
                            startAngle: -90 + index * (sweepAngle + (segmentedArc.clockwise ? +segmentedArc.gap : -segmentedArc.gap)) + segmentedArc.start
                            sweepAngle: segmentedArc.clockwise ? (segmentedArc.endFromStart / segmentedArc.segmentAmount) - segmentedArc.gap : -(segmentedArc.endFromStart / segmentedArc.segmentAmount) + segmentedArc.gap
                            moveToStart: true
                        }
                    }
                }
            }
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Component.onCompleted: {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            var second = wallClock.time.getSeconds()
            var month = wallClock.time.getMonth()
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
            dateCanvas.month = month
            dateCanvas.requestPaint()
            monthCanvas.month = month
            monthCanvas.requestPaint()
            amPmCanvas.am = am
            amPmCanvas.requestPaint()
            burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .08 : .2)})
            burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .08 : .2)})
        }

        Connections {
            target: wallClock
            function onTimeChanged() {
                var hour = wallClock.time.getHours()
                var minute = wallClock.time.getMinutes()
                var second = wallClock.time.getSeconds()
                var month = wallClock.time.getMonth()
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
                } if(dateCanvas.date !== date || dateCanvas.month !== month) {
                    dateCanvas.month = month
                    dateCanvas.date = date
                    dateCanvas.requestPaint()
                } if(monthCanvas.month !== month) {
                    monthCanvas.month = month
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
}
