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
import QtQuick.Window 2.0
import org.nemomobile.lipstick 0.1

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
    property Item _mapTo: Lipstick.compositor.homeActive ? Lipstick.compositor.topmostWindow.window : parent
    property variant _gestures: ["down", "left", "up", "right"]

    function mouseToMouseReal(m) {
        return mapToItem(_mapTo, m.x, m.y)
    }

    function realGesture(g) {
        var r = Screen.angleBetween(Lipstick.compositor.screenOrientation, Screen.orientation) / 90
        if (r === 0)
            return g

        var shiftedGestures = _gestures.slice(0)
        for (var i = 0; i < r; i++) {
            var shifted = shiftedGestures.shift()
            shiftedGestures.push(shifted)
        }

        return _gestures[shiftedGestures.indexOf(g)]
    }

    onPressed: {
        var mouseReal = mouseToMouseReal(mouse)

        if (mouseReal.x < boundary) {
            gesture = "right"
            max = _mapTo.width - mouseReal.x
        } else if (_mapTo.width - mouseReal.x < boundary) {
            gesture = "left"
            max = mouseReal.x
        } else if (mouseReal.y < boundary) {
            gesture = "down"
            max = _mapTo.height - mouseReal.y
        } else if (_mapTo.height - mouseReal.y < boundary) {
            gesture = "up"
            max = mouseReal.y
        } else {
            mouse.accepted = false
            return
        }

        value = 0
        if (horizontal)
            _mouseStart = mouseReal.x
        else
            _mouseStart = mouseReal.y

        gestureStarted(Lipstick.compositor.homeActive ?  gesture : realGesture(gesture))
    }

    onPositionChanged: {
        var mouseReal = mouseToMouseReal(mouse)
        var p = horizontal ? mouseReal.x : mouseReal.y
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
        gestureFinished(Lipstick.compositor.homeActive ? gesture : realGesture(gesture))
        if (!delayReset)
            reset()
    }
}

