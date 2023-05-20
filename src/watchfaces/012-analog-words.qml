/*
 * Copyright (C) 2023 - Timo Könnecke <github.com/eLtMosen>
 *               2021 - Ed Beroset <github.com/beroset>
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
    property int hour: wallClock.time.toLocaleString(Qt.locale(), "h ap").slice(0, 2) === "12" ? 0 : wallClock.time.toLocaleString(Qt.locale(), "h ap").slice(0, 2)
    property var colorOffset: ["#ff0000", "#ff8000", "#ffff00", "#80ff00", "#00ff00", "#00ff80", "#00ffff", "#0080ff", "#0000ff", "#8000ff", "#ff00ff", "#ff0080"]
    property var wordsDE: ["zwölf", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht", "neun", "zehn", "elf"]
    property var wordsEN: ["twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven"]
    property var wordsFR: ["douze", "une", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf", "dix", "onze"]
    property var wordsES: ["doce", "una", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once"]
    property var wordsIT: ["dodici", "uno", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci", "undici"]
    property var wordsNL: ["twaalf", "één", "twee", "drie", "vier", "vijf", "zes", "zeven", "acht", "negen", "tien", "elf"]
    property var wordsGR: ["δώδεκα", "ένα", "δύο", "τρία", "τέσσερα", "πέντε", "έξι", "επτά", "οκτώ", "εννέα", "δέκα", "έντεκα"]
    property var wordsSV: ["tolv", "ett", "två", "tre", "fyra", "fem", "sex", "sju", "åtta", "nio", "tio", "elva"]
    property var wordsSK: ["dvanajst", "ena", "dve", "tri", "štiri", "pet", "šest", "sedem", "osem", "devet", "deset", "enajst"]
    property var wordsDA: ["tolv", "en", "et", "to", "tre", "fire", "fem", "seks", "syv", "otte", "ni", "ti", "elleve"]
    property var wordsPT: ["doze", "um", "dois", "três", "quatro", "cinco", "seis", "sete", "oito", "nove", "dez", "onze"]
    property var wordsTR: ["on iki", "bir", "iki", "üç", "dört", "beş", "altı", "yedi", "sekiz", "dokuz", "on", "onbir"]
    property var wordsNB: ["tolv", "en", "to", "tre", "fire", "fem", "seks", "syv", "åtte", "ni", "ti", "elleve"]

    Item {
        id: root

        height: parent.width > parent.height ? parent.height : parent.width
        width: height

        anchors.centerIn: parent

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
                property int segmentAmount: 50
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .02
                property real scalefactor: .48 - (arcStrokeWidth / 2)
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

        Rectangle {
            id: circleBack
            z: 2

            property var toggle: 1
            antialiasing : true
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            color: "white"
            width: parent.width * 0.3
            height: parent.height * 0.3
            radius: width * 0.5

            Text {
                id: minuteDisplay

                font.pixelSize: parent.height * 0.549
                font.family: "Montserrat"
                font.styleName: "Regular"
                color: "black"
                opacity: 1
                anchors.centerIn: parent
                text: wallClock.time.toLocaleString(Qt.locale(), "mm")
            }
        }

        Repeater {
            model: 12

            Rectangle {
                id: backRectangles
                z: hour == index ? 1 : 0

                antialiasing: true
                width: hourText.paintedWidth + (hourText.x * 1.21)
                height: parent.height * 0.138
                color: hour == index ? "white" : colorOffset[index]
                opacity: 1
                radius: width * 0.5
                transform: [
                    Rotation {
                        origin.x: backRectangles.height / 2;
                        origin.y: backRectangles.height / 2;
                        angle: ((index) * 30) - 90
                    },
                    Translate {
                        x: (parent.width - backRectangles.height) / 2
                        y: (parent.height - backRectangles.height) / 2
                    }
                ]
                state: currentColor
                states: State { name: "black";
                    PropertyChanges { target: backRectangles;
                        color: hour == index ? "white" : "black" }
                }
                transitions: Transition {
                    from: ""; to: "black"; reversible: true
                        ColorAnimation { duration: 500 }
                }

                Text {
                    id: hourText

                    property var heightFontOffest: (index > 0 && index < 7) ? -parent.height * 0.05 : parent.height * 0.05

                    font.pixelSize: parent.height * (hour == index ? 0.70 : 0.56)
                    font.family: "SourceSansPro"
                    font.styleName: hour == index ? "Semibold" : "Light"
                    font.letterSpacing: hour == index ? -parent.height * 0.02 : parent.height * 0.001
                    color: "black"
                    x: hour == index ? parent.height * 1.58 : parent.height * 1.94
                    y: ((parent.height - hourText.height) / 2) + heightFontOffest
                    text: Qt.locale().name.substring(0,2) === "de" ? wordsDE[index]:
                          Qt.locale().name.substring(0,2) === "fr" ? wordsFR[index]:
                          Qt.locale().name.substring(0,2) === "es" ? wordsES[index]:
                          Qt.locale().name.substring(0,2) === "it" ? wordsIT[index]:
                          Qt.locale().name.substring(0,2) === "nl" ? wordsNL[index]:
                          Qt.locale().name.substring(0,2) === "el" ? wordsGR[index]:
                          Qt.locale().name.substring(0,2) === "sv" ? wordsSV[index]:
                          Qt.locale().name.substring(0,2) === "sk" ? wordsSK[index]:
                          Qt.locale().name.substring(0,2) === "da" ? wordsDA[index]:
                          Qt.locale().name.substring(0,2) === "pt" ? wordsPT[index]:
                          Qt.locale().name.substring(0,2) === "tr" ? wordsTR[index]:
                          Qt.locale().name.substring(0,2) === "nb" ? wordsNB[index]:
                                                                     wordsEN[index]
                    transform: Rotation {
                        origin.x: hourText.width / 2;
                        origin.y: hourText.height / 2;
                        /* flip text for readability for hours 1 through 6 */
                        angle: (index > 0 && index < 7) ? 0 : 180
                    }
                    state: currentColor
                    states: State { name: "black";
                        PropertyChanges { target: hourText;
                            color: hour == index ? "black" : "white" }
                    }
                    transitions: Transition {
                        from: ""; to: "black"; reversible: true
                            ColorAnimation { duration: 500 }
                    }
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 12.0
                    samples: 17
                    color: "#50000000"
                }
            }
        }

        Connections {
            target: compositor

            function onDisplayAmbientEntered() {
                if (currentColor == "") {
                    currentColor = "black"
                    userColor = ""
                }
                else
                    userColor = "black"
            }

            function onDisplayAmbientLeft() {
                if (userColor == "") {
                    currentColor = ""
                }
            }
        }
    }
}
