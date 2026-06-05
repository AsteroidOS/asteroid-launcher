// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-License-Identifier: LGPL-2.1-or-later

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes

Item {
    anchors.fill: parent

    Item {
        id: root

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: root
            visible: nightstandMode.active

            Repeater {
                id: segmentedArc

                property real inputValue: batteryChargePercentage.percent / 100
                property int segmentAmount: 48
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: 0.05
                property real scalefactor: 0.46 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

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
                        startY: root.height * (0.5 - segmentedArc.scalefactor)

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

        Item {
            id: watchfaceRoot

            anchors.centerIn: root
            width: root.width * (nightstandMode.active ? 0.8 : 1)
            height: width
            layer.enabled: true

            Text {
                id: hourDisplay

                renderType: Text.NativeRendering
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) : wallClock.time.toLocaleString(Qt.locale(), "HH")

                anchors {
                    centerIn: watchfaceRoot
                    verticalCenterOffset: -watchfaceRoot.height * 0.218
                }

                font {
                    pixelSize: watchfaceRoot.height * 0.4
                    letterSpacing: watchfaceRoot.height * 0.006
                    family: "Outfit"
                    weight: Font.Medium
                }

            }

            Text {
                id: apDisplay

                renderType: Text.NativeRendering
                visible: use12H.value
                color: "#ddffffff"
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()

                anchors {
                    left: hourDisplay.right
                    leftMargin: watchfaceRoot.height * 0.01
                    bottom: watchfaceRoot.verticalCenter
                    bottomMargin: watchfaceRoot.height * 0.22
                }

                font {
                    pixelSize: watchfaceRoot.height * 0.076
                    family: "Outfit"
                    letterSpacing: watchfaceRoot.height * 0.006
                }

            }

            Text {
                id: monthDisplay

                anchors.centerIn: watchfaceRoot
                renderType: Text.NativeRendering
                color: "#ddffffff"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "MMM dd").replace(".", "").toUpperCase()

                font {
                    pixelSize: watchfaceRoot.height * 0.1
                    letterSpacing: watchfaceRoot.height * 0.006
                    family: "Outfit"
                    weight: Font.Light
                }

            }

            Text {
                id: minuteDisplay

                renderType: Text.NativeRendering
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "mm")

                anchors {
                    centerIn: watchfaceRoot
                    verticalCenterOffset: watchfaceRoot.height * 0.21
                }

                font {
                    pixelSize: watchfaceRoot.height * 0.4
                    letterSpacing: watchfaceRoot.height * 0.006
                    family: "Outfit"
                    weight: Font.Light
                }

            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: watchfaceRoot.height * 0.01
                verticalOffset: watchfaceRoot.height * 0.01
                radius: watchfaceRoot.height * 0.018
                samples: 9
                color: "#99000000"
            }

        }

    }

}
