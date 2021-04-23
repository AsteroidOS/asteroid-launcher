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

    Image {
        z: 0
        width: parent.width
        height: parent.height
        source: "../watchfaces-img/funky" + wallClock.time.toLocaleString(Qt.locale(), "hh am").slice(0, 2) + ".svg"
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
        source: "../watchfaces-img/funky" + wallClock.time.toLocaleString(Qt.locale("en_EN"), "ap").toLowerCase().slice(0, 2) + ".svg"
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    Text {
        z: 1
        id: minuteDisplay
        font.pixelSize: parent.height*0.24
        font.family: "Source Sans Pro"
        font.styleName: "Light"
        color: "white"
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height*0.155
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: parent.width*0.210
        }
        Behavior on text {
            SequentialAnimation {
                NumberAnimation { target: minuteDisplay; property: "opacity"; to: 0 }
                PropertyAction {}
                NumberAnimation { target: minuteDisplay; property: "opacity"; to: 1 }
            }
        }
        text: wallClock.time.toLocaleString(Qt.locale(), "mm")
    }

    Component.onCompleted: {
        burnInProtectionManager.leftOffset = Qt.binding(function() { return width*0.4})
        burnInProtectionManager.rightOffset = Qt.binding(function() { return width*0.05})
        burnInProtectionManager.topOffset = Qt.binding(function() { return height*0.4})
        burnInProtectionManager.bottomOffset = Qt.binding(function() { return height*0.05})
    }
}
