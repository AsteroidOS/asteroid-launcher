// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import org.asteroid.controls
import org.asteroid.utils
import Nemo.Mce

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
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                model: segmentAmount

                Shape {
                    id: segment

                    visible: index === 0 ? true : (index/segmentedArc.segmentAmount) < segmentedArc.inputValue

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
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
            id: dialBox

            anchors.fill: parent

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * .005
                verticalOffset: root.width * .005
                radius: root.width * .03
                samples: 25
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
                id: hourRotation

                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: 0
            }
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * .01
                verticalOffset: root.width * .01
                radius: root.width * .015
                samples: 13
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
                id: minuteRotation

                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: 0
            }
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * .015
                verticalOffset: root.width * .015
                radius: root.width * .02
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
                id: secondRotation

                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: 0
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
        
        Connections {
            function onTimeChanged() {
                var hours = wallClock.time.getHours()
                var minutes = wallClock.time.getMinutes()
                hourRotation.angle = (hours * 30) + (minutes * .5)
                minuteRotation.angle = (minutes * 6) + (wallClock.time.getSeconds() * .1)
            }
            target: wallClock
        }

        Timer {
            interval: 16
            repeat: true
            running: !displayAmbient && visible
            onTriggered: {
                var now = new Date()
                secondRotation.angle = (now.getSeconds() * 1000 + now.getMilliseconds()) * 6 / 1000
            }
        }

        Component.onCompleted: {
            var hours = wallClock.time.getHours()
            var minutes = wallClock.time.getMinutes()
            hourRotation.angle = (hours * 30) + (minutes * .5)
            minuteRotation.angle = (minutes * 6) + (wallClock.time.getSeconds() * .1)
        }
    }

    Connections {
        function onDisplayAmbientEntered() {
            if (currentColor == "black") {
                currentColor = ""
                userColor = "black"
            } else {
                userColor = ""
            }
        }
        function onDisplayAmbientLeft() {
            if (userColor == "black") {
                currentColor = "black"
            }
        }
        target: compositor
    }
}
