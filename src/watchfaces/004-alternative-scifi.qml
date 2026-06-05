// SPDX-FileCopyrightText: 2022 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griét <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2016 Florent Revest <revestflo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
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
                horizontalOffset: root.height * .0062
                verticalOffset: root.height * .0062
                radius: root.height * .0166
                samples: 12
                color: Qt.rgba(0, 0, 0, .84)
            }
            

            Text {
                id: dowText

                x: parent.width * .373 - width / 2
                y: parent.height * .324 - height / 2
                visible: !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .051
                    family: "Xolonium"
                }
                text: Qt.formatDate(wallClock.time, "dddd").toUpperCase()
            }

            Text {
                id: hourText

                x: parent.width * .625 - width
                y: parent.height * .61 - height * .75
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .36
                    family: "Xolonium"
                }
                text: {
                    var h = wallClock.time.getHours()
                    if (use12H.value) { h = h % 12; if (h === 0) h = 12 }
                    return h < 10 ? "0" + h : "" + h
                }
            }

            Text {
                id: minuteText

                x: parent.width * .64
                y: parent.height * .611 - height * .75
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .17
                    family: "Xolonium"
                }
                text: Qt.formatTime(wallClock.time, "mm")
            }

            Text {
                id: amPmText

                x: parent.width * .645
                y: parent.height * .465 - height * .75
                visible: use12H.value && !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .057
                    family: "Xolonium"
                }
                text: wallClock.time.toLocaleString(Qt.locale("en_EN"), "AP")
            }

            Text {
                id: dateText

                x: parent.width * .626 - width / 2
                y: parent.height * .675 - height / 2
                visible: !nightstandMode.active
                color: "white"
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.height * .051
                    family: "Xolonium"
                }
                text: Qt.formatDate(wallClock.time, "dd MMMM").toUpperCase()
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
                property real arcStrokeWidth: .024
                property real scalefactor: .42 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: [ "red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                anchors.fill: parent

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                    strokeWidth: chargeArc.height * chargeArc.arcStrokeWidth
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
                renderType: Text.NativeRendering
                font {
                    pixelSize: parent.width / 20
                    family: "Xolonium"
                    weight: Font.Bold
                }
                text: batteryChargePercentage.percent + "%"
            }
        }

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Component.onCompleted: {
            burnInProtectionManager.widthOffset = Qt.binding(function() { return width * (nightstandMode.active ? .12 : .2) })
            burnInProtectionManager.heightOffset = Qt.binding(function() { return height * (nightstandMode.active ? .12 : .2) })
        }
    }
}
