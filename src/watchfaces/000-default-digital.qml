// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2017 Florent Revest <revestflo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes

Item {
    anchors.fill: parent

    Item {
        id: root

        // Time values, declarative bindings on the launcher wallClock.
        property int hour24: wallClock.time.getHours()
        property int displayHour: use12H.value ? (hour24 % 12 === 0 ? 12 : hour24 % 12) : hour24
        property int minutes: wallClock.time.getMinutes()
        property string apText: wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP")
        property string dateText: wallClock.time.toLocaleString(Qt.locale(), "d MMM")

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        Item {
            id: watchfaceRoot

            anchors.centerIn: parent
            width: parent.width * (nightstandMode.active ? .86 : 1)
            height: width

            layer.enabled: true
            layer.effect: DropShadow {
                color: "black"
                horizontalOffset: 0
                verticalOffset: 0
                radius: root.height * .0235
                samples: 17
            }

            Text {
                id: hourLabel

                anchors {
                    centerIn: parent
                    horizontalCenterOffset: parent.width * (.379 - .5)
                    verticalCenterOffset: parent.height * (.487 - .5)
                }
                color: "white"
                renderType: Text.NativeRendering
                font {
                    family: "Roboto"
                    pixelSize: parent.height * .36
                    weight: Font.Medium
                }
                text: root.displayHour < 10 ? "0" + root.displayHour : "" + root.displayHour
            }

            Text {
                id: minuteLabel

                anchors {
                    centerIn: parent
                    horizontalCenterOffset: parent.width * (.717 - .5)
                    verticalCenterOffset: parent.height * (.45 - .5)
                }
                color: "white"
                renderType: Text.NativeRendering
                font {
                    family: "Roboto"
                    pixelSize: parent.height * .18
                    weight: Font.Light
                }
                text: root.minutes < 10 ? "0" + root.minutes : "" + root.minutes
            }

            Text {
                id: apLabel

                anchors {
                    centerIn: parent
                    horizontalCenterOffset: parent.width * (.898 - .5)
                    verticalCenterOffset: parent.height * (.368 - .5)
                }
                visible: use12H.value
                color: "white"
                renderType: Text.NativeRendering
                font {
                    family: "Raleway"
                    pixelSize: parent.height * .065
                    weight: Font.Light
                }
                text: root.apText
            }

            Text {
                id: dateLabel

                anchors {
                    centerIn: parent
                    horizontalCenterOffset: parent.width * (.719 - .5)
                    verticalCenterOffset: parent.height * (.587 - .5)
                }
                color: "white"
                renderType: Text.NativeRendering
                font {
                    family: "Raleway"
                    pixelSize: parent.height * .076
                    weight: Font.Light
                }
                text: root.dateText
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
                property int segmentAmount: 50
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .055
                property real scalefactor: .45 - (arcStrokeWidth / 2)
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

        Component.onCompleted: {
            burnInProtectionManager.widthOffset = Qt.binding(function() { return root.width * (nightstandMode.active ? .1 : .32) })
            burnInProtectionManager.heightOffset = Qt.binding(function() { return root.height * (nightstandMode.active ? .1 : .7) })
        }
    }
}
