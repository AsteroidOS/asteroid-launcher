/*
 * Copyright (C) 2018 - Timo Könnecke <el-t-mo@arcor.de>
 *               2017 - Mario Kicherer <dev@kicherer.org>
 *               2016 - Sylvia van Os <iamsylvie@openmailbox.org>
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

/*
 * Based on analog-precison by Mario Kicherer. Remodeled the arms to arcs
 * and tried hard on font centering and anchor alignment.
 */

import QtQuick 2.1

Item {
    property var radian: 0.01745

    function prepareContext(ctx) {
        ctx.reset()
        ctx.shadowColor = (0, 0, 0, 0.25)
        ctx.shadowOffsetX = 0
        ctx.shadowOffsetY = 0
        ctx.shadowBlur = parent.height*0.00625
        ctx.lineCap="round"

    }

    Rectangle {
        z: 0
        x: parent.width/2-width/2
        y: parent.height/2-width/2
        color: Qt.rgba(0, 0, 0, 0.2)
        width: parent.width/1.3
        height: parent.height/1.3
        radius: width*0.5
    }

    Canvas {
        id: secondCanvas
        property var second: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            var rot = (wallClock.time.getSeconds() - 15)*6
            var rot_half = (wallClock.time.getSeconds() - 22)*6
            prepareContext(ctx)
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 2.2, -89.5 * radian, rot* radian, false);
            ctx.lineWidth = parent.width * 0.009375
            ctx.strokeStyle = Qt.rgba(0.871, 0.165, 0.102, 0.95)
            ctx.stroke()
        }
    }

    Canvas {
        id: minuteCanvas
        property var minute: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            var rot = (minute -15 )*6
            prepareContext(ctx)
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 2.33, -88.8* radian, rot* radian, false);
            ctx.lineWidth = parent.width * 0.01875
            ctx.strokeStyle = Qt.rgba(1, 0.549, 0.149, 0.95)
            ctx.stroke()
        }
    }

    Canvas {
        id: hourCanvas
        property var hour: 0
        anchors.fill: parent
        smooth: true
        renderStrategy: Canvas.Threaded
        visible: !displayAmbient
        onPaint: {
            var ctx = getContext("2d")
            var rot = 0.5 * (60 * (hour-3) + wallClock.time.getMinutes())
            prepareContext(ctx)
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 2.6,  273.5* radian, rot* radian, false);
            ctx.lineWidth = parent.width * 0.05
            ctx.strokeStyle = Qt.rgba(0.945, 0.769, 0.059, 0.95)
            ctx.stroke()
            ctx.beginPath()
        }
    }

    Text {
        id: hourDisplay
        font.pixelSize: parent.height * 0.375
        font.family: "Titillium"
        font.styleName:'Bold'
        font.letterSpacing: -3
        color: Qt.rgba(1, 1, 1, 1)
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.5)
        anchors {
            right: parent.horizontalCenter
            rightMargin: -parent.height * 0.0938
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: parent.height * 0.0281
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "HH")
    }

    Text {
        id: minuteDisplay
        property var rotM: (wallClock.time.getMinutes() - 12.1)/60
        font.pixelSize: parent.height * 0.1375
        font.styleName:'Semibold'
        font.letterSpacing: -1
        color: Qt.rgba(1, 1, 1, 1)
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.5)
        anchors {
            top: hourDisplay.top;
            topMargin: -parent.height*0.015625
            leftMargin: parent.width*0.025
            left: hourDisplay.right;
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "mm")
    }

    Text {
        id: secondDisplay
        font.pixelSize: parent.height * 0.1375
        font.family: "Titillium"
        font.styleName:'Thin'
        font.letterSpacing: -1
        color: Qt.rgba(1, 1, 1, 1)
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.5)
        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: hourDisplay.bottom;
            bottomMargin: parent.height*0.059375
            leftMargin: parent.width*0.025
            left: hourDisplay.right;
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "ss")
        visible: !displayAmbient
    }

    Text {
        id: dowDisplay
        font.pixelSize: parent.height*0.084375
        font.family: "Titillium"
        font.styleName:'Thin'
        color: Qt.rgba(1, 1, 1, 1)
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.5)
        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: hourDisplay.top
            left: parent.left
            right: parent.right
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "dddd")
    }

    Text {
        id: dateDisplay
        font.pixelSize: parent.height*0.084375
        font.family: "Titillium"
        font.styleName:'Thin'
        color: Qt.rgba(1, 1, 1, 1)
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.5)
        horizontalAlignment: Text.AlignHCenter
        anchors {
            topMargin: -parent.height*0.05
            top: hourDisplay.bottom
            left: parent.left
            right: parent.right
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "<b>dd</b> MMMM")
    }

    Connections {
        target: wallClock
        onTimeChanged: {
            if (displayAmbient) return
            var hour = wallClock.time.getHours()
            var minute = wallClock.time.getMinutes()
            var second = wallClock.time.getSeconds()
            if(secondCanvas.second != second) {
                secondCanvas.second = second
                secondCanvas.requestPaint()
            } if(hourCanvas.hour != hour) {
                hourCanvas.hour = hour
            }if(minuteCanvas.minute != minute) {
                minuteCanvas.minute = minute
                minuteCanvas.requestPaint()
                hourCanvas.requestPaint()
            }
        }
    }

    Component.onCompleted: {
        var hour = wallClock.time.getHours()
        var minute = wallClock.time.getMinutes()
        var second = wallClock.time.getSeconds()
        secondCanvas.second = second
        secondCanvas.requestPaint()
        minuteCanvas.minute = minute
        minuteCanvas.requestPaint()
        hourCanvas.hour = hour
        hourCanvas.requestPaint()

        burnInProtectionManager.widthOffset = Qt.binding(function() { return width*0.3})
        burnInProtectionManager.heightOffset = Qt.binding(function() { return height*0.3})
    }
}
