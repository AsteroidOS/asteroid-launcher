// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
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

    property string imgPath: "../watchfaces-img/analog-scientific-v2-"

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Item {
        id: root

        anchors.centerIn: parent

        height: Math.min(parent.width, parent.height)
        width: height

        Item {
            id: dialBox

            anchors.fill: root

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.width * .005
                verticalOffset: root.width * .005
                radius: root.width * .013
                samples: 9
                color: "#99000000"
            }

            Repeater {
                model: 60

                Rectangle {
                    id: minuteStrokes

                    property real rotM: (index - 15) / 60
                    property real centerX: root.width / 2 - width / 2
                    property real centerY: root.height / 2 - height / 2

                    x: index % 5 ? centerX+Math.cos(rotM * 2 * Math.PI) * parent.width * .488 :
                                   centerX+Math.cos(rotM * 2 * Math.PI) * parent.width * .480
                    y: index % 5 ? centerY+Math.sin(rotM * 2 * Math.PI) * parent.width * .488 :
                                   centerY+Math.sin(rotM * 2 * Math.PI) * parent.width * .480
                    antialiasing : true
                    color: index % 5 ? "#77ffffff" : "#ffffffff"
                    width: index % 5 ? parent.width * .0066 : parent.width * .009
                    height: index % 5 ? parent.height * .026 : parent.height * .038
                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: (index) * 6
                    }
                }
            }

            Repeater {
                model: 12

                Text {
                    id: hourNumbers

                    property real rotM: ((index * 5 ) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    x: index === 10 ?
                           centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .378 :
                           index === 11 ?
                               centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .388 :
                               centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .4
                    y: index === 10 ?
                           centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .378 :
                           index === 11 ?
                               centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .388 :
                               centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .4
                    font {
                        pixelSize: parent.height * .088
                        family: "Outfit"
                    }
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignHCenter
                    color: "#ffffffff"
                    text: index === 0 ? "12" : index
                }
            }

            Image {
                id: asteroidLogo

                visible: !displayAmbient
                source: "../watchfaces-img/asteroid-logo.svg"
                antialiasing: true
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * .272
                }
                width: parent.width * .12
                height: parent.height * .12
                opacity: .7

                Text {
                    id: asteroidSlogan

                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -parent.height * .005
                    }
                    font {
                        pixelSize: parent.height * .31
                        family: "Raleway"
                    }
                    renderType: Text.NativeRendering
                    visible: !displayAmbient
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.StyledText
                    text: "<b>AsteroidOS</b><br>Free Your Wrist"
                }
                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: asteroidLogo.visible ?
                                        asteroidLogo.visible = false :
                                        asteroidLogo.visible = true
                }
            }

            Text {
                id: digitalDisplay

                anchors {
                    right: parent.horizontalCenter
                    rightMargin: parent.width * .004
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -parent.width * .124
                }
                font {
                    pixelSize: parent.height * .15
                    family: "Open Sans"
                    letterSpacing: -parent.width * .001
                }
                renderType: Text.NativeRendering
                color: "#bbffffff"
                text: if (use12H.value) {
                          wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2)}
                      else
                          wallClock.time.toLocaleString(Qt.locale(), "HH")
            }

            Text {
                id: digitalMinutes

                anchors {
                    left: digitalDisplay.right
                    bottom: digitalDisplay.bottom
                    leftMargin: root.width * .004
                }
                font {
                    pixelSize: root.height * .15
                    family: "Open Sans"
                    weight: Font.Light
                    letterSpacing: -parent.width * .001
                }
                renderType: Text.NativeRendering
                color: "#ccffffff"
                text: wallClock.time.toLocaleString(Qt.locale(), "mm")
            }

            Text {
                id: apDisplay

                anchors {
                    left: digitalMinutes.right
                    leftMargin: parent.width * .014
                    bottom: digitalMinutes.verticalCenter
                    bottomMargin: -parent.width * .012
                }
                font {
                    pixelSize: root.height * .06
                    family: "Open Sans Condensed"
                }
                renderType: Text.NativeRendering
                visible: use12H.value
                color: "#ddffffff"
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
            }

            Item {
                id: dayBox

                property int currentDayOfWeek: wallClock.time.getDay()

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .06
                    horizontalCenterOffset: -parent.width * .23
                }
                width: parent.width * .22
                height: parent.height * .22

                Rectangle {
                    id: dayArc

                    anchors.centerIn: parent
                    width: parent.width * .9
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    opacity: !displayAmbient ? 1 : .3

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: root.height * .002
                        border.color: "#77ffffff"
                    }
                }

                Shape {
                    anchors.fill: parent
                    opacity: !displayAmbient ? 1 : .3

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: "#ff98E2C6"
                        strokeWidth: root.height * .005
                        capStyle: ShapePath.RoundCap
                        startX: dayBox.width / 2
                        startY: dayBox.height * (.5 - .456)

                        PathAngleArc {
                            centerX: dayBox.width / 2
                            centerY: dayBox.height / 2
                            radiusX: dayBox.width * .456
                            radiusY: dayBox.height * .456
                            startAngle: 169
                            sweepAngle: dayBox.currentDayOfWeek / 7 * 360
                            moveToStart: true
                        }
                    }
                }

                Repeater {
                    model: 7
                    visible: !displayAmbient

                    Text {
                        id: dayStrokes

                        property bool currentDayHighlight: new Date(2017, 1, index).toLocaleString(Qt.locale(), "ddd") === wallClock.time.toLocaleString(Qt.locale(), "ddd")
                        property real rotM: ((index * 8.7) -15) / 60
                        property real centerX: parent.width / 2 - width / 2
                        property real centerY: parent.height / 2 - height / 2

                        x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .35
                        y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .35
                        antialiasing: true
                        opacity: !displayAmbient ? 1 : .6
                        color: currentDayHighlight ?
                                   "#ffffffff" :
                                   "#88ffffff"
                        font {
                            pixelSize: currentDayHighlight ? root.height * .036 : root.height * .03
                            letterSpacing: parent.width * .004
                            family: "Outfit"
                            weight: currentDayHighlight ? Font.Bold : Font.Normal
                        }
                        renderType: Text.NativeRendering
                        text: new Date(2017, 1, index).toLocaleString(Qt.locale(), "ddd").slice(0, 2).toUpperCase()
                        transform: Rotation {
                            origin.x: width / 2
                            origin.y: height / 2
                            angle: index * 52
                        }
                    }
                }

                Text {
                    id: dayDisplay

                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -root.width * .003
                    }
                    font {
                        pixelSize: parent.height * .39
                        family: "Noto Sans"
                        styleName: "Condensed Light"
                    }
                    renderType: Text.NativeRendering
                    color: "#ffffffff"
                    text: wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()
                }
            }

            Item {
                id: monthBox

                property int currentMonth: wallClock.time.getMonth() + 1

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .06
                    horizontalCenterOffset: parent.width * .23
                }
                width: parent.width * .22
                height: parent.height * .22

                Rectangle {
                    id: monthArc

                    anchors.centerIn: parent
                    width: parent.width * .9
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    opacity: !displayAmbient ? 1 : .3

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: root.height * .002
                        border.color: "#77ffffff"
                    }
                }

                Shape {
                    anchors.fill: parent
                    opacity: !displayAmbient ? 1 : .3

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: "#ff98E2C6"
                        strokeWidth: root.height * .005
                        capStyle: ShapePath.RoundCap
                        startX: monthBox.width / 2
                        startY: monthBox.height * (.5 - .456)

                        PathAngleArc {
                            centerX: monthBox.width / 2
                            centerY: monthBox.height / 2
                            radiusX: monthBox.width * .456
                            radiusY: monthBox.height * .456
                            startAngle: -90
                            sweepAngle: monthBox.currentMonth / 12 * 360
                            moveToStart: false
                        }
                    }
                }

                Repeater {
                    model: 12

                    Text {
                        id: monthStrokes

                        property bool currentMonthHighlight: Number(wallClock.time.toLocaleString(Qt.locale(), "MM")) === index ||
                                                             Number(wallClock.time.toLocaleString(Qt.locale(), "MM")) === index + 12
                        property real rotM: ((index * 5) - 15) / 60
                        property real centerX: parent.width / 2 - width / 2
                        property real centerY: parent.height / 2 - height / 2

                        x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .35
                        y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .35
                        antialiasing: true
                        opacity: !displayAmbient ? 1 : .6
                        font {
                            pixelSize: currentMonthHighlight ? root.height * .036 : root.height * .03
                            letterSpacing: parent.width * .004
                            family: "Outfit"
                            weight: currentMonthHighlight ? Font.Bold : Font.Normal
                        }
                        renderType: Text.NativeRendering
                        color:  currentMonthHighlight ?
                                    "#ffffffff" :
                                    "#88ffffff"
                        text: index === 0 ? 12 : index
                        transform: Rotation {
                            origin.x: width / 2
                            origin.y: height / 2
                            angle: (index * 30)
                        }
                    }
                }

                Text {
                    id: monthDisplay

                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font {
                        pixelSize: parent.height * .366
                        family: "Noto Sans"
                        styleName: "Condensed Light"
                        letterSpacing: -root.width * .0018
                    }
                    color: "#ddffffff"
                    text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase()
                }
            }

            Item {
                id: batteryBox

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .206
                }
                width: parent.width * .26
                height: parent.height * .26

                Rectangle {
                    id: batteryArc

                    anchors.centerIn: parent
                    width: parent.width * .9
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    opacity: !displayAmbient ? 1 : .3

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: root.height * .002
                        border.color: "#77ffffff"
                    }
                }

                Shape {
                    anchors.fill: parent
                    opacity: !displayAmbient ? 1 : .3

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: batteryChargePercentage.percent < 30 ? "#EF476F" :
                                     batteryChargePercentage.percent < 60 ? "#D0E562" : "#23F0C7"
                        strokeWidth: root.height * .005
                        capStyle: ShapePath.RoundCap
                        startX: batteryBox.width / 2
                        startY: batteryBox.height * (.5 - .456)

                        PathAngleArc {
                            centerX: batteryBox.width / 2
                            centerY: batteryBox.height / 2
                            radiusX: batteryBox.width * .456
                            radiusY: batteryBox.height * .456
                            startAngle: -90
                            sweepAngle: batteryChargePercentage.percent / 100 * 360
                            moveToStart: false
                        }
                    }
                }

                Text {
                    id: batteryDisplay

                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    font {
                        pixelSize: parent.height * (batteryDisplay.text === "100" ? 0.46 : .48)
                        family: "Outfit"
                        weight: Font.Thin
                    }
                    color: "#ffffffff"
                    text: batteryChargePercentage.percent

                    Text {
                         id: batteryPercent

                         anchors {
                             centerIn: batteryDisplay
                             verticalCenterOffset: parent.height*.34
                         }
                         font {
                             pixelSize: parent.height * .194
                             family: "Open Sans"
                         }
                         renderType: Text.NativeRendering
                         horizontalAlignment: Text.AlignHCenter
                         lineHeightMode: Text.FixedHeight
                         lineHeight: parent.height * .94
                         color: !displayAmbient ?
                                    "#bbffffff" :
                                    "#55ffffff"
                         text: "BAT<br>%"
                     }
                }
            }
        }

        Item {
            id: handBox

            anchors.fill: root

            Image {
                id: hourSVG

                anchors.centerIn: handBox
                source: imgPath + (displayAmbient ? "hour-bw.svg" : "hour.svg")
                width: handBox.width
                height: handBox.height
                transform: Rotation {
                    id: hourRotation

                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                    angle: 0
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: root.width * .01
                    verticalOffset: root.width * .01
                    radius: root.width * .018
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .2)
                }
            }

            Image {
                id: minuteSVG

                anchors.centerIn: handBox
                source: imgPath + (displayAmbient ? "minute-bw.svg" : "minute.svg")
                width: handBox.width
                height: handBox.height
                transform: Rotation {
                    id: minuteRotation

                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                    angle: 0
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: root.width * .012
                    verticalOffset: root.width * .012
                    radius: root.width * .022
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .2)
                }
            }

            Image {
                id: secondSVG

                anchors.centerIn: handBox
                source: imgPath + "second.svg"
                visible: !displayAmbient
                width: handBox.width
                height: handBox.height
                transform: Rotation {
                    id: secondRotation

                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                    angle: 0
                }
            }
            
            Connections {
                function onTimeChanged() {
                    var hours = wallClock.time.getHours()
                    var minutes = wallClock.time.getMinutes()
                    hourRotation.angle = use12H.value ?
                        (hours % 12 * 30) + (minutes * .5) :
                        (hours * 15) + (minutes * .25)
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
                hourRotation.angle = use12H.value ?
                    (hours % 12 * 30) + (minutes * .5) :
                    (hours * 15) + (minutes * .25)
                minuteRotation.angle = (minutes * 6) + (wallClock.time.getSeconds() * .1)
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
                property int segmentAmount: 60
                property int start: -10
                property int gap: 4
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .016
                property real scalefactor: .50 - (arcStrokeWidth / 2)
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
    }
}
