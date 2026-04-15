/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
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

MouseArea {
    id: ma

    width: parent.width
    height: width
    preventStealing: true

    property alias icon: ic.name
    property bool checkable: false
    property bool checked: false

    property bool rangeBased: false
    property int rangeMin: 0
    property int rangeMax: 100
    property int rangeStepSize: 10
    property int rangeValue: 0

    pressAndHoldInterval: 300

    property bool isIncreasing: true

    onPressAndHold: {
        if (!rangeBased) return;
        holdTimer.start()
    }

    onReleased: {
        holdTimer.stop()
        directionChangeTimer.stop()
    }

    onCanceled: {
        holdTimer.stop()
        directionChangeTimer.stop()
    }

    Timer {
        id: holdTimer
        interval: 300
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const newValue = rangeValue + (isIncreasing ? 1 : -1) * rangeStepSize
            rangeValue = Math.max(rangeMin, Math.min(rangeMax, newValue))
            if (rangeValue >= rangeMax || rangeValue <= rangeMin) {
                holdTimer.stop()
                isIncreasing = !isIncreasing
                directionChangeTimer.start()
            }
        }
    }

    Timer {
        id: directionChangeTimer
        //delay after direction is changed
        interval: 1000
        repeat: false
        onTriggered: {
            if (ma.pressed)
                holdTimer.start()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width/2
        color: "#222222"
        opacity: ma.pressed ? 0.6 : ma.checked ?  0.75 : (ma.checkable ? 0.2 : 1)
    }

    Icon {
        id: ic
        width: parent.width*0.5
        height: width
        anchors.centerIn: parent
        color: ma.pressed ? "lightgrey" : "white"
        opacity: ma.pressed ? 0.5 : ma.checked ? 1 : (ma.checkable ? 0.3 : 1)
    }
}

