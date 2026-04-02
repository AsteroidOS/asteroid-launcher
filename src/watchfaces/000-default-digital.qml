// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2017 Florent Revest <revestflo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    anchors.fill: parent

    function twoDigits(x) {
        return x < 10 ? "0" + x : "" + x
    }

    function prepareContext(ctx) {
        ctx.reset()
        ctx.fillStyle = "white"
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.shadowColor = "black"
        ctx.shadowOffsetX = 0
        ctx.shadowOffsetY = 0
        ctx.shadowBlur = root.height * .0125
    }

    Item {
        id: root

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Item {
            id: watchfaceRoot

            anchors.centerIn: parent
            width: parent.width * (nightstandMode.active ? .86 : 1)
            height: width

            Canvas {
                id: hourCanvas

                property int hour: 0

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                onPaint: {
                    var ctx = getContext("2d")
                    prepareContext(ctx)
                    ctx.font = "57 " + height * .36 + "px Roboto"
                    ctx.fillText(twoDigits(hour), width * .378, height * .537)
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
                    ctx.font = "30 " + height * .18 + "px Roboto"
                    ctx.fillText(twoDigits(minute), width * .717, height * .473)
                }
            }

            Canvas {
                id: amPmCanvas

                property bool am: false
                property string ap: ""

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                visible: use12H.value

                onPaint: {
                    var ctx = getContext("2d")
                    prepareContext(ctx)
                    ctx.font = "25 " + height / 15 + "px Raleway"
                    ctx.fillText(ap, width * .894, height * .371)
                }
            }

            Canvas {
                id: dateCanvas

                property int date: 0
                property int month: 0
                property string dateText: ""

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                onPaint: {
                    var ctx = getContext("2d")
                    prepareContext(ctx)
                    ctx.font = "25 " + height / 13 + "px Raleway"
                    ctx.fillText(dateText, width * .719, height * .595)
                }
            }
        }

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: parent

            layer.enabled: true
            layer.samples: 4

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
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                model: segmentAmount

                Shape {
                    id: segment

                    visible: index === 0 ? true : (index / segmentedArc.segmentAmount) < segmentedArc.inputValue

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
                        strokeWidth: parent.height * segmentedArc.arcStrokeWidth
                        capStyle: ShapePath.FlatCap
                        joinStyle: ShapePath.MiterJoin
                        startX: parent.width / 2
                        startY: parent.height * (.5 - segmentedArc.scalefactor)

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
                var month = wallClock.time.getMonth()
                var date = wallClock.time.getDate()
                var am = hour < 12
                if (use12H.value) {
                    hour = hour % 12
                    if (hour === 0) hour = 12
                }
                if (hourCanvas.hour !== hour) {
                    hourCanvas.hour = hour
                    hourCanvas.requestPaint()
                }
                if (minuteCanvas.minute !== minute) {
                    minuteCanvas.minute = minute
                    minuteCanvas.requestPaint()
                }
                if (dateCanvas.date !== date || dateCanvas.month !== month) {
                    dateCanvas.date = date
                    dateCanvas.month = month
                    dateCanvas.dateText = wallClock.time.toLocaleString(Qt.locale(), "d MMM")
                    dateCanvas.requestPaint()
                }
                if (amPmCanvas.am !== am) {
                    amPmCanvas.am = am
                    amPmCanvas.ap = wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP")
                    amPmCanvas.requestPaint()
                }
            }
        }

        Component.onCompleted: {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            var month = wallClock.time.getMonth()
            var date = wallClock.time.getDate()
            var am = hour < 12
            if (use12H.value) {
                hour = hour % 12
                if (hour === 0) hour = 12
            }
            hourCanvas.hour = hour
            hourCanvas.requestPaint()
            minuteCanvas.minute = minute
            minuteCanvas.requestPaint()
            dateCanvas.month = month
            dateCanvas.date = date
            dateCanvas.dateText = wallClock.time.toLocaleString(Qt.locale(), "d MMM")
            dateCanvas.requestPaint()
            amPmCanvas.am = am
            amPmCanvas.ap = wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP")
            amPmCanvas.requestPaint()
            burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .1 : .32) })
            burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .1 : .7) })
        }
    }
}
