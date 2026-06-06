// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2017 Mario Kicherer <dev@kicherer.org>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later
// Based on analog-precison by Mario Kicherer. Remodeled the arms to arcs
// and tried hard on font centering and anchor alignment.

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import org.asteroid.controls

Item {
    property real radian: 0.01745

    function prepareContext(ctx) {
        ctx.reset();
        ctx.shadowColor = (0, 0, 0, 0.25);
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 0;
        ctx.shadowBlur = parent.height * 0.00625;
        ctx.lineCap = "round";
    }

    anchors.fill: parent

    Item {
        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height
        Component.onCompleted: {
            var hour = wallClock.time.getHours();
            var minute = wallClock.time.getMinutes();
            var second = wallClock.time.getSeconds();
            secondCanvas.second = second;
            secondCanvas.requestPaint();
            minuteCanvas.minute = minute;
            minuteCanvas.requestPaint();
            hourCanvas.hour = hour;
            hourCanvas.requestPaint();
            burnInProtectionManager.widthOffset = Qt.binding(function() {
                return width * (nightstandMode.active ? 0.08 : 0.3);
            });
            burnInProtectionManager.heightOffset = Qt.binding(function() {
                return height * (nightstandMode.active ? 0.08 : 0.3);
            });
        }

        Rectangle {
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - width / 2
            color: Qt.rgba(0, 0, 0, 0.2)
            width: parent.width / 1.3
            height: parent.height / 1.3
            radius: width * 0.5
        }

        Canvas {
            id: secondCanvas

            property int second: 0

            anchors.fill: parent
            smooth: true
            renderStrategy: Canvas.Cooperative
            visible: !displayAmbient && !nightstandMode.active
            onPaint: {
                var ctx = getContext("2d");
                var rot = (wallClock.time.getSeconds() - 15) * 6;
                var rot_half = (wallClock.time.getSeconds() - 22) * 6;
                prepareContext(ctx);
                ctx.beginPath();
                ctx.arc(parent.width / 2, parent.height / 2, width / 2.2, -89.5 * radian, rot * radian, false);
                ctx.lineWidth = parent.width * 0.009375;
                ctx.strokeStyle = Qt.rgba(0.871, 0.165, 0.102, 0.95);
                ctx.stroke();
            }
        }

        Canvas {
            id: minuteCanvas

            property int minute: 0

            anchors.fill: parent
            smooth: true
            renderStrategy: Canvas.Cooperative
            visible: !displayAmbient && !nightstandMode.active
            onPaint: {
                var ctx = getContext("2d");
                var rot = (minute - 15) * 6;
                prepareContext(ctx);
                ctx.beginPath();
                ctx.arc(parent.width / 2, parent.height / 2, width / 2.33, -88.8 * radian, rot * radian, false);
                ctx.lineWidth = parent.width * 0.01875;
                ctx.strokeStyle = Qt.rgba(1, 0.549, 0.149, 0.95);
                ctx.stroke();
            }
        }

        Canvas {
            id: hourCanvas

            property int hour: 0

            anchors.fill: parent
            smooth: true
            renderStrategy: Canvas.Cooperative
            visible: !displayAmbient && !nightstandMode.active
            onPaint: {
                var ctx = getContext("2d");
                var rot = 0.5 * (60 * (hour - 3) + wallClock.time.getMinutes());
                prepareContext(ctx);
                ctx.beginPath();
                ctx.arc(parent.width / 2, parent.height / 2, width / 2.6, 273.5 * radian, rot * radian, false);
                ctx.lineWidth = parent.width * 0.05;
                ctx.strokeStyle = Qt.rgba(0.945, 0.769, 0.059, 0.95);
                ctx.stroke();
                ctx.beginPath();
            }
        }

        Text {
            id: hourDisplay

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.5)
            text: {
                if (use12H.value) {
                    wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2);
                } else {
                    wallClock.time.toLocaleString(Qt.locale(), "HH");
                }
            }

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: -parent.width * 0.1085
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -parent.height * 0.03
            }

            font {
                pixelSize: parent.height * 0.375
                family: "Titillium"
                weight: Font.Bold
                letterSpacing: -3
            }

        }

        Text {
            id: minuteDisplay

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.5)
            text: wallClock.time.toLocaleString(Qt.locale(), "mm")

            anchors {
                left: parent.horizontalCenter
                leftMargin: parent.width * 0.117
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -parent.height * 0.085
            }

            font {
                pixelSize: parent.height * 0.1375
                letterSpacing: -1
            }

        }

        Text {
            id: secondDisplay

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.5)
            horizontalAlignment: Text.AlignHCenter
            visible: !displayAmbient
            text: wallClock.time.toLocaleString(Qt.locale(), "ss")

            anchors {
                left: parent.horizontalCenter
                leftMargin: parent.width * 0.1175
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: parent.height * 0.0665
            }

            font {
                pixelSize: parent.height * 0.1375
                family: "Titillium"
                weight: Font.Thin
                letterSpacing: -1
            }

        }

        Text {
            id: dowDisplay

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.5)
            horizontalAlignment: Text.AlignHCenter
            text: wallClock.time.toLocaleString(Qt.locale(), "dddd")

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: -parent.width * 0.002
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -parent.height * 0.2165
            }

            font {
                pixelSize: parent.height * 0.084375
                family: "Titillium"
                weight: Font.Thin
            }

        }

        Row {
            id: dateDisplay

            spacing: parent.width * 0.018

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: parent.width * 0.002
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: parent.height * 0.2
            }

            Text {
                renderType: Text.NativeRendering
                color: Qt.rgba(1, 1, 1, 1)
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.5)
                text: wallClock.time.toLocaleString(Qt.locale(), "dd")

                font {
                    pixelSize: parent.parent.height * 0.084375
                    family: "Titillium"
                    weight: Font.Medium
                }

            }

            Text {
                renderType: Text.NativeRendering
                color: Qt.rgba(1, 1, 1, 1)
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.5)
                text: wallClock.time.toLocaleString(Qt.locale(), "MMMM")

                font {
                    pixelSize: parent.parent.height * 0.084375
                    family: "Titillium"
                    weight: Font.Thin
                }

            }

        }

        Text {
            id: pmDisplay

            renderType: Text.NativeRendering
            color: Qt.rgba(1, 1, 1, 1)
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.5)
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.StyledText
            visible: use12H.value
            text: wallClock.time.toLocaleString(Qt.locale(), "<b>ap</b>")

            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: -parent.width * 0.0015
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -parent.height * 0.2975
            }

            font {
                pixelSize: parent.height * 0.05
                family: "Titillium"
                weight: Font.DemiBold
            }

        }

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: parent
            visible: nightstandMode.active

            Shape {
                id: chargeArc

                property real angle: batteryChargePercentage.percent * 360 / 100
                property real arcStrokeWidth: 0.03
                property real scalefactor: 0.45 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

                anchors.fill: parent

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: parent.height * chargeArc.arcStrokeWidth
                    capStyle: ShapePath.RoundCap
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

            Icon {
                id: batteryIcon

                name: "ios-battery-charging"
                visible: nightstandMode.active
                width: parent.width * 0.14
                height: parent.height * 0.14

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.width * 0.316
                }

            }

            ColorOverlay {
                anchors.fill: batteryIcon
                source: batteryIcon
                color: chargeArc.colorArray[chargeArc.chargecolor]
            }

            Text {
                id: batteryPercent

                renderType: Text.NativeRendering
                visible: nightstandMode.active
                color: chargeArc.colorArray[chargeArc.chargecolor]
                style: Text.Outline
                styleColor: "#80000000"
                text: batteryChargePercentage.percent + "%"

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * 0.324
                }

                font {
                    pixelSize: parent.width * 0.09
                    family: "Titillium"
                    styleName: "ExtraCondensed"
                }

            }

        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Connections {
            function onTimeChanged() {
                if (displayAmbient)
                    return ;

                var hour = wallClock.time.getHours();
                var minute = wallClock.time.getMinutes();
                var second = wallClock.time.getSeconds();
                if (secondCanvas.second !== second) {
                    secondCanvas.second = second;
                    secondCanvas.requestPaint();
                }
                if (hourCanvas.hour !== hour)
                    hourCanvas.hour = hour;

                if (minuteCanvas.minute !== minute) {
                    minuteCanvas.minute = minute;
                    minuteCanvas.requestPaint();
                    hourCanvas.requestPaint();
                }
            }

            target: wallClock
        }

    }

}
