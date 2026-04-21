// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
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
        id: root

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Item {
            id: scaleContent

            anchors.centerIn: parent
            width: parent.width * (nightstandMode.active ? .8 : 1)
            height: width

            Canvas {
                id: minuteArc

                property int minute: 0
                property real centerX: parent.width / 2
                property real centerY: parent.height / 2

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                visible: !displayAmbient && !nightstandMode.active

                onPaint: {
                    var ctx = getContext("2d")
                    var rot = (minute - 15) * 6
                    ctx.reset()
                    ctx.lineWidth = parent.width * .0031
                    // conical gradient arc — kept as Canvas since PathAngleArc has no conical gradient support
                    var gradient = ctx.createConicalGradient(centerX, centerY, 90 * .01745)
                    gradient.addColorStop(1 - (minute / 60), Qt.rgba(1, 1, 1, .4))
                    gradient.addColorStop(1 - (minute / 60 / 6), Qt.rgba(1, 1, 1, 0))
                    var gradient2 = ctx.createConicalGradient(centerX, centerY, 90 * .01745)
                    gradient2.addColorStop(1 - (minute / 60), Qt.rgba(1, 1, 1, .5))
                    gradient2.addColorStop(1 - (minute / 60 / 6), Qt.rgba(1, 1, 1, .01))
                    ctx.fillStyle = gradient
                    ctx.strokeStyle = gradient2
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, width / 2.75, -90 * .017453, rot * .017453, false)
                    ctx.lineTo(centerX, centerY)
                    ctx.fill()
                    ctx.stroke()
                }
            }

            Text {
                id: hourDisplay

                anchors.centerIn: parent
                renderType: Text.NativeRendering
                color: Qt.rgba(1, 1, 1, .9)
                opacity: .9
                horizontalAlignment: Text.AlignHCenter
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, .2)
                font {
                    pixelSize: parent.height * .87
                    family: "BebasKai"
                    styleName: "Bold"
                }
                text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) :
                                     wallClock.time.toLocaleString(Qt.locale(), "HH")
            }

            // Minute hand tip dot — Rectangle replaces Canvas circle
            Rectangle {
                id: minuteCircle

                width: parent.width / 8.6 * 2
                height: width
                radius: width / 2
                color: Qt.rgba(.184, .184, .184, .95)
            }

            Text {
                id: minuteDisplay

                color: "white"
                font {
                    pixelSize: parent.height / 5.24
                    family: "BebasKai"
                    styleName: "Condensed"
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
                property real arcStrokeWidth: .04
                property real scalefactor: .49 - (arcStrokeWidth / 2)
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
        }
    }

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            var min = wallClock.time.getMinutes()
            var rotM = (min - 15) / 60
            var cx = scaleContent.width / 2
            var cy = scaleContent.height / 2
            var dotR = scaleContent.width / 8.6

            minuteArc.minute = min
            minuteArc.requestPaint()

            minuteCircle.x = cx + Math.cos(rotM * 2 * Math.PI) * scaleContent.width / 2.75 - dotR
            minuteCircle.y = cy + Math.sin(rotM * 2 * Math.PI) * scaleContent.height / 2.75 - dotR

            minuteDisplay.x = cx - minuteDisplay.width / 2 + Math.cos(rotM * 2 * Math.PI) * scaleContent.width * .364
            minuteDisplay.y = cy - minuteDisplay.height / 2 + Math.sin(rotM * 2 * Math.PI) * scaleContent.width * .364
            minuteDisplay.text = wallClock.time.toLocaleString(Qt.locale(), "mm")
        }
    }

    Component.onCompleted: {
        var min = wallClock.time.getMinutes()
        var rotM = (min - 15) / 60
        var cx = scaleContent.width / 2
        var cy = scaleContent.height / 2
        var dotR = scaleContent.width / 8.6

        minuteArc.minute = min
        minuteArc.requestPaint()

        minuteCircle.x = cx + Math.cos(rotM * 2 * Math.PI) * scaleContent.width / 2.75 - dotR
        minuteCircle.y = cy + Math.sin(rotM * 2 * Math.PI) * scaleContent.height / 2.75 - dotR

        minuteDisplay.x = cx - minuteDisplay.width / 2 + Math.cos(rotM * 2 * Math.PI) * scaleContent.width * .364
        minuteDisplay.y = cy - minuteDisplay.height / 2 + Math.sin(rotM * 2 * Math.PI) * scaleContent.width * .364
        minuteDisplay.text = wallClock.time.toLocaleString(Qt.locale(), "mm")

        burnInProtectionManager.widthOffset = Qt.binding(function() { return width * .3 })
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height * .3 })
    }
}
