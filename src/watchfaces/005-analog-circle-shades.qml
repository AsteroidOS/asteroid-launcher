// SPDX-FileCopyrightText: 2022 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import Nemo.Mce

Item {
    anchors.fill: parent

    property string imgPath: "../watchfaces-img/analog-circle-shades-"

    Item {
        id: root

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Item {
            id: batterySegments

            anchors.fill: parent
            visible: !displayAmbient || nightstand

            Repeater {
                id: segmentedArc

                property real inputValue: batteryChargePercentage.percent
                property int segmentAmount: 12
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .011
                property real scalefactor: .374 - (arcStrokeWidth / 2)

                model: segmentAmount

                Shape {
                    id: segment

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: index / segmentedArc.segmentAmount < segmentedArc.inputValue / 100 ? "#26C485" : "black"
                        strokeWidth: root.height * segmentedArc.arcStrokeWidth
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.MiterJoin
                        startX: root.width / 2
                        startY: root.height * (.5 - segmentedArc.scalefactor)

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

        Item {
            id: handBox

            anchors.fill: root

            Image {
                id: secondSVG

                anchors.fill: handBox
                visible: !displayAmbient
                source: imgPath + "second.svg"

                transform: Rotation {
                    id: secondRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }
            }

            Text {
                id: secondDisplay

                visible: !displayAmbient
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .082
                    family: "Roboto Flex"
                    letterSpacing: -parent.height * .005
                }
            }

            Image {
                id: minuteSVG

                anchors.fill: handBox
                source: imgPath + "minute.svg"

                transform: Rotation {
                    id: minuteRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 15.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .8)
                }
            }

            Text {
                id: minuteDisplay

                color: "black"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .12
                    family: "Roboto Flex"
                    weight: Font.Medium
                    letterSpacing: -parent.height * .006
                }
            }

            Image {
                id: hourSVG

                anchors.fill: parent
                source: imgPath + "hour.svg"

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 20.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .8)
                }
            }
        }

        Text {
            id: hourDisplay

            anchors {
                centerIn: parent
                verticalCenterOffset: parent.height * .004
                horizontalCenterOffset: -parent.height * .0012
            }
            color: "black"
            renderType: Text.NativeRendering
            font {
                pixelSize: parent.height * .18
                family: "Roboto Flex"
                weight: Font.Medium
                letterSpacing: -parent.height * .005
            }
            text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) : wallClock.time.toLocaleString(Qt.locale(), "HH")
        }
        
        Timer {
            interval: 16
            repeat: true
            running: !displayAmbient && visible

            onTriggered: {
                var now = new Date();
                var secMs = now.getSeconds() * 1000 + now.getMilliseconds();
                secondRot.angle = secMs * 6 / 1000;
                var rotS = (secMs / 1000 - 15) / 60;
                secondDisplay.x = root.width / 2 - secondDisplay.width / 1.9 + Math.cos(rotS * 2 * Math.PI) * root.width * .366;
                secondDisplay.y = root.height / 2 - secondDisplay.height / 2.06 + Math.sin(rotS * 2 * Math.PI) * root.height * .366;
            }
        }
        
        Connections {
            target: wallClock
            function onTimeChanged() {
                var min = wallClock.time.getMinutes();
                var sec = wallClock.time.getSeconds();
                minuteRot.angle = min * 6 + sec * 6 / 60;
                var rotM = (min - 15 + sec / 60) / 60;
                minuteDisplay.x = root.width / 2 - minuteDisplay.width / 1.92 + Math.cos(rotM * 2 * Math.PI) * root.height * .214;
                minuteDisplay.y = root.height / 2 - minuteDisplay.height / 2.04 + Math.sin(rotM * 2 * Math.PI) * root.width * .214;
                minuteDisplay.text = wallClock.time.toLocaleString(Qt.locale(), "mm");
                secondDisplay.text = wallClock.time.toLocaleString(Qt.locale(), "ss");
            }
        }
        
        Component.onCompleted: {
            var min = wallClock.time.getMinutes();
            var sec = wallClock.time.getSeconds();
            minuteRot.angle = min * 6 + sec * 6 / 60;
            var rotM = (min - 15 + sec / 60) / 60;
            minuteDisplay.x = root.width / 2 - minuteDisplay.width / 1.92 + Math.cos(rotM * 2 * Math.PI) * root.height * .214;
            minuteDisplay.y = root.height / 2 - minuteDisplay.height / 2.04 + Math.sin(rotM * 2 * Math.PI) * root.width * .214;
            minuteDisplay.text = wallClock.time.toLocaleString(Qt.locale(), "mm");
            secondDisplay.text = wallClock.time.toLocaleString(Qt.locale(), "ss");
        }
    }
}
