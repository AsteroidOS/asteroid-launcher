// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/eLtMosen>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {
    anchors.fill: parent

    property string imgPath: "../watchfaces-img/analog-scientific-v2-"
    // rad kept for batteryArc canvas which uses radial gradient — not convertible to PathAngleArc
    property real rad: .01745
    property int currentMonth: 0
    property string currentDayName: ""

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    Item {
        id: root

        anchors.centerIn: parent
        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        Item {
            id: dialBox

            anchors.fill: root

            layer.enabled: true
            layer.samples: 2
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 2
                radius: 5.0
                samples: 9
                color: "#99000000"
            }

            Repeater {
                model: 60
                Rectangle {
                    property real rotM: (index - 15) / 60
                    property real centerX: root.width / 2 - width / 2
                    property real centerY: root.height / 2 - height / 2

                    x: index % 5 ? centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .488 :
                                   centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .480
                    y: index % 5 ? centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .488 :
                                   centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .480
                    antialiasing: true
                    color: index % 5 ? "#77ffffff" : "#ffffffff"
                    width: index % 5 ? parent.width * .0066 : parent.width * .009
                    height: index % 5 ? parent.height * .026 : parent.height * .038

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        angle: index * 6
                    }
                }
            }

            Repeater {
                model: 12
                Text {
                    property real rotM: ((index * 5) - 15) / 60
                    property real centerX: parent.width / 2 - width / 2
                    property real centerY: parent.height / 2 - height / 2

                    x: index === 10 ? centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .378 :
                       index === 11 ? centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .388 :
                                      centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .4
                    y: index === 10 ? centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .378 :
                       index === 11 ? centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .388 :
                                      centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .4
                    horizontalAlignment: Text.AlignHCenter
                    color: "#ffffffff"
                    font {
                        pixelSize: parent.height * .088
                        family: "Outfit"
                        styleName: "Regular"
                    }
                    text: index === 0 ? "12" : index
                }
            }

            Image {
                id: asteroidLogo

                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * .272
                }
                visible: !displayAmbient
                antialiasing: true
                opacity: .7
                width: parent.width * .12
                height: parent.height * .12
                source: "../watchfaces-img/asteroid-logo.svg"

                Text {
                    id: asteroidSlogan

                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -parent.height * .005
                    }
                    visible: !displayAmbient
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: parent.height * .31
                        family: "Raleway"
                    }
                    text: "<b>AsteroidOS</b><br>Free Your Wrist"
                }

                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: asteroidLogo.visible = !asteroidLogo.visible
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
                color: "#bbffffff"
                font {
                    pixelSize: parent.height * .15
                    family: "Open Sans"
                    styleName: "Regular"
                    letterSpacing: -parent.width * .001
                }
                text: use12H.value ? wallClock.time.toLocaleString(Qt.locale(), "hh ap").slice(0, 2) :
                                     wallClock.time.toLocaleString(Qt.locale(), "HH")
            }

            Text {
                id: digitalMinutes

                anchors {
                    left: digitalDisplay.right
                    bottom: digitalDisplay.bottom
                    leftMargin: root.width * .004
                }
                color: "#ccffffff"
                font {
                    pixelSize: root.height * .15
                    family: "Open Sans"
                    styleName: "Light"
                    letterSpacing: -parent.width * .001
                }
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
                visible: use12H.value
                color: "#ddffffff"
                font {
                    pixelSize: root.height * .06
                    family: "Open Sans Condensed"
                    styleName: "Regular"
                }
                text: wallClock.time.toLocaleString(Qt.locale(), "ap").toUpperCase()
            }

            Item {
                id: dayBox

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .06
                    horizontalCenterOffset: -parent.width * .23
                }
                width: parent.width * .22
                height: parent.height * .22

                // Static background circle — fill + inner border ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    border.color: "#77ffffff"
                    border.width: root.height * .002
                    opacity: !displayAmbient ? 1 : .3
                }

                // Day of week progress arc — declarative binding updates automatically
                Shape {
                    anchors.fill: parent
                    opacity: !displayAmbient ? 1 : .3

                    ShapePath {
                        strokeColor: "#ff98E2C6"
                        strokeWidth: root.height * .005
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: dayBox.width / 2
                            centerY: dayBox.height / 2
                            radiusX: dayBox.width * .456
                            radiusY: dayBox.height * .456
                            startAngle: 169
                            sweepAngle: wallClock.time.getDay() / 7 * 360
                        }
                    }
                }

                Repeater {
                    model: 7
                    visible: !displayAmbient

                    Text {
                        // static Date objects for locale day name lookup — only re-evaluates when currentDayName changes
                        property bool currentDayHighlight: new Date(2017, 1, index).toLocaleString(Qt.locale(), "ddd") === currentDayName
                        property real rotM: ((index * 8.7) - 15) / 60
                        property real centerX: parent.width / 2 - width / 2
                        property real centerY: parent.height / 2 - height / 2

                        x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .35
                        y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .35
                        antialiasing: true
                        opacity: !displayAmbient ? 1 : .6
                        color: currentDayHighlight ? "#ffffffff" : "#88ffffff"
                        font {
                            pixelSize: currentDayHighlight ? root.height * .036 : root.height * .03
                            letterSpacing: parent.width * .004
                            family: "Outfit"
                            styleName: currentDayHighlight ? "Bold" : "Regular"
                        }
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
                    color: "#ffffffff"
                    font {
                        pixelSize: parent.height * .39
                        family: "Noto Sans"
                        styleName: "Condensed Light"
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "dd").slice(0, 2).toUpperCase()
                }
            }

            Item {
                id: monthBox

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .06
                    horizontalCenterOffset: parent.width * .23
                }
                width: parent.width * .22
                height: parent.height * .22

                // Static background circle — fill + inner border ring
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: width
                    radius: width / 2
                    color: "#22ffffff"
                    border.color: "#77ffffff"
                    border.width: root.height * .002
                    opacity: !displayAmbient ? 1 : .3
                }

                // Month progress arc — sweepAngle binding from lifted root.currentMonth property
                Shape {
                    anchors.fill: parent
                    opacity: !displayAmbient ? 1 : .3

                    ShapePath {
                        strokeColor: "#ff98E2C6"
                        strokeWidth: root.height * .005
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: monthBox.width / 2
                            centerY: monthBox.height / 2
                            radiusX: monthBox.width * .456
                            radiusY: monthBox.height * .456
                            startAngle: -90
                            sweepAngle: currentMonth / 12 * 360
                        }
                    }
                }

                Repeater {
                    model: 12

                    Text {
                        // currentMonth compared against index — evaluates only when currentMonth changes
                        property bool currentMonthHighlight: currentMonth === index || currentMonth === index + 12
                        property real rotM: ((index * 5) - 15) / 60
                        property real centerX: parent.width / 2 - width / 2
                        property real centerY: parent.height / 2 - height / 2

                        x: centerX + Math.cos(rotM * 2 * Math.PI) * parent.width * .35
                        y: centerY + Math.sin(rotM * 2 * Math.PI) * parent.width * .35
                        antialiasing: true
                        opacity: !displayAmbient ? 1 : .6
                        color: currentMonthHighlight ? "#ffffffff" : "#88ffffff"
                        font {
                            pixelSize: currentMonthHighlight ? root.height * .036 : root.height * .03
                            letterSpacing: parent.width * .004
                            family: "Outfit"
                            styleName: currentMonthHighlight ? "Bold" : "Regular"
                        }
                        text: index === 0 ? 12 : index

                        transform: Rotation {
                            origin.x: width / 2
                            origin.y: height / 2
                            angle: index * 30
                        }
                    }
                }

                Text {
                    id: monthDisplay

                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    color: "#ddffffff"
                    font {
                        pixelSize: parent.height * .366
                        family: "Noto Sans"
                        styleName: "Condensed Light"
                        letterSpacing: -root.width * .0018
                    }
                    text: wallClock.time.toLocaleString(Qt.locale(), "MMM").slice(0, 3).toUpperCase()
                }
            }

            Item {
                id: batteryBox

                property int value: batteryChargePercentage.percent

                anchors {
                    centerIn: parent
                    verticalCenterOffset: parent.width * .206
                }
                width: parent.width * .26
                height: parent.height * .26

                onValueChanged: batteryArc.requestPaint()

                Canvas {
                    id: batteryArc

                    // radial gradient battery arc — kept as Canvas since QtShapes has no radial gradient support
                    anchors.fill: parent
                    renderStrategy: Canvas.Cooperative
                    opacity: !displayAmbient ? 1 : .3

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.beginPath()
                        ctx.fillStyle = "#22ffffff"
                        ctx.arc(parent.width / 2,
                                parent.height / 2,
                                parent.width * .45,
                                270 * rad,
                                360,
                                false)
                        ctx.strokeStyle = "#77ffffff"
                        ctx.lineWidth = root.height * .002
                        ctx.stroke()
                        ctx.fill()
                        ctx.closePath()
                        var gradient = ctx.createRadialGradient(parent.width / 2,
                                                                parent.height / 2,
                                                                0,
                                                                parent.width / 2,
                                                                parent.height / 2,
                                                                parent.width * .46)
                        gradient.addColorStop(.44,
                                              batteryChargePercentage.percent < 30 ?
                                              "#00EF476F" :
                                              batteryChargePercentage.percent < 60 ?
                                              "#00D0E562" :
                                              "#0023F0C7")
                        gradient.addColorStop(.97,
                                              batteryChargePercentage.percent < 30 ?
                                              "#ffEF476F" :
                                              batteryChargePercentage.percent < 60 ?
                                              "#ffD0E562" :
                                              "#ff23F0C7")
                        ctx.lineWidth = root.height * .005
                        ctx.lineCap = "round"
                        ctx.strokeStyle = gradient
                        ctx.beginPath()
                        ctx.arc(parent.width / 2,
                                parent.height / 2,
                                parent.width * .456,
                                270 * rad,
                                ((batteryChargePercentage.percent / 100 * 360) + 270) * rad,
                                false)
                        ctx.lineTo(parent.width / 2,
                                   parent.height / 2)
                        ctx.stroke()
                        ctx.closePath()
                    }
                }

                Text {
                    id: batteryDisplay

                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    color: "#ffffffff"
                    font {
                        pixelSize: parent.height * (batteryDisplay.text === "100" ? 0.46 : .48)
                        family: "Outfit"
                        styleName: "Thin"
                    }
                    text: batteryChargePercentage.percent

                    Text {
                        id: batteryPercent

                        anchors {
                            centerIn: batteryDisplay
                            verticalCenterOffset: parent.height * .34
                        }
                        renderType: Text.NativeRendering
                        horizontalAlignment: Text.AlignHCenter
                        lineHeightMode: Text.FixedHeight
                        lineHeight: parent.height * .94
                        color: !displayAmbient ? "#bbffffff" : "#55ffffff"
                        font {
                            pixelSize: parent.height * .194
                            family: "Open Sans"
                            styleName: "Regular"
                        }
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

                property bool toggle24h: false

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                antialiasing: true
                source: imgPath + (displayAmbient ? "hour-bw.svg" : "hour.svg")

                transform: Rotation {
                    id: hourRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.enabled: true
                layer.samples: 2
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 4
                    verticalOffset: 4
                    radius: 7.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .2)
                }
            }

            Image {
                id: minuteSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                antialiasing: true
                source: imgPath + (displayAmbient ? "minute-bw.svg" : "minute.svg")

                transform: Rotation {
                    id: minuteRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }

                layer.enabled: true
                layer.samples: 2
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 5
                    verticalOffset: 5
                    radius: 9.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, .2)
                }
            }

            // second hand has no layer — continuous 60fps rotation would force constant recomposite
            Image {
                id: secondSVG

                anchors.centerIn: handBox
                width: handBox.width
                height: handBox.height
                antialiasing: true
                visible: !displayAmbient
                source: imgPath + "second.svg"

                transform: Rotation {
                    id: secondRot
                    origin.x: handBox.width / 2
                    origin.y: handBox.height / 2
                }
            }
        }

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
                property int segmentAmount: 60
                property int start: -10
                property int gap: 4
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .016
                property real scalefactor: .50 - (arcStrokeWidth / 2)
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
                hourRot.angle = hourSVG.toggle24h ? h * 15 + min * .25 : h * 30 + min * .5
                minuteRot.angle = min * 6 + sec * 6 / 60
                currentMonth = Number(wallClock.time.toLocaleString(Qt.locale(), "MM"))
                currentDayName = wallClock.time.toLocaleString(Qt.locale(), "ddd")
            }
        }

        Component.onCompleted: {
            var h = wallClock.time.getHours()
            var min = wallClock.time.getMinutes()
            var sec = wallClock.time.getSeconds()
            hourRot.angle = hourSVG.toggle24h ? h * 15 + min * .25 : h * 30 + min * .5
            minuteRot.angle = min * 6 + sec * 6 / 60
            currentMonth = Number(wallClock.time.toLocaleString(Qt.locale(), "MM"))
            currentDayName = wallClock.time.toLocaleString(Qt.locale(), "ddd")
        }
    }
}
