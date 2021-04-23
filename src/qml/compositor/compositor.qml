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

import QtQuick 2.9
import QtQuick.Window 2.1
import org.nemomobile.lipstick 0.1
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import "desktop.js" as Desktop
import "compositor"

Item {
    id: root
    width: Dims.w(100)
    height: Dims.h(100)
    rotation: Screen.angleBetween(Screen.primaryScreen, Lipstick.compositor.screenOrientation)

    Item {
        id: homeLayer
        z: 1
        anchors.fill: parent
    }

    Item {
        id: appLayer
        z: 2

        opacity: (width-2*gestureArea.value)/width
        x: gestureArea.active &&  gestureArea.horizontal ? gestureArea.value : 0
        y: gestureArea.active && !gestureArea.horizontal ? gestureArea.value : 0

        width: parent.width
        height: parent.height

        // Let app deal with rotation themselves
        rotation: Screen.angleBetween(Lipstick.compositor.screenOrientation, Screen.primaryScreen)
    }

    Item {
        id: notificationLayer
        z: 3
        anchors.fill: parent
    }

    Item {
        id: agentLayer
        z: 4
        anchors.fill: parent
    }

    BorderGestureArea {
        id: gestureArea
        enabled: comp.appActive
        z: 5
        anchors.fill: parent
        acceptsDown: true
        acceptsRight: !comp.topmostWindowRequestsGesturesDisabled

        property real swipeThreshold: 0.15

        onGestureStarted: {
            swipeAnimation.stop()
            if (gesture == "down")
                Desktop.onAboutToClose()
            else if(gesture == "right")
                Desktop.onAboutToMinimize()
        }

        onGestureFinished: {
            if ((gesture == "down" || gesture == "right")) {
                if (gestureArea.progress >= swipeThreshold) {
                    swipeAnimation.valueTo = inverted ? -max : max
                    swipeAnimation.start()
                    Lipstick.compositor.closeClientForWindowId(comp.topmostWindow.window.windowId)
                } else {
                    cancelAnimation.start()
                }
            } else if (comp.homeActive) {
                cancelAnimation.start()
            }
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
                script: comp.setCurrentWindow(comp.homeWindow)
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
            Lipstick.compositor.closeClientForWindowId(comp.topmostWindow.window.windowId)
            Lipstick.compositor.setAmbientUpdatesEnabled(true)
        }
    }

    Compositor {
        id: comp

        property Item homeWindow

        // Set to the item of the current topmost window
        property Item topmostWindow

        // Only used to change blank timeout when on watchface or elsewhere
        property bool longTimeout: homeActive
        Component.onCompleted: longTimeout = Qt.binding(function() { return homeActive && (Desktop.panelsGrid.currentVerticalPos == 0 && Desktop.panelsGrid.currentHorizontalPos == 0) })
        onLongTimeoutChanged: lipstickSettings.lockscreenVisible = longTimeout

        // True if the home window is the topmost window
        homeActive: topmostWindow == comp.homeWindow
        property bool appActive: !homeActive

        // The application window that was most recently topmost
        property Item topmostApplicationWindow

        readonly property bool topmostWindowRequestsGesturesDisabled: topmostWindow && topmostWindow.window
                                                                      && (topmostWindow.window.windowFlags & 1)

        function windowToFront(winId) {
            var o = comp.windowForId(winId)
            var window = null

            if (o) window = o.userData
            if (window == null) window = homeWindow

            setCurrentWindow(window)
        }

        function setCurrentWindow(w, skipAnimation) {
            if (w == null)
                w = homeWindow

            topmostWindow = w;

            if (topmostWindow != homeWindow && topmostWindow != null) {
                if (topmostApplicationWindow) topmostApplicationWindow.visible = false
                topmostApplicationWindow = topmostWindow
                topmostApplicationWindow.visible = true
                if (!skipAnimation) topmostApplicationWindow.animateIn()
                w.window.takeFocus()
            }
        }

        onDisplayOff: delayTimer.start()
        onDisplayAboutToBeOn: delayTimer.stop()

        onWindowAdded: {
            var isHomeWindow = window.isInProcess && comp.homeWindow == null && window.title === "Home"
            var isDialogWindow = window.category === "dialog"
            var isNotificationWindow = window.category == "notification"
            var isAgentWindow = window.category == "agent"
            var parent = null
            if (isHomeWindow) {
                parent = homeLayer
            } else if (isNotificationWindow) {
                parent = notificationLayer
            } else if (isAgentWindow) {
                parent = agentLayer
            } else {
                parent = appLayer
            }

            var w = windowWrapper.createObject(parent, { window: window })
            window.userData = w

            if (isHomeWindow) {
                comp.homeWindow = w
                setCurrentWindow(homeWindow)
            } else if (!isNotificationWindow && !isAgentWindow && !isDialogWindow) {
                if (topmostApplicationWindow != null) {
                    Lipstick.compositor.closeClientForWindowId(topmostApplicationWindow.window.windowId)
                }
                w.smoothBorders = true
                w.x = width
                w.moveInAnim.start()
                cancelAnimation.start()
                setCurrentWindow(w)
            }
        }

        onWindowRaised:  windowToFront(window.windowId)

        onWindowRemoved: {
            var w = window.userData;
            if (comp.topmostWindow == w)
                setCurrentWindow(comp.homeWindow);

            if (window.userData)
                window.userData.destroy()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        z: 6
        visible: DeviceInfo.hasRoundScreen
        layer.enabled: DeviceInfo.hasRoundScreen
        layer.effect: CircleMaskShader {
            smoothness: 0.002
            keepInner: false
        }
    }
}
