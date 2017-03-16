/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2012 Timur Kristóf <venemo@fedoraproject.org>
 *               2011 Tom Swindell <t.swindell@rubyx.co.uk>
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

import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import org.asteroid.controls 1.0

MouseArea {
    id: switcherItemRoot

    Item {
        anchors.fill: parent
        WindowPixmapItem {
            id: windowPixmap
            anchors.fill: parent
            windowId: model.window
        }
        Rectangle {
            id: darkener
            anchors.fill: parent
            color: "#000000"
            opacity: 0.3
            visible: switcherItemRoot.pressed
        }
        opacity: switcherRoot.closeMode ? .6 : 1
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        layer.enabled: DeviceInfo.hasRoundScreen
        layer.effect: ShaderEffect {
            property real adjustX: Math.max(width / height, 1)
            property real adjustY: Math.max(1 / (width / height), 1)

            fragmentShader: "
            #extension GL_OES_standard_derivatives: enable
            #ifdef GL_ES
                precision lowp float;
            #endif // GL_ES
            varying highp vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D source;
            uniform lowp float adjustX;
            uniform lowp float adjustY;

            void main(void) {
                lowp float x, y;
                x = (qt_TexCoord0.x - 0.5) * adjustX;
                y = (qt_TexCoord0.y - 0.5) * adjustY;
                float delta = adjustX != 1.0 ? fwidth(y) / 2.0 : fwidth(x) / 2.0;
                gl_FragColor = texture2D(source, qt_TexCoord0).rgba
                    * step(x * x + y * y, 0.25)
                    * smoothstep((x * x + y * y) , 0.25 + delta, 0.25)
                    * qt_Opacity;
            }"
        }
    }

    function close() {
        Lipstick.compositor.closeClientForWindowId(model.window)
    }

    onClicked: {
        if (!switcherRoot.closeMode) {
            Lipstick.compositor.windowToFront(model.window);
        } else {
            switcherRoot.closeMode = false;
        }
    }

    onPressAndHold: {
        switcherRoot.closeMode = true;
    }

    SequentialAnimation {
        id: closeAnimation
        ParallelAnimation {
            NumberAnimation {
                target: switcherItemRoot
                property: "scale"
                duration: 200
                to: 0.0
            }

            NumberAnimation {
                target: switcherItemRoot
                property: "opacity"
                duration: 150
                to: 0.0
            }
        }
        ScriptAction {
            script: switcherItemRoot.close()
        }
    }

    Icon {
        id: closeButton
        name: "ios-close-circle"
        Behavior on scale { PropertyAnimation { duration: 300; easing.type: Easing.OutBack } }
        scale: switcherRoot.closeMode ? 1 : 0
        opacity: scale
        enabled: !closeAnimation.running
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: closeAnimation.start()
        }
    }
}
