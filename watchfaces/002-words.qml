/*
 * Copyright (C) 2016 Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
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
import QtGraphicalEffects 1.0

Item {
    id: rootitem

    Text {
        function generateTime(time) {
            var minutesList = ["<b>'o clock</b>", "<b>five</b><br>past", "<b>ten</b><br>past", "<b>quarter</b><br>past", "<b>twenty</b>", "<b>twenty-five</b>", "<b>thirty</b>", "<b>thirty-five</b>", "<b>fourty</b>", "<b>quarter</b><br>to", "<b>ten</b><br>to", "<b>five</b><br>to", "<b>'o clock</b>"]
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

        id: timeDisplay

        textFormat: Text.RichText

        font.pixelSize: 45
        font.weight: Font.Light
        lineHeight: 0.85
        color: "white"
        horizontalAlignment: Text.AlignHCenter

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }

        text: generateTime(wallClock.time)
    }

    DropShadow {
        anchors.fill: timeDisplay
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 16
        color: "#80000000"
        source: timeDisplay
    }

    Text {
        id: dateDisplay

        font.pixelSize: 20
        color: "white"
        opacity: 0.8
        horizontalAlignment: Text.AlignHCenter

        anchors {
            topMargin: 10
            top: timeDisplay.bottom
            left: parent.left
            right: parent.right
        }

        text: Qt.formatDateTime(wallClock.time, "<b>ddd.</b> d MMM.")
    }

    DropShadow {
        anchors.fill: dateDisplay
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 16
        color: "#80000000"
        source: dateDisplay
    }
}
