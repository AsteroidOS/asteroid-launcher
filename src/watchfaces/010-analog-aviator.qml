// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-License-Identifier: LGPL-2.1-or-later

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
            layer.enabled: true
            layer.samples: 4
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
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
                readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

                model: segmentAmount

                Shape {
                    id: segment

                    visible: index === 0 ? true : (index / segmentedArc.segmentAmount) < segmentedArc.inputValue

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segmentedArc.colorArray[segmentedArc.chargecolor]
                        strokeWidth: parent.height * segmentedArc.arcStrokeWidth
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.MiterJoin
                        startX: parent.width / 2
                        startY: parent.height * (.5 - segmentedArc.scalefactor)

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
                samples: 9
                color: "#bb000000"
            }

            Image {
                id: asteroidLogo

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.324
                }
                antialiasing: true
                opacity: 1
                width: parent.width / 5.5
                height: parent.height / 5.5
                source: "../watchfaces-img/asteroid-logo-white.svg"
                state: currentColor

                states: State {
                    name: "black"
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
                color: "#bbffffff"
                horizontalAlignment: Text.AlignHCenter
                font {
                    pixelSize: parent.height * 0.048
                    family: "Raleway"
                }
                text: "<b>AsteroidOS</b><br>Free Your Wrist"
                state: currentColor

                states: State {
                    name: "black"
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
                    verticalCenterOffset: parent.height * 0.14
                }
                visible: !displayAmbient
                color: "#bbffffff"
                horizontalAlignment: Text.AlignHCenter
                font {
                    pixelSize: parent.height * 0.052
                    family: "Raleway"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b> MMMM<br>yyyy")
                state: currentColor

                states: State {
                    name: "black"
                    PropertyChanges { target: dateDisplay; color: "black" }
                }
                transitions: Transition {
                    from: ""; to: "black"; reversible: true
                    ColorAnimation { duration: 300 }
                }
            }

            Text {
                id: apDisplay

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 3.8
                    horizontalCenterOffset: parent.width / 3.8
                }
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                font {
                    pixelSize: parent.height * 0.065
                    family: "PTSans"
                    styleName: "Regular"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
                state: currentColor

                states: State {
                    name: "black"
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
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                font {
                    pixelSize: parent.height * 0.065
                    family: "PTSans"
                    styleName: "Regular"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 2).toUpperCase()
                state: currentColor

                states: State {
                    name: "black"
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
                    property real rotM: (index - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    visible: index % 5
                    antialiasing: true
                    x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.48
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.48
                    color: "#bbffffff"
                    width: parent.width * 0.0055
                    height: parent.height * 0.04

                    transform: Rotation { origin.x: width / 2; origin.y: height / 2; angle: index * 6 }
                    state: currentColor

                    states: State {
                        name: "black"
                        PropertyChanges { target: parent; color: "black" }
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
                    property real rotM: ((index * 15) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.35
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.35
                    color: "#ccffffff"
                    font {
                        pixelSize: parent.height * 0.21
                        family: "Signika"
                    }
                    text: index === 0 ? "" : index * 3
                    state: currentColor

                    states: State {
                        name: "black"
                        PropertyChanges { target: parent; color: "black" }
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
                    property real rotM: ((index * 5) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    width: parent.width * 0.020
                    height: [0, 3, 6, 9].includes(index) ? parent.height * 0.04 : parent.height * 0.13
                    x: [0, 3, 6, 9].includes(index) ?
                       centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.48 :
                       centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.44
                    y: [0, 3, 6, 9].includes(index) ?
                       centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.48 :
                       centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.44
                    antialiasing: true
                    color: "#ccffffff"

                    transform: Rotation { origin.x: width / 2; origin.y: height / 2; angle: index * 5 * 6 }
                    state: currentColor

                    states: State {
                        name: "black"
                        PropertyChanges { target: parent; color: "black" }
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
            source: imgPath + "hour-ambient.svg"

            transform: Rotation {
                id: hourRot
                origin.x: root.width / 2
                origin.y: root.height / 2
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 4
                verticalOffset: 4
                radius: 6.0
                samples: 9
                color: "#22000000"
            }
            state: currentColor

            states: State {
                name: "black"
                PropertyChanges { target: hourSVG; source: imgPath + "hour.svg" }
            }
        }

        Image {
            id: minuteSVG

            anchors.fill: root
            source: imgPath + "minute-ambient.svg"

            transform: Rotation {
                id: minuteRot
                origin.x: root.width / 2
                origin.y: root.height / 2
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 6
                verticalOffset: 6
                radius: 8.0
                samples: 9
                color: "#22000000"
            }
            state: currentColor

            states: State {
                name: "black"
                PropertyChanges { target: minuteSVG; source: imgPath + "minute.svg" }
            }
        }

        // second hand has no layer — 16ms Timer rotation would force constant 60fps recomposite
        Image {
            id: secondSVG

            property int toggle: 1

            anchors.fill: root
            visible: !displayAmbient
            source: imgPath + "second-ambient.svg"

            transform: Rotation {
                id: secondRot
                origin.x: root.width / 2
                origin.y: root.height / 2
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

            states: State {
                name: "black"
                PropertyChanges { target: secondSVG; source: imgPath + "second.svg" }
            }
        }

        Timer {
            interval: 16
            repeat: true
            running: !displayAmbient && visible

            onTriggered: {
                var now = new Date()
                secondRot.angle = (now.getSeconds() * 1000 + now.getMilliseconds()) * 6 / 1000
            }
        }

        Connections {
            target: wallClock
            function onTimeChanged() {
                var h = wallClock.time.getHours()
                var min = wallClock.time.getMinutes()
                var sec = wallClock.time.getSeconds()
                hourRot.angle = h * 30 + min * 0.5
                minuteRot.angle = min * 6 + sec * 6 / 60
            }
        }

        Connections {
            target: compositor
            function onDisplayAmbientEntered() {
                if (currentColor === "black") {
                    currentColor = ""
                    userColor = "black"
                } else {
                    userColor = ""
                }
            }
            function onDisplayAmbientLeft() {
                if (userColor === "black") {
                    currentColor = "black"
                }
            }
        }

        Component.onCompleted: {
            var h = wallClock.time.getHours()
            var min = wallClock.time.getMinutes()
            var sec = wallClock.time.getSeconds()
            hourRot.angle = h * 30 + min * 0.5
            minuteRot.angle = min * 6 + sec * 6 / 60
        }
    }
}
