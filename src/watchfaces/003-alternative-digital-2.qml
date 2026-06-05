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

    Item {
        id: root

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        Item {
            id: watchfaceRoot

            anchors.centerIn: parent

            width: parent.width * (nightstandMode.active ? .8 : 1)
            height: width
            layer.enabled: true
            layer.effect: DropShadow {
                color: Qt.rgba(0, 0, 0, .80)
                horizontalOffset: root.height * .00625
                verticalOffset: root.height * .00625
                radius: root.height * .0152
                samples: 12
            }

            Text {
                id: hourText

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    horizontalCenterOffset: parent.height * .003
                    verticalCenterOffset: -parent.height * .212
                }
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .39
                    family: "Roboto"
                    weight: Font.Medium
                }
                text: {
                    var h = wallClock.time.getHours()
                    if (use12H.value) { h = h % 12; if (h === 0) h = 12 }
                    return h < 10 ? "0" + h : "" + h
                }
            }

            Text {
                id: minuteText

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: parent.height * .19
                }
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .38
                    family: "Roboto"
                    weight: Font.Light
                }
                text: Qt.formatTime(wallClock.time, "mm")
            }

            Text {
                id: dateText

                x: parent.width * .175
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -parent.height * .002
                }
                visible: !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .09
                    family: "Raleway"
                    weight: Font.Medium
                }
                text: Qt.formatDate(wallClock.time, "dd")
            }

            Text {
                id: monthText

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: parent.height * .006
                }
                visible: !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .07
                    family: "Raleway"
                    weight: Font.Normal
                }
                text: Qt.formatDate(wallClock.time, "MMMM").toUpperCase()
            }

            Text {
                id: amPmText

                x: parent.width * .83 - width
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: parent.height * .006
                }
                visible: use12H.value && !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .072
                    family: "Raleway"
                    weight: Font.Bold
                }
                text: wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP")
            }

            Text {
                id: secondText

                x: parent.width * .81 - width
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -parent.height * .002
                }
                visible: !use12H.value && !displayAmbient && !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .09
                    family: "Roboto"
                    weight: Font.Medium
                }
                text: Qt.formatTime(wallClock.time, "ss")
            }
        }

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

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
                readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                model: segmentAmount

                Shape {
                    id: segment

                    visible: index === 0 ? true : (index / segmentedArc.segmentAmount) < segmentedArc.inputValue

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
                        strokeWidth: root.height * segmentedArc.arcStrokeWidth
                        capStyle: ShapePath.FlatCap
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

        MceBatteryLevel {
            id: batteryChargePercentage
        }
    }
}
