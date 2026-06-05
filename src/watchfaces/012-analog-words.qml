// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2021 Ed Beroset <github.com/beroset>
// SPDX-License-Identifier: LGPL-2.1-or-later

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes

Item {
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

    anchors.fill: parent

    Item {
        id: root

        height: Math.min(parent.width, parent.height)
        width: height
        anchors.centerIn: parent

        Item {
            id: nightstandMode

            readonly property bool active: nightstand

            anchors.fill: parent
            visible: nightstandMode.active

            Repeater {
                id: segmentedArc

                property real inputValue: batteryChargePercentage.percent / 100
                property int segmentAmount: 50
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: 0.02
                property real scalefactor: 0.48 - (arcStrokeWidth / 2)
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
                        capStyle: ShapePath.FlatCap
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

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Rectangle {
            id: circleBack

            property var toggle: 1

            // z: 2 retained — must always paint above backRectangles delegates whose z is dynamic (hour == index ? 1 : 0)
            z: 2
            antialiasing: true
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
                renderType: Text.NativeRendering
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
                state: currentColor
                layer.enabled: true
                transform: [
                    Rotation {
                        origin.x: backRectangles.height / 2
                        origin.y: backRectangles.height / 2
                        angle: ((index) * 30) - 90
                    },
                    Translate {
                        x: (parent.width - backRectangles.height) / 2
                        y: (parent.height - backRectangles.height) / 2
                    }
                ]

                Text {
                    id: hourText

                    property var heightFontOffest: (index > 0 && index < 7) ? -parent.height * 0.05 : parent.height * 0.05

                    font.pixelSize: parent.height * (hour == index ? 0.7 : 0.56)
                    font.family: "SourceSansPro"
                    font.weight: hour == index ? Font.DemiBold : Font.Light
                    font.letterSpacing: hour == index ? -parent.height * 0.02 : parent.height * 0.001
                    renderType: Text.NativeRendering
                    color: "black"
                    x: hour == index ? parent.height * 1.58 : parent.height * 1.94
                    y: ((parent.height - hourText.height) / 2) + heightFontOffest
                    text: Qt.locale().name.substring(0, 2) === "de" ? wordsDE[index] : Qt.locale().name.substring(0, 2) === "fr" ? wordsFR[index] : Qt.locale().name.substring(0, 2) === "es" ? wordsES[index] : Qt.locale().name.substring(0, 2) === "it" ? wordsIT[index] : Qt.locale().name.substring(0, 2) === "nl" ? wordsNL[index] : Qt.locale().name.substring(0, 2) === "el" ? wordsGR[index] : Qt.locale().name.substring(0, 2) === "sv" ? wordsSV[index] : Qt.locale().name.substring(0, 2) === "sk" ? wordsSK[index] : Qt.locale().name.substring(0, 2) === "da" ? wordsDA[index] : Qt.locale().name.substring(0, 2) === "pt" ? wordsPT[index] : Qt.locale().name.substring(0, 2) === "tr" ? wordsTR[index] : Qt.locale().name.substring(0, 2) === "nb" ? wordsNB[index] : wordsEN[index]
                    state: currentColor

                    transform: Rotation {
                        origin.x: hourText.width / 2
                        origin.y: hourText.height / 2
                        // flip text for readability for hours 1 through 6
                        angle: (index > 0 && index < 7) ? 0 : 180
                    }

                    states: State {
                        name: "black"

                        PropertyChanges {
                            target: hourText
                            color: hour == index ? "black" : "white"
                        }

                    }

                    transitions: Transition {
                        from: ""
                        to: "black"
                        reversible: true

                        ColorAnimation {
                            duration: 500
                        }

                    }

                }

                states: State {
                    name: "black"

                    PropertyChanges {
                        target: backRectangles
                        color: hour == index ? "white" : "black"
                    }

                }

                transitions: Transition {
                    from: ""
                    to: "black"
                    reversible: true

                    ColorAnimation {
                        duration: 500
                    }

                }

                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 12
                    samples: 17
                    color: "#50000000"
                }

            }

        }

        Connections {
            function onDisplayAmbientEntered() {
                if (currentColor == "") {
                    currentColor = "black";
                    userColor = "";
                } else {
                    userColor = "black";
                }
            }

            function onDisplayAmbientLeft() {
                if (userColor == "")
                    currentColor = "";

            }

            target: compositor
        }

    }

}
