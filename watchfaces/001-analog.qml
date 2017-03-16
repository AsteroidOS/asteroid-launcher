/*
 * Copyright (C) 2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *               2012 - Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
 *                      Aleksey Mikhailichenko <a.v.mich@gmail.com>
 *                      Arto Jalkanen <ajalkane@gmail.com>
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

import QtQuick 2.1

Item {
    Text {
        id: dateDisplay

        font.pixelSize: parent.height/17
        color: "white"
        style: Text.Outline; styleColor: "#80000000"
        opacity: 0.8
        horizontalAlignment: Text.AlignHCenter

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height/17

        text: Qt.formatDate(wallClock.time, "<b>ddd</b> d MMM")
    }

    Canvas {
        anchors.fill: parent
        rotation: wallClock.time.getHours() * 30 + wallClock.time.getMinutes() * 0.5
        smooth: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = 3
            ctx.strokeStyle = "white"
            ctx.shadowColor = "#80000000"
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 3
            ctx.beginPath()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(width/2, height*0.3)
            ctx.closePath()
            ctx.stroke()
        }
    }

    Canvas {
        anchors.fill: parent
        rotation: wallClock.time.getMinutes() * 6
        smooth: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = 3
            ctx.strokeStyle = "white"
            ctx.shadowColor = "#80000000"
            ctx.shadowOffsetX = 3
            ctx.shadowOffsetY = 3
            ctx.shadowBlur = 3
            ctx.beginPath()
            ctx.moveTo(parent.width/2, parent.height/2)
            ctx.lineTo(width/2, height*0.1)
            ctx.closePath()
            ctx.stroke()
        }
    }
}
