/*
 * Copyright (C) 2018 - Timo Könnecke <el-t-mo@arcor.de>
 *               2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *               2014 - Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.1

Item {
    id: rootitem

    Text {
        function generateTimeEn(time) {
            var minutesList = ["'o clock", "<b>five</b><br>past", "<b>ten</b><br>past", "<b>quarter</b><br>past", "<b>twenty</b>", "twenty-five", "<b>thirty</b>", "thirty-five", "<b>fourty</b>", "<b>quarter</b><br>to", "<b>ten</b><br>to", "<b>five</b><br>to", "'o clock"]
            var hoursList = ["<b>twelve</b>", "<b>one</b>", "<b>two</b>", "<b>three</b>", "<b>four</b>", "<b>five</b>", "<b>six</b>", "<b>seven</b>", "<b>eight</b>", "<b>nine</b>", "<b>ten</b>", "<b>eleven</b>"]
            var minutesFirst = [false, true, true, true, false, false, false, false, false, true, true, true, false]
            var nextHour = [false, false, false, false, false, false, false, false, false, true, true, true, true]

            var minutes = Math.round(time.getMinutes()/5)
            var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12

            var start = "<p style=\"text-align:center\">"
            var newline = "<br>"
            var end = "</p>"

            if (minutesFirst[minutes]) {
                var generatedString = minutesList[minutes].toUpperCase() + newline + hoursList[hours].toUpperCase()
            } else {
                var generatedString = hoursList[hours].toUpperCase() + newline + minutesList[minutes].toUpperCase()
            }

            return start + generatedString + end
        }

        function generateTimeEs(time) {
            var minutesList = ["en punto", "<b>cinco</b>", "<b>diez</b>", "<b>cuarto</b>", "<b>veinte</b>", "veinticinco", "<b>media</b>", "veinticinco", "<b>veinte</b>", "<b>cuarto</b>", "<b>diez</b>", "<b>cinco</b>", "en punto"]
            var hoursList = ["<b>doce</b>", "<b>una</b>", "<b>dos</b>", "<b>tres</b>", "<b>cuatro</b>", "<b>cinco</b>", "<b>seis</b>", "<b>siete</b>", "<b>ocho</b>", "<b>nueve</b>", "<b>diez</b>", "<b>once</b>"]
            var hoursListy = ["<b>doce</b> y", "<b>una</b> y", "<b>dos</b> y", "<b>tres</b> y", "<b>cuatro</b> y", "<b>cinco</b> y", "<b>seis</b> y", "<b>siete</b> y", "<b>ocho</b> y", "<b>nueve</b> y", "<b>diez</b> y", "<b>once</b> y"]
            var hoursListmenos = ["<b>doce</b><br>menos", "<b>una</b><br>menos", "<b>dos</b><br>menos", "<b>tres</b><br>menos", "<b>cuatro</b><br>menos", "<b>cinco</b><br>menos", "<b>seis</b><br>menos", "<b>siete</b><br>menos", "<b>ocho</b><br>menos", "<b>nueve</b><br>menos", "<b>diez</b><br>menos", "<b>once</b><br>menos"]
            var nextHour = [false, false, false, false, false, false, false, true, true, true, true, true, true]
            var enPunto = [true, false, false, false, false, false, false, false, false, false, false, false, true]
            var minutes = Math.round(time.getMinutes()/5)
            var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12

            var start = "<p style=\"text-align:center\">"
            var newline = "<br>"
            var end = "</p>"
            if (enPunto[minutes]) {
                var generatedString = hoursList[hours].toUpperCase() + newline + minutesList[minutes].toUpperCase()
            } else {
                //also use next hour to decide between y or menos
                if (nextHour[minutes]) {
                    var generatedString = hoursListmenos[hours].toUpperCase() + newline + minutesList[minutes].toUpperCase()
                } else {
                    var generatedString = hoursListy[hours].toUpperCase() + newline + minutesList[minutes].toUpperCase()
                }
            }
            return start + generatedString + end
        }

        function generateTimeDe(time) {
            var nextHour   = [false, false, false, false, false, false, false, false, false, true, true, true, true]
            var minutes = Math.round(time.getMinutes()/5)
            var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12

            var minutesList = ["UHR", "<b>fünf</b><br>nach", "<b>zehn</b><br>nach", "<b>viertel</b><br>nach", "<b>zwanzig</b>", "<b>fünf</b><br> vor halb", "<b>halb</b>", "<b>fünf</b><br> nach halb", "<b>vierzig</b>", "<b>viertel</b><br>vor", "<b>zehn</b><br>vor", "<b>fünf</b><br>vor", "UHR"]
            var hoursList = ["<b>zwölf</b>", minutesList[minutes] == "UHR" ? "<b>ein</b>" : "<b>eins</b>", "<b>zwei</b>", "<b>drei</b>", "<b>vier</b>", "<b>fünf</b>", "<b>sechs</b>", "<b>sieben</b>", "<b>acht</b>", "<b>neun</b>", "<b>zehn</b>", "<b>elf</b>"]
            var minutesFirst = [false, true, true, true, false, true, true, true, false, true, true, true, false]
            var hourSuffix = [false, false, false, false ,true, false, false, false, true, false, false, false, false]



            var start = "<p style=\"text-align:center\">"
            var newline = "<br>"
            var end = "</p>"

            if (hourSuffix[minutes]) {
                if (minutesFirst[minutes]) {
                    var generatedString = minutesList[minutes].toUpperCase() + newline + hoursList[hours].toUpperCase() +" UHR"
                } else {
                    var generatedString = hoursList[hours].toUpperCase()+ newline + " UHR" + newline + minutesList[minutes].toUpperCase()}
            } else {

                    if (minutesFirst[minutes]) {
                        var generatedString = minutesList[minutes].toUpperCase() + newline + hoursList[hours].toUpperCase()
                    } else {
                        var generatedString = hoursList[hours].toUpperCase() + newline + minutesList[minutes].toUpperCase()
                    }

            }
            return start + generatedString + end
        }

        function generateTimeFr(time) {
            var minutesList = ["pile", "<b>cinq</b>", "<b>dix</b>", "et <b>quart</b>", "<b>vingt</b>", "<b>vingt-cinq</b>", "et <b>demie</b>", "moins<br><b>vingt-cinq</b>", "moins<br><b>vingt</b>", "moins le<br><b>quart</b>", "moins <b>dix</b>", "moins <b>cinq</b>", "pile"]
            var hoursList = ["<b>douze</b><br>heures", "<b>une</b><br>heure", "<b>deux</b><br>heures", "<b>trois</b><br>heures", "<b>quatre</b><br>heures", "<b>cinq</b><br>heures", "<b>six</b><br>heures", "<b>sept</b><br>heures", "<b>huit</b><br>heures", "<b>neuf</b><br>heures", "<b>dix</b><br>heures", "<b>onze</b><br>heures"]
            var minutesFirst = [false, false, false, false, false, false, false, false, false, false, false, false, false]
            var nextHour = [false, false, false, false, false, false, true, true, true, true, true, true, true]

            var minutes = Math.round(time.getMinutes()/5)
            var hours = (time.getHours() + (nextHour[minutes] ? 1 : 0)) % 12

            var start = "<p style=\"text-align:center\">"
            var newline = "<br>"
            var end = "</p>"

            if (minutesFirst[minutes]) {
                var generatedString = minutesList[minutes].toUpperCase() + newline + hoursList[hours].toUpperCase()
            } else {
                var generatedString = hoursList[hours].toUpperCase() + newline + minutesList[minutes].toUpperCase()
            }

            return start + generatedString + end
        }

        id: timeDisplay

        textFormat: Text.RichText
        font.pixelSize: Qt.locale().name.substring(0,2) == "fr" ? parent.height * 0.135 : Qt.locale().name.substring(0,2) == "es" ? parent.height * 0.145 : parent.height * 0.15
        font.weight: Font.Light
        lineHeight: 0.85
        color: "white"
        style: Text.Outline; styleColor: "#80000000"
        horizontalAlignment: Text.AlignHCenter

        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -parent.height*0.019
            left: parent.left
            right: parent.right
        }

        text: Qt.locale().name.substring(0,2) == "de" ? generateTimeDe(wallClock.time): Qt.locale().name.substring(0,2) == "es" ? generateTimeEs(wallClock.time): Qt.locale().name.substring(0,2) == "fr" ? generateTimeFr(wallClock.time): generateTimeEn(wallClock.time)
    }

    Text {
        id: dateDisplay

        font.pixelSize: parent.height*0.07
        color: "white"
        style: Text.Outline; styleColor: "#80000000"
        opacity: 0.9
        horizontalAlignment: Text.AlignHCenter

        anchors {
            topMargin: parent.width * 0.025
            top: timeDisplay.bottom
            left: parent.left
            right: parent.right
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "<b>ddd</b> d MMM")
    }

    Connections {
        target: localeManager
        onChangesObserverChanged: {
            timeDisplay.text = Qt.binding(function() { return generateTime(wallClock.time) })
            dateDisplay.text = Qt.binding(function() { return wallClock.time.toLocaleString(Qt.locale(), "<b>ddd</b> d MMM") })
        }
    }

    Component.onCompleted: {
        burnInProtectionManager.leftOffset = Qt.binding(function() { return width*0.05})
        burnInProtectionManager.rightOffset = Qt.binding(function() { return width*0.05})
        burnInProtectionManager.topOffset = Qt.binding(function() { return height*0.4})
        burnInProtectionManager.bottomOffset = Qt.binding(function() { return height*0.05})
    }
}
