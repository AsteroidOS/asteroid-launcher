/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2013 John Brooks <john.brooks@dereferenced.net>
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

import QtQuick
import QtQuick.Window
import QtSensors
import Nemo.Configuration
import org.nemomobile.lipstick
import org.asteroid.controls
import org.asteroid.utils
import "desktop.js" as Desktop
import "compositor"

Item {
    id: root
    readonly property bool quarterTurn: rotation % 180 !== 0
    width: quarterTurn ? Dims.h(100) : Dims.w(100)
    height: quarterTurn ? Dims.w(100) : Dims.h(100)
    x: (Dims.w(100) - width) / 2
    y: (Dims.h(100) - height) / 2
    rotation: Screen.angleBetween(Screen.primaryOrientation, Lipstick.compositor.screenOrientation)

    Behavior on rotation {
        RotationAnimation { duration: 150; easing.type: Easing.OutQuad; direction: RotationAnimation.Shortest }
    }

    function orientationForReading(reading) {
        var angle
        switch (reading) {
        case OrientationReading.RightUp: angle = 90;  break
        case OrientationReading.TopDown: angle = 180; break
        case OrientationReading.LeftUp:  angle = 270; break
        default: return Qt.PrimaryOrientation
        }
        var candidates = [Qt.PortraitOrientation, Qt.LandscapeOrientation,
                          Qt.InvertedPortraitOrientation, Qt.InvertedLandscapeOrientation]
        for (var i = 0; i < candidates.length; i++)
            if (Screen.angleBetween(Screen.primaryOrientation, candidates[i]) === angle)
                return candidates[i]
        return Qt.PrimaryOrientation
    }

    // The home screen is a persistent item at the bottom of the z-stack, not
    // an in-process "window". Its z follows MainScreen's own z (raised while
    // the splash is up) so it can sit above running apps when needed.
    Item {
        id: homeLayer
        z: homeLoader.item ? homeLoader.item.z : 0
        anchors.fill: parent

        Loader {
            id: homeLoader
            anchors.fill: parent
            source: "MainScreen.qml"
            onLoaded: item.aboutToOpen = Qt.binding(function() { return !comp.homeActive && !appLayer.ready })
        }
    }

    Item {
        property bool ready: false
        id: appLayer
        visible: comp ? comp.appActive : false
        z: 2

        opacity: (width-2*gestureArea.value)/width
        x: gestureArea.active &&  gestureArea.horizontal ? gestureArea.value : 0
        y: gestureArea.active && !gestureArea.horizontal ? gestureArea.value : 0

        width: parent.width
        height: parent.height
    }

    // Launcher overlays, rendered directly in the compositor scene as
    // z-ordered items instead of in-process "windows". Each is fed by a C++
    // object exposed as a context property; the QML gates its own visibility.
    Loader {
        z: 3
        anchors.fill: parent
        source: "notifications/NotificationPreview.qml"
    }

    Loader {
        z: 3
        anchors.fill: parent
        source: "system/ShutdownScreen.qml"
    }

    Loader {
        z: 4
        anchors.fill: parent
        source: "connectivity/BluetoothAgent.qml"
    }

    BorderGestureArea {
        id: gestureArea
        enabled: comp ? comp.appActive : false
        z: 5
        anchors.fill: parent
        acceptsDown: true
        acceptsRight: comp != null && comp.topmostWindow != null && !comp.topmostWindowRequestsGesturesDisabled

        property real swipeThreshold: 0.15

        onGestureStarted: (gesture) => {
            swipeAnimation.stop()
            if (gesture == "down") {
                Desktop.desktop.aboutToClose = true
            } else if(gesture == "right") {
                Desktop.desktop.aboutToMinimize = true
            }
        }

        onGestureFinished: (gesture) => {
            if ((gesture == "down" || gesture == "right")) {
                if (gestureArea.progress >= swipeThreshold) {
                    swipeAnimation.valueTo = inverted ? -max : max
                    swipeAnimation.start()
                    var app = comp.topmostWindow
                    comp.topmostWindow = null
                    if (app && app.window)
                        Lipstick.compositor.closeClientForWindowId(app.window.windowId)
                } else {
                    cancelAnimation.start()
                }
            } else if (comp.homeActive) {
                cancelAnimation.start()
            }
            Desktop.desktop.aboutToClose = false
            Desktop.desktop.aboutToMinimize = false
        }

        NumberAnimation {
            id: cancelAnimation
            target: gestureArea
            property: "value"
            to: 0
            duration: 200
            easing.type: Easing.OutQuint
        }

        SequentialAnimation {
            id: swipeAnimation
            property alias valueTo: valueAnimation.to

            NumberAnimation {
                id: valueAnimation
                target: gestureArea
                property: "value"
                duration: 200
                easing.type: Easing.OutQuint
            }

            ScriptAction {
                script: comp.setCurrentWindow(null)
            }
        }
    }

    Component {
        id: windowWrapper
        WindowWrapperBase { }
    }

    Timer {
        id: delayTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (comp.topmostWindow && comp.topmostWindow.window)
                Lipstick.compositor.closeClientForWindowId(comp.topmostWindow.window.windowId)
            Lipstick.compositor.setAmbientUpdatesEnabled(true)
        }
    }

    ConfigurationValue {
        id: nightstandRotate
        key: "/desktop/asteroid/nightstand/rotate"
        defaultValue: true
    }

    OrientationSensor {
        id: orientationSensor
        readonly property bool wanted: nightstandRotate.value
                                       && homeLoader.item && homeLoader.item.nightstand
        active: wanted && (comp ? !comp.displayAmbient : false)
    }

    Compositor {
        id: comp

        screenOrientation: orientationSensor.wanted && orientationSensor.reading
                           ? root.orientationForReading(orientationSensor.reading.orientation)
                           : Qt.PrimaryOrientation

        // The current foreground application window, or null when the home
        // screen (the persistent item underneath) is showing.
        property Item topmostWindow

        // Only used to change blank timeout when on watchface or elsewhere
        property bool longTimeout: homeActive
        Component.onCompleted: {
            longTimeout = Qt.binding(function() {
                return homeActive && Desktop.panelsGrid != null
                    && Desktop.panelsGrid.currentVerticalPos == 0
                    && Desktop.panelsGrid.currentHorizontalPos == 0
            })
        }
        onLongTimeoutChanged: lipstickSettings.lockscreenVisible = longTimeout

        // Home is active whenever no application window is on top
        homeActive: topmostWindow == null
        property bool appActive: !homeActive

        // The application window that was most recently topmost
        property Item topmostApplicationWindow

        readonly property bool topmostWindowRequestsGesturesDisabled: topmostWindow && topmostWindow.window
                                                                      && topmostWindow.window.overridesSystemGestures

        function windowToFront(winId) {
            var o = comp.windowForId(winId)
            setCurrentWindow(o ? o.userData : null)
        }

        function setCurrentWindow(w, skipAnimation) {
            topmostWindow = w; // null => the home screen is shown

            if (topmostWindow != null) {
                if (topmostApplicationWindow && topmostApplicationWindow != topmostWindow)
                    topmostApplicationWindow.visible = false
                topmostApplicationWindow = topmostWindow
                topmostApplicationWindow.visible = true
                if (!skipAnimation) topmostApplicationWindow.animateIn()
                w.window.takeFocus()
            }
        }

        onDisplayOff: delayTimer.start()
        onDisplayAboutToBeOn: delayTimer.stop()

        onWindowAdded: (window) => {
            // The launcher's own UI (home screen + overlays) are plain items,
            // so every window here is a Wayland client application.
            var isDialogWindow = window.category === "dialog"

            var w = windowWrapper.createObject(appLayer, { window: window })
            window.userData = w

            if (!isDialogWindow) {
                if (topmostApplicationWindow != null) {
                    Lipstick.compositor.closeClientForWindowId(topmostApplicationWindow.window.windowId)
                }
                appLayer.ready = false
                w.smoothBorders = Qt.binding(function() {
                    return gestureArea.active || appLayer.opacity < 1.0 || !appLayer.ready
                })
                w.x = width
                w.moveInAnim.start()
                cancelAnimation.start()
                setCurrentWindow(w)
            }
        }

        onWindowRaised: (window) => windowToFront(window.windowId)

        onWindowRemoved: (window) => {
            var w = window.userData;
            if (comp.topmostWindow == w)
                setCurrentWindow(null); // reveal the home screen underneath

            if (window.userData)
                window.userData.destroy()
        }
    }

    // Rounds off the corners of a round screen. The mask depends on nothing
    // but the size of the screen, so rather than masking the whole screen
    // again on every frame the system draws, it is rendered once into a
    // texture that every later frame simply blits.
    ShaderEffectSource {
        z: 6
        anchors.fill: parent
        visible: DeviceSpecs.hasRoundScreen
        live: false
        hideSource: true
        sourceItem: cornerMask

        Component.onCompleted: scheduleUpdate()
        onWidthChanged: scheduleUpdate()
        onHeightChanged: scheduleUpdate()

        Item {
            id: cornerMask
            anchors.fill: parent

            // CircleMaskShader shades a source texture, and the source here is
            // a constant: the corners are painted plain black. A single opaque
            // black pixel, stretched over the item, is that constant.
            Rectangle {
                id: blackPixel
                width: 1
                height: 1
                color: "black"
                layer.enabled: true
            }

            CircleMaskShader {
                anchors.fill: parent
                smoothness: 0.002
                keepInner: false
                property Item source: blackPixel
            }
        }
    }
}
