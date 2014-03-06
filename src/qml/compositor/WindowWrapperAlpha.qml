// Copyright (C) 2013 Jolla Ltd.
//
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import QtQuick 2.0

WindowWrapperBase {
    id: wrapper
    ShaderEffect {
        anchors.fill: parent
        z: 2

        // source Item must be a texture provider
        property Item source: wrapper.window

        fragmentShader: "
                       uniform sampler2D source;
                       uniform mediump float qt_Opacity;
                       varying highp vec2 qt_TexCoord0;
                       void main() {
                           gl_FragColor = qt_Opacity * texture2D(source, qt_TexCoord0);
                       }"
    }
    onWindowChanged: {
        if (window != null) {
            // do not paint the QWaylandSurfaceItem, just use it as
            // a texture provider
            window.setPaintEnabled(false)
        }
    }
}

