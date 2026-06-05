// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2021 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2012 Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
// SPDX-FileCopyrightText: 2012 Aleksey Mikhailichenko <a.v.mich@gmail.com>
// SPDX-FileCopyrightText: 2012 Arto Jalkanen <ajalkane@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Nemo.Mce
import org.asteroid.utils

Item {
    property string imgPath: "../watchfaces-img/numerals-duo-synth-neon-green-"

    anchors.fill: parent

    Item {
        id: root

        anchors.centerIn: parent
        height: Math.min(parent.width, parent.height)
        width: height

        Text {
            id: dowDisplay

            visible: !displayAmbient
            renderType: Text.NativeRendering
            color: "white"
            opacity: 0.95
            horizontalAlignment: Text.AlignHCenter
            text: wallClock.time.toLocaleString(Qt.locale(), "dddd").toUpperCase()
            layer.enabled: true

            font {
                pixelSize: root.height * 0.054
                family: "Sunflower"
                weight: Font.Light
                letterSpacing: root.height * 0.003
            }

            anchors {
                bottom: root.verticalCenter
                bottomMargin: DeviceSpecs.hasRoundScreen ? root.height * 0.387 : root.height * 0.402
                horizontalCenter: root.horizontalCenter
            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 3
                radius: 12
                samples: 16
                color: "#fe16a2"
            }

        }

        Text {
            id: dateDisplay

            visible: !displayAmbient
            renderType: Text.NativeRendering
            color: "white"
            opacity: 0.95
            horizontalAlignment: Text.AlignHCenter
            text: wallClock.time.toLocaleString(Qt.locale(), "yyyy-MM-dd")
            layer.enabled: true

            font {
                pixelSize: root.height * 0.056
                family: "Sunflower"
                weight: Font.Light
            }

            anchors {
                top: root.verticalCenter
                topMargin: DeviceSpecs.hasRoundScreen ? root.height * 0.394 : root.height * 0.406
                horizontalCenter: root.horizontalCenter
            }

            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: -3
                radius: 12
                samples: 16
                color: "#fe16a2"
            }

        }

        Item {
            x: DeviceSpecs.hasRoundScreen ? root.height * 0.1 : (!displayAmbient ? root.height * 0.1 : 0)
            y: DeviceSpecs.hasRoundScreen ? root.height * 0.1 : (!displayAmbient ? root.height * 0.1 : 0)
            width: DeviceSpecs.hasRoundScreen ? root.height * 0.8 : (displayAmbient ? root.height : root.height * 0.8)
            height: DeviceSpecs.hasRoundScreen ? root.height * 0.8 : (displayAmbient ? root.height : root.height * 0.8)

            LinearGradient {
                id: greenColor

                anchors.fill: parent
                visible: false
                start: Qt.point(0, 0)
                end: Qt.point(300, 300)

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#38FF12"
                    }

                    GradientStop {
                        position: 1
                        color: "#00F5FB"
                    }

                }

            }

            LinearGradient {
                id: whiteColor

                anchors.fill: parent
                visible: false
                start: Qt.point(0, 0)
                end: Qt.point(300, 300)

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#FFF100"
                    }

                    GradientStop {
                        position: 1
                        color: "#FFFFFF"
                    }

                }

            }

            Image {
                id: topLeft

                visible: false
                fillMode: Image.PreserveAspectFit
                x: parseInt(parent.width * 0.135)
                y: parseInt(parent.height * 0.045)
                sourceSize: Qt.size(parent.width / 2 - parent.width * 0.15, parent.height / 2 - parent.height * 0.15)
                source: imgPath + wallClock.time.toLocaleString(Qt.locale(), "HH").slice(0, 1) + ".png"
            }

            Image {
                id: topRight

                visible: false
                fillMode: Image.PreserveAspectFit
                x: parseInt(parent.width / 2 + parent.width * 0.03)
                y: parseInt(parent.height * 0.045)
                sourceSize: Qt.size(parent.width / 2 - parent.width * 0.15, parent.height / 2 - parent.height * 0.15)
                source: imgPath + wallClock.time.toLocaleString(Qt.locale(), "HH").slice(1, 2) + ".png"
            }

            Image {
                id: bottomLeft

                visible: false
                fillMode: Image.PreserveAspectFit
                x: parseInt(parent.width * 0.135)
                y: parseInt(parent.height / 2 + parent.height * 0.025)
                sourceSize: Qt.size(parent.width / 2 - parent.width * 0.15, parent.height / 2 - parent.height * 0.15)
                source: imgPath + wallClock.time.toLocaleString(Qt.locale(), "mm").slice(0, 1) + ".png"
            }

            Image {
                id: bottomRight

                visible: false
                fillMode: Image.PreserveAspectFit
                x: parseInt(parent.width / 2 + parent.width * 0.03)
                y: parseInt(parent.height / 2 + parent.height * 0.025)
                sourceSize: Qt.size(parent.width / 2 - parent.width * 0.15, parent.height / 2 - parent.height * 0.15)
                source: imgPath + wallClock.time.toLocaleString(Qt.locale(), "mm").slice(1, 2) + ".png"
            }

            OpacityMask {
                invert: true
                anchors.fill: topLeft
                source: greenColor
                maskSource: topLeft
                layer.enabled: true

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1
                    verticalOffset: 1
                    radius: 12
                    samples: 20
                    color: "#f800ff"
                }

            }

            OpacityMask {
                invert: true
                anchors.fill: topRight
                source: greenColor
                maskSource: topRight
                layer.enabled: true

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: -1
                    verticalOffset: 1
                    radius: 12
                    samples: 20
                    color: "#f800ff"
                }

            }

            OpacityMask {
                invert: true
                anchors.fill: bottomLeft
                source: whiteColor
                maskSource: bottomLeft
                layer.enabled: true

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: -1
                    verticalOffset: -1
                    radius: 12
                    samples: 20
                    color: "#9600ff"
                }

            }

            OpacityMask {
                invert: true
                anchors.fill: bottomRight
                source: whiteColor
                maskSource: bottomRight
                layer.enabled: true

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1
                    verticalOffset: -1
                    radius: 12
                    samples: 20
                    color: "#9600ff"
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on height {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }

            }

        }

    }

}
