/*
 * Copyright (C) 2022 - Timo Könnecke <github.com/eLtMosen>
 *               2022 - Darrel Griët <dgriet@gmail.com>
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

import QtQuick 2.9
import org.asteroid.controls 1.0
import QtGraphicalEffects 1.15

Item {
    anchors.fill: parent
    visible: background.opacity > 0
    Timer {
        id: animationStarter
        running: true
        triggeredOnStart: true
        onTriggered: {
            background.opacity = 0
            logoTransform.scale = 14
            cutout.width = Dims.w(150)
        }
    }
    Rectangle {
        id: background
        color: "black"
        anchors.fill: parent
        opacity: visible ? 1.0 : 0
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: 150 }
                NumberAnimation { duration: 250; easing.type: Easing.InSine }
            }
        }
    }
    Rectangle {
        id: logo
        anchors.fill: parent
        color: "black"
        visible: false
        Image {
            id: logoSvg
            anchors.fill: parent
            fillMode: Image.Pad
            source: "qrc:/images/bootlogo.svg"
            sourceSize: Qt.size(Dims.w(55), Dims.h(55))
            transform: Scale {
                id: logoTransform
                property real scale: 1
                origin.x: Dims.w(50)
                origin.y: Dims.h(44.5)
                xScale: scale
                yScale: scale
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.InQuint } }
            }
        }
    }
    Item {
        id: mask
        anchors.fill: parent
        visible: false
        Rectangle {
            id: cutout
            width: 1
            height: width
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Dims.h(5)
            radius: parent.width / 2
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InQuint } }
        }
    }
    OpacityMask {
        anchors.fill: logo
        source: logo
        maskSource: mask
        invert: true
    }
}
