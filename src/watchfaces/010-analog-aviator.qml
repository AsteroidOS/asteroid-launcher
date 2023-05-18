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

    property string currentColor: ""
    property string userColor: ""
    property string imgPath: "../watchfaces-img/analog-aviator-"

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Item {
        id: root

        anchors.centerIn: parent

        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: parent

            layer {
                enabled: true
                samples: 4
                smooth: true
                textureSize: Qt.size(nightstandMode.width * 2, nightstandMode.height * 2)
            }
            visible: nightstandMode.active

            Repeater {
                id: segmentedArc

                property real inputValue: batteryChargePercentage.percent / 100
                property int segmentAmount: 12
                property int start: 0
                property int gap: 0
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .015
                property real scalefactor: .49 - (arcStrokeWidth / 2)
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
                        capStyle: ShapePath.RoundCap
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

        Item {
            id: dialBox

            anchors.fill: parent

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 2
                radius: 12.0
                samples: 17
                color: "#bb000000"
            }

            Image {
                id: asteroidLogo

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.324
                }
                source: "../watchfaces-img/asteroid-logo-white.svg"
                antialiasing: true

                width: parent.width / 5.5
                height: parent.height / 5.5
                opacity: 1
                state: currentColor
                states: State { name: "black"
                    PropertyChanges {
                        target: asteroidLogo
                        source: "../watchfaces-img/asteroid-logo-black.svg"
                    }
                }
            }

            Text {
                id: asteroidSlogan

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.146
                }
                visible: !displayAmbient
                font {
                    pixelSize: parent.height * 0.048
                    family: "Raleway"
                }
                color: "#bbffffff"
                horizontalAlignment: Text.AlignHCenter
                text: "<b>AsteroidOS</b><br>Free Your Wrist"
                state: currentColor
                states: State { name: "black";
                    PropertyChanges { target: asteroidSlogan; color: "black" }
                }
                transitions: Transition {
                    from: ""; to: "black"; reversible: true
                        ColorAnimation { duration: 300 }
                }
            }

            Text {
                id: dateDisplay

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height*0.14
                }
                visible: !displayAmbient
                font {
                    pixelSize: parent.height * 0.052
                    family: "Raleway"
                }
                color: "#bbffffff"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b> MMMM<br>yyyy")
                state: currentColor
                states: State { name: "black";
                    PropertyChanges { target: dateDisplay; color: "black" }
                }
                transitions: Transition {
                    from: ""; to: "black"; reversible: true
                        ColorAnimation { duration: 300 }
                }
            }

            Text {
                id: apDisplay

                property int day: wallClock.time.toLocaleString(Qt.locale(), "d")
                property int month: wallClock.time.toLocaleString(Qt.locale(), "M")

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 3.8
                    horizontalCenterOffset: parent.width/3.8
                }
                font {
                    pixelSize: parent.height * 0.065
                    family: "PTSans"
                    styleName: "Regular"
                }
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
                state: currentColor
                states: State { name: "black";
                    PropertyChanges { target: apDisplay; color: "black" }
                }
                transitions: Transition {
                    from: ""; to: "black"; reversible: true
                        ColorAnimation { duration: 300 }
                }
            }

            Text {
                id: dowDisplay

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 3.8
                    horizontalCenterOffset: -parent.width / 3.8
                }
                font {
                    pixelSize: parent.height*0.065
                    family: "PTSans"
                    styleName: "Regular"
                }
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 2).toUpperCase()
                state: currentColor
                states: State { name: "black";
                    PropertyChanges { target: dowDisplay; color: "black" }
                }
                transitions: Transition {
                    from: ""; to: "black"; reversible: true
                        ColorAnimation { duration: 300 }
                }
            }

            Repeater {
                model: 60

                Rectangle {
                    id: minuteStrokes

                    property real rotM: ((index) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    visible: index % 5
                    antialiasing : true
                    x: centerX+Math.cos(rotM * 2 * Math.PI) * parent.width * 0.48
                    y: centerY+Math.sin(rotM * 2 * Math.PI) * parent.width * 0.48
                    color: "#bbffffff"
                    width: parent.width * 0.0055
                    height: parent.height * 0.04
                    transform: Rotation { origin.x: width / 2; origin.y: height / 2; angle: (index) * 6}
                    state: currentColor
                    states: State { name: "black";
                        PropertyChanges { target: minuteStrokes; color: "black" }
                    }
                    transitions: Transition {
                        from: ""; to: "black"; reversible: true
                            ColorAnimation { duration: 300 }
                    }
                }
            }

            Repeater {
                model: 4

                Text {
                    id: hourNumbers

                    property real rotM: ((index * 15 ) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2.0

                    font {
                        pixelSize: parent.height * 0.21
                        family: "Signika"
                    }
                    x: centerX+Math.cos(rotM * 2 * Math.PI) * parent.width * 0.35
                    y: centerY+Math.sin(rotM * 2 * Math.PI) * parent.width * 0.35
                    color: "#ccffffff"
                    text: if (index === 0)
                              ""
                          else
                              index * 3
                    state: currentColor
                    states: State { name: "black";
                        PropertyChanges { target: hourNumbers; color: "black" }
                    }
                    transitions: Transition {
                        from: ""; to: "black"; reversible: true
                            ColorAnimation { duration: 300 }
                    }
                }
            }

            Repeater {
                model: 12

                Rectangle {
                    id: hourStrokes

                    property real rotM: ((index * 5 ) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    width: parent.width * 0.020
                    height: [0, 3, 6, 9].includes(index) ? parent.height * 0.04 : parent.height * 0.13
                    x: if ([0, 3, 6, 9].includes(index))
                           centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.48
                       else
                           centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.44
                    y: if ([0, 3, 6, 9].includes(index))
                           centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.48
                       else
                           centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.44
                    antialiasing : true
                    color: "#ccffffff"
                    transform: Rotation { origin.x: width / 2; origin.y: height / 2; angle: (index * 5) * 6}
                    state: currentColor
                    states: State { name: "black";
                        PropertyChanges { target: hourStrokes; color: "black" }
                    }
                    transitions: Transition {
                        from: ""; to: "black"; reversible: true
                            ColorAnimation { duration: 300 }
                    }
                }
            }
        }

        Image {
            id: hourSVG

            anchors.fill: root

            source: !displayAmbient ? imgPath + "hour-ambient.svg" : imgPath + "hour-ambient.svg"
            transform: Rotation {
                origin.x: root.width / 2;
                origin.y: root.height / 2;
                angle: (wallClock.time.getHours()*30) + (wallClock.time.getMinutes() * 0.5)
            }
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 4
                verticalOffset: 4
                radius: 6.0
                samples: 17
                color: "#22000000"
            }
            state: currentColor
            states: State { name: "black"
                PropertyChanges {
                    target: hourSVG
                    source: imgPath + "hour.svg"
                }
            }
        }

        Image {
            id: minuteSVG

            anchors.fill: root

            source: !displayAmbient ? imgPath + "minute-ambient.svg" : imgPath + "minute-ambient.svg"
            transform: Rotation {
                origin.x: root.width / 2;
                origin.y: root.height / 2;
                angle: (wallClock.time.getMinutes()*6)+(wallClock.time.getSeconds() * 6 / 60)
            }
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 6
                verticalOffset: 6
                radius: 8.0
                samples: 17
                color: "#22000000"
            }
            state: currentColor
            states: State { name: "black"
                PropertyChanges {
                    target: minuteSVG
                    source: imgPath + "minute.svg"
                }
            }
        }

        Image {
            id: secondSVG

            property int toggle: 1

            anchors.fill: root

            visible: !displayAmbient
            source: imgPath + "second-ambient.svg"
            transform: Rotation {
                origin.x: root.width / 2;
                origin.y: root.height / 2;
                angle: (wallClock.time.getSeconds() * 6)
            }
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 8
                verticalOffset: 8
                radius: 9.0
                samples: 12
                color: "#22000000"
            }
            MouseArea {
                anchors.fill: parent
                onDoubleClicked: {
                   if (secondSVG.toggle === 1) {
                        currentColor = "black"
                        secondSVG.toggle = 0
                   } else {
                        currentColor = ""
                        secondSVG.toggle = 1
                    }
                }
            }
            state: currentColor
            states: State { name: "black"
                PropertyChanges {
                    target: secondSVG
                    source: imgPath + "second.svg"
                }
            }
        }
    }

    Connections {
        target: compositor
        onDisplayAmbientEntered: if (currentColor == "black") {
                                     currentColor = ""
                                     userColor = "black"
                                 }
                                 else
                                     userColor = ""

        onDisplayAmbientLeft:    if (userColor == "black") {
                                     currentColor = "black"
                                 }
    }
}
