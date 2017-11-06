/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2013 Jolla Ltd.
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
import org.asteroid.utils 1.0

ShaderEffect {
    property real smoothness: 0.0007
    property bool keepInner: true

    property real end: 0.25
    property real beginning: 0.25 - smoothness

    fragmentShader: "
    #extension GL_OES_standard_derivatives: enable
    #ifdef GL_ES
        precision lowp float;
    #endif // GL_ES
    varying highp vec2 qt_TexCoord0;
    uniform highp float qt_Opacity;
    uniform lowp sampler2D source;
    uniform lowp float end;
    uniform lowp float beginning;
    uniform bool keepInner;

    void main(void) {
        lowp float x, y;
        x = (qt_TexCoord0.x - 0.5);
        y = (qt_TexCoord0.y - 0.5);
        if(keepInner) {
            gl_FragColor = texture2D(source, qt_TexCoord0).rgba
                * step(x * x + y * y, 0.25)
                * smoothstep((x * x + y * y) , end, beginning)
                * qt_Opacity;
        } else {
            gl_FragColor = texture2D(source, qt_TexCoord0).rgba
                * (1.0 - (step(x * x + y * y, 0.25)
                * smoothstep((x * x + y * y) , end, beginning)))
                * qt_Opacity;
        }
    }"
}
