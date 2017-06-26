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

import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import org.asteroid.controls 1.0
import "desktop.js" as Desktop
import "compositor"

Item {
    id: root
    anchors.fill: parent

    Connections {
        target: comp != null ? comp.quickWindow : null
        onActiveFocusItemChanged: {
            // Search for the layer of the focus item
            var focusedLayer = comp.activeFocusItem
            while (focusedLayer && focusedLayer.parent !== layersParent)
                focusedLayer = focusedLayer.parent

            // reparent the overlay to the found layer
            overlayLayer.parent = focusedLayer ? focusedLayer : overlayLayer.parent
        }
    }

    Item {
        id: layersParent
        anchors.fill: parent

        Item {
            id: homeLayer
            z: comp != null && comp.homeActive ? 4 : 1
            anchors.fill: parent
        }

        Item {
            id: appLayer
            z: 2

            width: parent.width
            height: parent.height
            visible: comp != null && comp.appActive
        }

        Item {
            id: overlayLayer
            z: 5

            visible: comp != null && comp.appActive
        }

        Item {
            id: notificationLayer
            z: 6
        }

        Item {
            id: agentLayer
            z: 7
        }

        Item {
            id: alarmsLayer
            z: 3
        }
    }

    BorderGestureArea {
        id: gestureArea
        enabled: comp != null && comp.appActive
        z: 7
        anchors.fill: parent
        acceptsDown: true
        acceptsRight: comp != null && !comp.topmostWindowRequestsGesturesDisabled

        property real swipeThreshold: 0.15

        onGestureStarted: {
            swipeAnimation.stop()
            cancelAnimation.stop()
            if (gesture == "down") {
                Desktop.instance.onAboutToClose()
                state = "swipe"
            } else if(gesture == "right") {
                Desktop.instance.onAboutToMinimize()
                state = "swipe"
            }
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
            } else if (comp.homeActive){
                cancelAnimation.start()
            }
        }

        states: [
            State {
                name: "swipe"

                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }

                PropertyChanges {
                    target: comp != null ? (comp.topmostAlarmWindow == null ? appLayer : alarmsLayer) : null
                    opacity: (width-2*gestureArea.value)/width
                    x: gestureArea.horizontal ? gestureArea.value : 0
                    y: gestureArea.horizontal ? 0 : gestureArea.value
                }
            }
        ]

        SequentialAnimation {
            id: cancelAnimation

            NumberAnimation {
                target: gestureArea
                property: "value"
                to: 0
                duration: 200
                easing.type: Easing.OutQuint
            }

            PropertyAction {
                target: gestureArea
                property: "state"
                value: ""
            }
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

            PropertyAction {
                target: gestureArea
                property: "state"
                value: ""
            }
        }
    }

    Component {
        id: windowWrapper
        WindowWrapperBase { }
    }

    Component {
        id: alphaWrapper
        WindowWrapperAlpha { }
    }

    Timer {
        id: delayTimer
        interval: 5000
        repeat: false
        onTriggered: Lipstick.compositor.closeClientForWindowId(comp.topmostWindow.window.windowId)
    }

    Compositor {
        id: comp

        property Item homeWindow

        // Set to the item of the current topmost window
        property Item topmostWindow

        // Only used to change blank timeout when on watchface or elsewhere
        onHomeActiveChanged: lipstickSettings.lockscreenVisible = homeActive

        // True if the home window is the topmost window
        homeActive: topmostWindow == comp.homeWindow
        property bool appActive: !homeActive

        // The application window that was most recently topmost
        property Item topmostApplicationWindow
        property Item topmostAlarmWindow: null

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

            if (topmostWindow == homeWindow || topmostWindow == null) {
                clearKeyboardFocus()
            } else {
                if (topmostApplicationWindow) topmostApplicationWindow.visible = false
                topmostApplicationWindow = topmostWindow
                topmostApplicationWindow.visible = true
                if (!skipAnimation) topmostApplicationWindow.animateIn()
                w.window.takeFocus()
            }
        }

        onDisplayOff: {
            if (comp.topmostAlarmWindow == null)
                delayTimer.start()
        }

        onDisplayAboutToBeOn: delayTimer.stop()

        onWindowAdded: {
            var isHomeWindow = window.isInProcess && comp.homeWindow == null && window.title === "Home"
            var isDialogWindow = window.category === "dialog"
            var isNotificationWindow = window.category == "notification"
            var isOverlayWindow =  window.category == "overlay"
            var isAlarmWindow = window.category == "alarm"
            var isAgentWindow = window.category == "agent"
            var parent = null
            if (window.category == "cover") {
                window.visible = false
                return
            }
            if (isHomeWindow) {
                parent = homeLayer
            } else if (isNotificationWindow) {
                parent = notificationLayer
            } else if (isOverlayWindow){
                parent = overlayLayer
            } else if (isAgentWindow){
                parent = agentLayer
            } else if (isAlarmWindow) {
                parent = alarmsLayer
            } else {
                parent = appLayer
            }

            var w;
            if (isOverlayWindow) w = alphaWrapper.createObject(parent, { window: window })
            else w = windowWrapper.createObject(parent, { window: window })

            window.userData = w

            if (isHomeWindow) {
                comp.homeWindow = w
                setCurrentWindow(homeWindow)
            } else if (isNotificationWindow || isOverlayWindow || isAgentWindow) {

            } else if (isDialogWindow){
                setCurrentWindow(window)
            } else if (isAlarmWindow){
                comp.topmostAlarmWindow = window
                setCurrentWindow(window)
            } else {
                if (!comp.topmostAlarmWindow) {
                    setCurrentWindow(w)
                }
            }
        }

        onWindowRaised: {
            windowToFront(window.windowId)
        }

        onWindowRemoved: {
            var w = window.userData;
            if (window.category == "alarm") {
                comp.topmostAlarmWindow = null
                setCurrentWindow(comp.homeWindow)
            }
            if (comp.topmostWindow == w)
                setCurrentWindow(comp.homeWindow);

            if (window.userData)
                window.userData.destroy()
        }
    }
}
