// Copyright (C) 2013 John Brooks <john.brooks@dereferenced.net>
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

MouseArea {
    id: root

    property int boundary: 20
    property bool delayReset

    signal gestureStarted(string gesture)
    signal gestureFinished(string gesture)

    // Current gesture
    property bool active: gesture != ""
    property string gesture
    property int value
    property int max
    property real progress: Math.abs(value) / max
    property bool horizontal: gesture === "left" || gesture === "right"
    property bool inverted: gesture === "left" || gesture === "up"

    // Internal
    property int _mouseStart

    onPressed: {
        if (mouse.x < boundary) {
            gesture = "right"
            max = width - mouse.x
        } else if (width - mouse.x < boundary) {
            gesture = "left"
            max = mouse.x
        } else if (mouse.y < boundary) {
            gesture = "down"
            max = height - mouse.y
        } else if (height - mouse.y < boundary) {
            gesture = "up"
            max = mouse.y
        } else {
            mouse.accepted = false
            return
        }

        value = 0
        if (horizontal)
            _mouseStart = mouse.x
        else
            _mouseStart = mouse.y

        gestureStarted(gesture)
    }

    onPositionChanged: {
        var p = horizontal ? mouse.x : mouse.y
        value = Math.max(Math.min(p - _mouseStart, max), -max)
    }

    function reset() {
        gesture = ""
        value = max = 0
        _mouseStart = 0
    }

    onDelayResetChanged: {
        if (!delayReset)
            reset()
    }

    onReleased: {
        gestureFinished(gesture)
        if (!delayReset)
            reset()
    }
}

