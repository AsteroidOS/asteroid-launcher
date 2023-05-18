/*
 * Copyright (C) 2023 - Timo Könnecke <github.com/eLtMosen>
 *
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

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
            id: nightstandMode

            readonly property bool active: nightstand
            property int batteryPercentChanged: batteryChargePercentage.percent

            anchors.fill: root
            visible: nightstandMode.active
            layer {
                enabled: true
                samples: 4
                smooth: true
                textureSize: Qt.size(nightstandMode.width * 2, nightstandMode.height * 2)
            }

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
                property real chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: [ "red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                model: segmentAmount

                Shape {
                    id: segment

                    visible: index === 0 ? true : (index/segmentedArc.segmentAmount) < segmentedArc.inputValue

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
                        strokeWidth: parent.height * segmentedArc.arcStrokeWidth
                        capStyle: ShapePath.FlatCap
                        joinStyle: ShapePath.MiterJoin
                        startX: parent.width / 2
                        startY: parent.height * ( .5 - segmentedArc.scalefactor)

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

        Item {
            id: watchfaceRoot

            anchors.centerIn: root
            width: root.width * (nightstandMode.active ? .8 : 1)
            height: width

            Text {
                id: hourDisplay

                anchors {
                    centerIn: watchfaceRoot
                    verticalCenterOffset: -watchfaceRoot.height * .218
                }
                renderType: Text.NativeRendering
                font {
                    pixelSize: watchfaceRoot.height * .4
                    letterSpacing: watchfaceRoot.height * .006
                    family: "Outfit"
                    styleName: "Medium"
                }
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                text: use12H.value ?
                          wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) :
                          wallClock.time.toLocaleString(Qt.locale(), "HH")
            }

            Text {
                id: apDisplay

                anchors {
                    left: hourDisplay.right
                    leftMargin: watchfaceRoot.height * .01
                    bottom: watchfaceRoot.verticalCenter
                    bottomMargin: watchfaceRoot.height * .22
                }
                renderType: Text.NativeRendering
                visible: use12H.value
                color: "#ddffffff"
                font {
                    pixelSize: watchfaceRoot.height * .076
                    family: "Outfit"
                    styleName: "Regular"
                    letterSpacing: watchfaceRoot.height * .006
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
            }

            Text {
                id: monthDisplay

                anchors.centerIn: watchfaceRoot

                renderType: Text.NativeRendering
                color: "#ddffffff"
                horizontalAlignment: Text.AlignHCenter
                font {
                    pixelSize: watchfaceRoot.height * .1
                    letterSpacing: watchfaceRoot.height * .006
                    family: "Outfit"
                    styleName: "Light"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "MMM dd").replace(".","").toUpperCase()
            }

            Text {
                id: minuteDisplay

                anchors {
                    centerIn: watchfaceRoot
                    verticalCenterOffset: watchfaceRoot.height * .21
                }
                renderType: Text.NativeRendering
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                font {
                    pixelSize: watchfaceRoot.height * .4
                    letterSpacing: watchfaceRoot.height * .006
                    family: "Outfit"
                    styleName: "Light"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "mm")
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 4
                verticalOffset: 4
                radius: 7.0
                samples: 15
                color: "#99000000"
            }
        }
    }
}
