// SPDX-FileCopyrightText: 2023 Timo Könnecke <github.com/moWerk>
// SPDX-FileCopyrightText: 2022 Darrel Griët <dgriet@gmail.com>
// SPDX-FileCopyrightText: 2022 Ed Beroset <github.com/beroset>
// SPDX-FileCopyrightText: 2021 Oliver Geneser <olivergeneser@gmail.com>
// SPDX-FileCopyrightText: 2016 Sylvia van Os <iamsylvie@openmailbox.org>
// SPDX-FileCopyrightText: 2015 Florent Revest <revestflo@gmail.com>
// SPDX-FileCopyrightText: 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import Nemo.Mce
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Shapes
import org.asteroid.controls

Item {
    anchors.fill: parent

    Item {
        id: root

        property string localeName: Qt.locale().name

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
                transparentBorder: true
                horizontalOffset: root.height * .01
                verticalOffset: root.height * .01
                radius: root.height * .014
                samples: 9
                color: "#60000000"
            }

            Text {
                id: timeDisplay

                function generateTimeEn(time) {
                    var minutesList = ["'o clock", "five<br>past", "ten<br>past", "quarter<br>past", "twenty", "twenty<br>five", "thirty", "thirty<br>five", "forty", "quarter<br>to", "ten to", "five to", "'o clock"]
                    var hoursList = ["<b>twelve</b>", "<b>one</b>", "<b>two</b>", "<b>three</b>", "<b>four</b>", "<b>five</b>", "<b>six</b>", "<b>seven</b>", "<b>eight</b>", "<b>nine</b>", "<b>ten</b>", "<b>eleven</b>"]
                    var minutesFirst = [false, true, true, true, false, false, false, false, false, true, true, true, false]
                    var nextHour = [false, false, false, false, false, false, false, false, false, true, true, true, true]
                    var minutes = Math.round(time.getMinutes() / 5)
                    var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12
                    var newline = "<br>"
                    if (minutesFirst[minutes]) {
                        var generatedString = minutesList[minutes] + newline + hoursList[hours]
                    } else {
                        var generatedString = hoursList[hours] + newline + minutesList[minutes]
                    }
                    return generatedString
                }

                function generateTimeEs(time) {
                    var minutesList = ["en punto", "cinco", "diez", "cuarto", "veinte", "veinticinco", "media", "veinticinco", "veinte", "cuarto", "diez", "cinco", "en punto"]
                    var hoursList = ["<b>doce</b>", "<b>una</b>", "<b>dos</b>", "<b>tres</b>", "<b>cuatro</b>", "<b>cinco</b>", "<b>seis</b>", "<b>siete</b>", "<b>ocho</b>", "<b>nueve</b>", "<b>diez</b>", "<b>once</b>"]
                    var hoursListy = ["<b>doce</b> y", "<b>una</b> y", "<b>dos</b> y", "<b>tres</b> y", "<b>cuatro</b> y", "<b>cinco</b> y", "<b>seis</b> y", "<b>siete</b> y", "<b>ocho</b> y", "<b>nueve</b> y", "<b>diez</b> y", "<b>once</b> y"]
                    var hoursListmenos = ["<b>doce</b><br>menos", "<b>una</b><br>menos", "<b>dos</b><br>menos", "<b>tres</b><br>menos", "<b>cuatro</b><br>menos", "<b>cinco</b><br>menos", "<b>seis</b><br>menos", "<b>siete</b><br>menos", "<b>ocho</b><br>menos", "<b>nueve</b><br>menos", "<b>diez</b><br>menos", "<b>once</b><br>menos"]
                    var nextHour = [false, false, false, false, false, false, false, true, true, true, true, true, true]
                    var enPunto = [true, false, false, false, false, false, false, false, false, false, false, false, true]
                    var minutes = Math.round(time.getMinutes() / 5)
                    var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12
                    var newline = "<br>"
                    if (enPunto[minutes]) {
                        var generatedString = hoursList[hours] + newline + minutesList[minutes]
                    } else {
                        if (nextHour[minutes]) {
                            var generatedString = hoursListmenos[hours] + newline + minutesList[minutes]
                        } else {
                            var generatedString = hoursListy[hours] + newline + minutesList[minutes]
                        }
                    }
                    return generatedString
                }

                function generateTimeDe(time) {
                    var nextHour = [false, false, false, false, false, true, true, true, true, true, true, true, true]
                    var minutes = Math.round(time.getMinutes() / 5)
                    var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12
                    var minutesList = ["uhr", "fünf<br>nach", "zehn<br>nach", "viertel<br>nach", "zwanzig<br>nach", "fünf<br>vor halb", "halb", "fünf<br>nach halb", "zwanzig<br>vor", "viertel<br>vor", "zehn<br>vor", "fünf<br>vor", "uhr"]
                    var hoursList = ["<b>zwölf</b>", minutesList[minutes] === "uhr" ? "<b>ein</b>" : "<b>eins</b>", "<b>zwei</b>", "<b>drei</b>", "<b>vier</b>", "<b>fünf</b>", "<b>sechs</b>", "<b>sieben</b>", "<b>acht</b>", "<b>neun</b>", "<b>zehn</b>", "<b>elf</b>"]
                    var minutesFirst = [false, true, true, true, true, true, true, true, true, true, true, true, false]
                    var newline = "<br>"
                    if (minutesFirst[minutes]) {
                        var generatedString = minutesList[minutes] + newline + hoursList[hours]
                    } else {
                        var generatedString = hoursList[hours] + newline + minutesList[minutes]
                    }
                    return generatedString
                }

                function generateTimeFr(time) {
                    var minutesList = ["heures<br>pile", "heures<br>cinq", "heures<br>dix", "heures<br>et quart", "heures<br>vingt", "heures<br>vingt-cinq", "heures<br>et demie", "heures<br>moins<br>vingt-cinq", "heures<br>moins<br>vingt", "heures<br>moins le<br>quart", "heures<br>moins<br>dix", "heures<br>moins<br>cinq", "pile"]
                    var hoursList = ["<b>douze</b>", "<b>une</b>", "<b>deux</b>", "<b>trois</b>", "<b>quatre</b>", "<b>cinq</b>", "<b>six</b>", "<b>sept</b>", "<b>huit</b>", "<b>neuf</b>", "<b>dix</b>", "<b>onze</b>"]
                    var minutesFirst = [false, false, false, false, false, false, false, false, false, false, false, false, false]
                    var nextHour = [false, false, false, false, false, false, false, true, true, true, true, true, true]
                    var minutes = Math.round(time.getMinutes() / 5)
                    var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12
                    var newline = "<br>"
                    if (minutesFirst[minutes]) {
                        var generatedString = minutesList[minutes] + newline + hoursList[hours]
                    } else {
                        var generatedString = hoursList[hours] + newline + minutesList[minutes]
                    }
                    return generatedString
                }

                function generateTimeDa(time) {
                    var minutesList = ["", "fem<br>over", "ti<br>over", "kvart<br>over", "tyve<br>over", "femog<br>tyve", "halv", "femog<br>tredive", "fyrre", "kvart I", "ti I", "fem I", ""]
                    var hoursList = ["<b>tolv</b>", "<b>et</b>", "<b>to</b>", "<b>tre</b>", "<b>fire</b>", "<b>fem</b>", "<b>seks</b>", "<b>syv</b>", "<b>otte</b>", "<b>ni</b>", "<b>ti</b>", "<b>elleve</b>"]
                    var minutesFirst = [false, true, true, true, true, false, true, false, false, true, true, true, false]
                    var nextHour = [false, false, false, false, false, false, true, false, false, true, true, true, false]
                    var minutes = Math.round(time.getMinutes() / 5)
                    var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12
                    var newline = "<br>"
                    if (minutesFirst[minutes]) {
                        var generatedString = minutesList[minutes] + newline + hoursList[hours]
                    } else {
                        var generatedString = hoursList[hours] + newline + minutesList[minutes]
                    }
                    return generatedString
                }

                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -parent.height * .029
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                lineHeight: .64
                color: "white"
                textFormat: Text.StyledText
                renderType: Text.NativeRendering
                font {
                    family: "SourceSansPro"
                    pixelSize: text.includes("veinticinco") || text.includes("moins") || text.includes("demie") || text.includes("vingt-cinq") ? parent.height * .185 : text.includes("nach halb") || text.includes("zwanzig") ? parent.height * .22 : parent.height * .24
                    weight: Font.Light
                }
                text: root.localeName.substring(0,2) === "de" ? generateTimeDe(wallClock.time) : root.localeName.substring(0,2) === "es" ? generateTimeEs(wallClock.time) : root.localeName.substring(0,2) === "fr" ? generateTimeFr(wallClock.time) : root.localeName.substring(0,2) === "da" ? generateTimeDa(wallClock.time) : generateTimeEn(wallClock.time)
            }

            Text {
                id: dateDisplay

                anchors {
                    topMargin: -parent.width * .019
                    top: timeDisplay.bottom
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignHCenter
                color: "white"
                textFormat: Text.StyledText
                renderType: Text.NativeRendering
                font.pixelSize: parent.height * .07
                text: wallClock.time.toLocaleString(Qt.locale(root.localeName), "<b>ddd</b> d MMM")
            }

            Item {
                id: batteryInfo

                anchors {
                    bottomMargin: parent.width * .05
                    bottom: timeDisplay.top
                    left: parent.left
                    right: parent.right
                }

                Icon {
                    id: batteryIcon

                    anchors {
                        right: parent.horizontalCenter
                        rightMargin: watchfaceRoot.height * .004
                    }
                    width: watchfaceRoot.width * .1
                    height: watchfaceRoot.height * .1
                    visible: nightstandMode.active
                    name: "ios-battery-charging"
                }

                Text {
                    id: batteryPercent

                    anchors {
                        left: parent.horizontalCenter
                        leftMargin: watchfaceRoot.height * .004
                    }
                    visible: nightstandMode.active
                    color: "white"
                    style: Text.Outline
                    styleColor: "#80000000"
                    renderType: Text.NativeRendering
                    font {
                        family: "Roboto"
                        pixelSize: watchfaceRoot.width * .07
                        styleName: "Regular"
                    }
                    text: batteryChargePercentage.percent + "%"
                }
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
                property int segmentAmount: 10
                property int start: 0
                property int gap: 6
                property int endFromStart: 360
                property bool clockwise: true
                property real arcStrokeWidth: .024
                property real scalefactor: .45 - (arcStrokeWidth / 2)
                property int chargecolor: Math.floor(batteryChargePercentage.percent / 33.35) | 0
                readonly property var colorArray: ["red", "yellow", Qt.rgba(.318, 1, .051, .9)]

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

        MceBatteryLevel {
            id: batteryChargePercentage
        }

        Connections {
            function onChangesObserverChanged() {
                root.localeName = Qt.locale().name
            }
            target: localeManager
        }

        Component.onCompleted: {
            burnInProtectionManager.widthOffset = Qt.binding(function() { return root.width * (nightstandMode.active ? .08 : .2) })
            burnInProtectionManager.heightOffset = Qt.binding(function() { return root.height * (nightstandMode.active ? .08 : .2) })
        }
    }
}
