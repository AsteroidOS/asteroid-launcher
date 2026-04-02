// SPDX-FileCopyrightText: 2022 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Florent Revest <revestflo@gmail.com>
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
                id: dowCanvas

                property string dow: ""

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                onPaint: {
                    var ctx = getContext("2d")
                    prepareContext(ctx)
                    ctx.shadowBlur = parent.height * .00625
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.font = "0 " + height * .051 + "px Xolonium"
                    ctx.fillText(dow, width * .373, height / 2 * .57 + height * .05)
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
                    ctx.font = "60 " + height * .36 + "px Xolonium"
                    ctx.fillText(twoDigits(hour), width / 2 * 1.25, height / 2 + height * .12)
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
                    ctx.font = "0 " + height * .17 + "px Xolonium"
                    ctx.fillText(twoDigits(minute), width / 2 * 1.268, height / 2 + height * .112)
                }
            }

            Canvas {
                id: amPmCanvas

                property string ap: ""

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                onPaint: {
                    var ctx = getContext("2d")
                    prepareContext(ctx)
                    ctx.shadowBlur = parent.height * .00625
                    ctx.textAlign = "left"
                    ctx.textBaseline = "left"
                    ctx.font = "64 " + height * .057 + "px Xolonium"
                    if (use12H.value) ctx.fillText(ap, width / 2 * 1.29, height / 2 * .83 + height * .05)
                }
            }

            Canvas {
                id: dateCanvas

                property string date: ""

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                onPaint: {
                    var ctx = getContext("2d")
                    prepareContext(ctx)
                    ctx.shadowBlur = parent.height * .00625
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.font = "0 " + height * .051 + "px Xolonium"
                    ctx.fillText(date, width * .626, height / 2 * 1.27 + height * .05)
                }
            }
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
                property real arcStrokeWidth: .024
                property real scalefactor: .42 - (arcStrokeWidth / 2)
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
                    verticalCenterOffset: -parent.width * .3
                }
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline
                styleColor: "#80000000"
                font {
                    pixelSize: parent.width / 20
                    family: "Xolonium"
                    styleName: "Bold"
                }
                text: batteryChargePercentage.percent + "%"
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
                    dowCanvas.dow = wallClock.time.toLocaleString(Qt.locale(), "dddd").toUpperCase()
                    dowCanvas.requestPaint()
                    dateCanvas.date = wallClock.time.toLocaleString(Qt.locale(), "dd MMMM").toUpperCase()
                    dateCanvas.requestPaint()
                }
                var ap = wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toUpperCase()
                if (amPmCanvas.ap !== ap) {
                    amPmCanvas.ap = ap
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

        Component.onCompleted: {
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            if (use12H.value) {
                hour = hour % 12
                if (hour === 0) hour = 12
            }
            hourCanvas.hour = hour
            hourCanvas.requestPaint()
            minuteCanvas.minute = minute
            minuteCanvas.requestPaint()
            dowCanvas.dow = wallClock.time.toLocaleString(Qt.locale(), "dddd").toUpperCase()
            dowCanvas.requestPaint()
            dateCanvas.date = wallClock.time.toLocaleString(Qt.locale(), "dd MMMM").toUpperCase()
            dateCanvas.requestPaint()
            amPmCanvas.ap = wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toUpperCase()
            amPmCanvas.requestPaint()
            burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .12 : .2) })
            burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .12 : .2) })
        }
    }
}
