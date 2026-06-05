// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-License-Identifier: LGPL-2.1-or-later

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes

Item {
    property string currentColor: ""
    property string userColor: ""
    property string imgPath: "../watchfaces-img/analog-aviator-"

    anchors.fill: parent

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Item {
        id: root

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height
        Component.onCompleted: {
            var hours = wallClock.time.getHours();
            var minutes = wallClock.time.getMinutes();
            hourRotation.angle = (hours * 30) + (minutes * 0.5);
            minuteRotation.angle = (minutes * 6) + (wallClock.time.getSeconds() * 0.1);
        }

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
                property real arcStrokeWidth: 0.015
                property real scalefactor: 0.49 - (arcStrokeWidth / 2)
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
                        capStyle: ShapePath.RoundCap
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

        Item {
            id: dialBox

            anchors.fill: parent
            layer.enabled: true

            Image {
                id: asteroidLogo

                source: "../watchfaces-img/asteroid-logo-white.svg"
                antialiasing: true
                width: parent.width / 5.5
                height: parent.height / 5.5
                opacity: 1
                state: currentColor

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.324
                }

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

                renderType: Text.NativeRendering
                visible: !displayAmbient
                color: "#bbffffff"
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                text: "<b>AsteroidOS</b><br>Free Your Wrist"
                state: currentColor

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.146
                }

                font {
                    pixelSize: parent.height * 0.048
                    family: "Raleway"
                }

                states: State {
                    name: "black"

                    PropertyChanges {
                        target: asteroidSlogan
                        color: "black"
                    }

                }

                transitions: Transition {
                    from: ""
                    to: "black"
                    reversible: true

                    ColorAnimation {
                        duration: 300
                    }

                }

            }

            Text {
                id: dateDisplay

                renderType: Text.NativeRendering
                visible: !displayAmbient
                color: "#bbffffff"
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b> MMMM<br>yyyy")
                state: currentColor

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height * 0.14
                }

                font {
                    pixelSize: parent.height * 0.052
                    family: "Raleway"
                }

                states: State {
                    name: "black"

                    PropertyChanges {
                        target: dateDisplay
                        color: "black"
                    }

                }

                transitions: Transition {
                    from: ""
                    to: "black"
                    reversible: true

                    ColorAnimation {
                        duration: 300
                    }

                }

            }

            Text {
                id: apDisplay

                renderType: Text.NativeRendering
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
                state: currentColor

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 3.8
                    horizontalCenterOffset: parent.width / 3.8
                }

                font {
                    pixelSize: parent.height * 0.065
                    family: "PTSans"
                }

                states: State {
                    name: "black"

                    PropertyChanges {
                        target: apDisplay
                        color: "black"
                    }

                }

                transitions: Transition {
                    from: ""
                    to: "black"
                    reversible: true

                    ColorAnimation {
                        duration: 300
                    }

                }

            }

            Text {
                id: dowDisplay

                renderType: Text.NativeRendering
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                text: wallClock.time.toLocaleString(Qt.locale(), "ddd").slice(0, 2).toUpperCase()
                state: currentColor

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.height / 3.8
                    horizontalCenterOffset: -parent.width / 3.8
                }

                font {
                    pixelSize: parent.height * 0.065
                    family: "PTSans"
                }

                states: State {
                    name: "black"

                    PropertyChanges {
                        target: dowDisplay
                        color: "black"
                    }

                }

                transitions: Transition {
                    from: ""
                    to: "black"
                    reversible: true

                    ColorAnimation {
                        duration: 300
                    }

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
                    antialiasing: true
                    x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.48
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.48
                    color: "#bbffffff"
                    width: parent.width * 0.0055
                    height: parent.height * 0.04
                    state: currentColor

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: (index) * 6
                    }

                    states: State {
                        name: "black"

                        PropertyChanges {
                            target: minuteStrokes
                            color: "black"
                        }

                    }

                    transitions: Transition {
                        from: ""
                        to: "black"
                        reversible: true

                        ColorAnimation {
                            duration: 300
                        }

                    }

                }

            }

            Repeater {
                model: 4

                Text {
                    id: hourNumbers

                    property real rotM: ((index * 15) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    renderType: Text.NativeRendering
                    x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.35
                    y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.35
                    color: "#ccffffff"
                    text: {
                        if (index === 0) {
                            "";
                        } else {
                            index * 3;
                        }
                    }
                    state: currentColor

                    font {
                        pixelSize: parent.height * 0.21
                        family: "Signika"
                    }

                    states: State {
                        name: "black"

                        PropertyChanges {
                            target: hourNumbers
                            color: "black"
                        }

                    }

                    transitions: Transition {
                        from: ""
                        to: "black"
                        reversible: true

                        ColorAnimation {
                            duration: 300
                        }

                    }

                }

            }

            Repeater {
                model: 12

                Rectangle {
                    id: hourStrokes

                    property real rotM: ((index * 5) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    width: parent.width * 0.02
                    height: [0, 3, 6, 9].includes(index) ? parent.height * 0.04 : parent.height * 0.13
                    x: {
                        if ([0, 3, 6, 9].includes(index)) {
                            centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.48;
                        } else {
                            centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * 0.44;
                        }
                    }
                    y: {
                        if ([0, 3, 6, 9].includes(index)) {
                            centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.48;
                        } else {
                            centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * 0.44;
                        }
                    }
                    antialiasing: true
                    color: "#ccffffff"
                    state: currentColor

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: (index * 5) * 6
                    }

                    states: State {
                        name: "black"

                        PropertyChanges {
                            target: hourStrokes
                            color: "black"
                        }

                    }

                    transitions: Transition {
                        from: ""
                        to: "black"
                        reversible: true

                        ColorAnimation {
                            duration: 300
                        }

                    }

                }

            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * 0.005
                verticalOffset: root.width * 0.005
                radius: root.width * 0.03
                samples: 25
                color: "#bb000000"
            }

        }

        Image {
            id: hourSVG

            anchors.fill: root
            source: !displayAmbient ? imgPath + "hour-ambient.svg" : imgPath + "hour-ambient.svg"
            layer.enabled: true
            state: currentColor

            transform: Rotation {
                id: hourRotation

                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: 0
            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * 0.01
                verticalOffset: root.width * 0.01
                radius: root.width * 0.015
                samples: 13
                color: "#22000000"
            }

            states: State {
                name: "black"

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
            layer.enabled: true
            state: currentColor

            transform: Rotation {
                id: minuteRotation

                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: 0
            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * 0.015
                verticalOffset: root.width * 0.015
                radius: root.width * 0.02
                samples: 17
                color: "#22000000"
            }

            states: State {
                name: "black"

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
            state: currentColor

            MouseArea {
                anchors.fill: parent
                onDoubleClicked: {
                    if (secondSVG.toggle === 1) {
                        currentColor = "black";
                        secondSVG.toggle = 0;
                    } else {
                        currentColor = "";
                        secondSVG.toggle = 1;
                    }
                }
            }

            transform: Rotation {
                id: secondRotation

                origin.x: root.width / 2
                origin.y: root.height / 2
                angle: 0
            }

            states: State {
                name: "black"

                PropertyChanges {
                    target: secondSVG
                    source: imgPath + "second.svg"
                }

            }

        }

        Connections {
            function onTimeChanged() {
                var hours = wallClock.time.getHours();
                var minutes = wallClock.time.getMinutes();
                hourRotation.angle = (hours * 30) + (minutes * 0.5);
                minuteRotation.angle = (minutes * 6) + (wallClock.time.getSeconds() * 0.1);
            }

            target: wallClock
        }

        Timer {
            interval: 16
            repeat: true
            running: !displayAmbient && visible
            onTriggered: {
                var now = new Date();
                secondRotation.angle = (now.getSeconds() * 1000 + now.getMilliseconds()) * 6 / 1000;
            }
        }

    }

    Connections {
        function onDisplayAmbientEntered() {
            if (currentColor == "black") {
                currentColor = "";
                userColor = "black";
            } else {
                userColor = "";
            }
        }

        function onDisplayAmbientLeft() {
            if (userColor == "black")
                currentColor = "black";

        }

        target: compositor
    }

}
