/*
 * Copyright (C) 2021 - Timo Könnecke <el-t-mo@arcor.de>
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

import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Mce 1.0

Item {

    Image {
        z: 0
        width: parent.width
        height: parent.height
        source: "../watchfaces-img/funky-town-words-" + wallClock.time.toLocaleString(Qt.locale(), "hh am").slice(0, 2) + ".svg"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    Image {
        z: 0
        visible: use12H.value
        width: parent.width
        height: parent.height
        source: "../watchfaces-img/funky-town-words-" + wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase().slice(0, 2) + ".svg"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    Text {
        id: minuteDisplay

        z: 1
        font.pixelSize: parent.height * 0.22
        font.family: "Source Sans Pro"
        font.styleName: "Light"
        color: "white"
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height * 0.15
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: parent.width*0.2
        }
        Behavior on text {
            enabled: !displayAmbient

            SequentialAnimation {
                NumberAnimation { target: minuteDisplay; property: "opacity"; to: 0 }
                PropertyAction {}
                NumberAnimation { target: minuteDisplay; property: "opacity"; to: 1 }
            }
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "mm")
    }


    Item {
        id: nightstandMode

        readonly property bool active: mceCableState.connected //ready || (nightstandEnabled.value && holdoff)
        //readonly property bool ready: nightstandEnabled.value && mceCableState.connected
        property int batteryPercentChanged: batteryChargePercentage.percent

        anchors.fill: parent
        visible: nightstandMode.active
        layer.enabled: true
        layer.samples: 4

        Shape {
            id: chargeArc

            property real angle: batteryChargePercentage.percent * 360 / 100
            // radius of arc is scalefactor * height or width
            property real arcStrokeWidth: 0.05
            property real scalefactor: 0.5 - (arcStrokeWidth / 2)
            property var chargecolor: Math.floor(batteryChargePercentage.percent / 33.35)
            readonly property var colorArray: [ "red", "yellow", Qt.rgba(0.318, 1, 0.051, 0.9)]

            anchors.fill: parent
            smooth: true
            antialiasing: true

            ShapePath {
                fillColor: "transparent"
                strokeColor: chargeArc.colorArray[chargeArc.chargecolor]
                strokeWidth: parent.height * chargeArc.arcStrokeWidth
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.MiterJoin
                startX: width / 2
                startY: height * ( 0.5 - chargeArc.scalefactor)

                PathAngleArc {
                    centerX: parent.width / 2
                    centerY: parent.height / 2
                    radiusX: chargeArc.scalefactor * parent.width
                    radiusY: chargeArc.scalefactor * parent.height
                    startAngle: -90
                    sweepAngle: chargeArc.angle
                    moveToStart: false
                }
            }
        }

        Text {
            id: batteryPercent

            anchors {
                centerIn: parent
                verticalCenterOffset: -parent.width * 0.28
            }

            font {
                pixelSize: parent.width * .22
                family: "Source Sans Pro"
                styleName: "Light"
            }
            visible: nightstandMode.active
            color: chargeArc.colorArray[chargeArc.chargecolor]
            text: batteryChargePercentage.percent
        }
    }

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    MceBatteryState {
        id: batteryChargeState
    }

    MceCableState {
        id: mceCableState
    }

    Component.onCompleted: {
        burnInProtectionManager.leftOffset = Qt.binding(function() { return width * 0.4})
        burnInProtectionManager.rightOffset = Qt.binding(function() { return width * 0.05})
        burnInProtectionManager.topOffset = Qt.binding(function() { return height * 0.4})
        burnInProtectionManager.bottomOffset = Qt.binding(function() { return height * 0.05})
    }
}
