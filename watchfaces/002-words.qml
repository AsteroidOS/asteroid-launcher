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
        function format(string, hour) {
            var hoursList = [qsTr("twelve"), qsTr("one"), qsTr("two"), qsTr("three"), qsTr("four"), qsTr("five"), qsTr("six"), qsTr("seven"), qsTr("eight"), qsTr("nine"), qsTr("ten"), qsTr("eleven")];

            string = string.replace(/\{0\}/g, function(_, _) {
                return hoursList[hour % 12];
            });

            return string.replace(/\{1\}/g, function(_, _) {
                return hoursList[(hour + 1) % 12];
            });
        }

        function generateTime(time) {
            var formatStrings = [qsTr("<b>{0}<br>'o clock</b>"),
                                 qsTr("<b>five</b><br>past<br><b>{0}</b>"),
                                 qsTr("<b>ten</b><br>past<br><b>{0}</b>"),
                                 qsTr("<b>quarter</b><br>past<br><b>{0}</b>"),
                                 qsTr("<b>{0}<br>twenty</b>"),
                                 qsTr("<b>{0}<br>twenty-five</b>"),
                                 qsTr("<b>{0}<br>thirty</b>"),
                                 qsTr("<b>{0}<br>thirty-five</b>"),
                                 qsTr("<b>{0}<br>fourty</b>"),
                                 qsTr("<b>quarter</b><br>to<br><b>{1}</b>"),
                                 qsTr("<b>ten</b><br>to<br><b>{1}</b>"),
                                 qsTr("<b>five</b><br>to<br><b>{1}</b>")];

            var minutes = Math.round(time.getMinutes()/5)

            return "<p style=\"text-align:center\">" + format(formatStrings[minutes], time.getHours()).toUpperCase() + "</p>"
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

        text: Qt.formatDate(wallClock.time, "<b>ddd</b> d MMM")
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
