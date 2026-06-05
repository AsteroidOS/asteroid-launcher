// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes

Item {
    anchors.fill: parent
    Component.onCompleted: {
        minuteArc.requestPaint();
        burnInProtectionManager.widthOffset = Qt.binding(function() {
            return width * 0.3;
        });
        burnInProtectionManager.heightOffset = Qt.binding(function() {
            return height * 0.3;
        });
    }

    Item {
        id: root

        property int currentMinute: wallClock.time.getMinutes()

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        Item {
            id: scaleContent

            anchors.centerIn: parent
            width: parent.width * (nightstandMode.active ? 0.8 : 1)
            height: width

            Canvas {
                id: minuteArc

                property real centerX: parent.width / 2
                property real centerY: parent.height / 2

                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                visible: !displayAmbient && !nightstandMode.active
                onPaint: {
                    var ctx = getContext("2d");
                    var rot = (wallClock.time.getMinutes() - 15) * 6;
                    ctx.reset();
                    ctx.lineWidth = parent.width * 0.0031;
                    var gradient = ctx.createConicalGradient(centerX, centerY, 90 * 0.01745);
                    gradient.addColorStop(1 - (wallClock.time.getMinutes() / 60), Qt.rgba(1, 1, 1, 0.4));
                    gradient.addColorStop(1 - (wallClock.time.getMinutes() / 60 / 6), Qt.rgba(1, 1, 1, 0));
                    var gradient2 = ctx.createConicalGradient(centerX, centerY, 90 * 0.01745);
                    gradient2.addColorStop(1 - (wallClock.time.getMinutes() / 60), Qt.rgba(1, 1, 1, 0.5));
                    gradient2.addColorStop(1 - (wallClock.time.getMinutes() / 60 / 6), Qt.rgba(1, 1, 1, 0.01));
                    ctx.fillStyle = gradient;
                    ctx.strokeStyle = gradient2;
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, width / 2.75, -90 * 0.017453, rot * 0.017453, false);
                    ctx.lineTo(centerX, centerY);
                    ctx.fill();
                    ctx.stroke();
                }
            }

            Text {
                id: hourDisplay

                renderType: Text.NativeRendering
                color: Qt.rgba(1, 1, 1, 0.9)
                opacity: 0.9
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.2)
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (use12H.value) {
                        wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2);
                    } else {
                        wallClock.time.toLocaleString(Qt.locale(), "HH");
                    }
                }

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                font {
                    pixelSize: parent.height * 0.87
                    family: "BebasKai"
                    weight: Font.Bold
                }

            }

            Rectangle {
                id: minuteCircle

                property real rotM: (wallClock.time.getMinutes() - 15) / 60
                property real centerX: parent.width / 2 - width / 2
                property real centerY: parent.height / 2 - height / 2

                x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.364
                y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.364
                width: parent.width / 4.3
                height: width
                radius: width / 2
                color: Qt.rgba(0.184, 0.184, 0.184, 0.95)
                visible: !displayAmbient && !nightstandMode.active
            }

            Text {
                id: minuteDisplay

                property real rotM: (wallClock.time.getMinutes() - 15) / 60
                property real centerX: parent.width / 2 - width / 2
                property real centerY: parent.height / 2 - height / 2

                renderType: Text.NativeRendering
                color: "white"
                opacity: 1
                x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.364
                y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.364
                text: wallClock.time.toLocaleString(Qt.locale(), "mm")

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
                property real arcStrokeWidth: 0.04
                property real scalefactor: 0.49 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: parent

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: parent.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.FlatCap
                    joinStyle: ShapePath.MiterJoin
                    startX: chargeArc.width / 2
                    startY: chargeArc.height * (0.5 - chargeArc.scalefactor)

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
        function onTimeChanged() {
            var minute = wallClock.time.getMinutes();
            if (currentMinute !== minute) {
                currentMinute = minute;
                minuteArc.requestPaint();
            }
        }

        target: wallClock
    }

}
