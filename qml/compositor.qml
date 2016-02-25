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

Compositor {
    id: root

    property Item homeWindow

    // Set to the item of the current topmost window
    property Item topmostWindow

    // True if the home window is the topmost window
    homeActive: topmostWindow == root.homeWindow
    property bool appActive: !homeActive

    // The application window that was most recently topmost
    property Item topmostApplicationWindow
    property Item topmostAlarmWindow: null

    readonly property bool topmostWindowRequestsGesturesDisabled: topmostWindow && topmostWindow.window
                                                                  && topmostWindow.window.surface
                                                                  && (topmostWindow.window.surface.windowFlags & 1)

    function windowToFront(winId) {
        var o = root.windowForId(winId)
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

    onSensorOrientationChanged: {
        screenOrientation = sensorOrientation
    }

    Connections {
        target: root
        onActiveFocusItemChanged: {
            // Search for the layer of the focus item
            var focusedLayer = root.activeFocusItem
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
            z: root.homeActive ? 4 : 1
            anchors.fill: parent
        }

        Item {
            id: appLayer
            z: 2

            width: parent.width
            height: parent.height
            visible: root.appActive
        }

        Item {
            id: overlayLayer
            z: 5

            visible: root.appActive
        }

        Item {
            id: notificationLayer
            z: 6
        }
        Item {
            id: alarmsLayer
            z: 3
        }
    }

    BorderGestureArea {
        id: gestureArea
        z: 7
        anchors.fill: parent
        enabled: !topmostWindowRequestsGesturesDisabled


        property real swipeThreshold: 0.15

        onGestureStarted: {
            swipeAnimation.stop()
            cancelAnimation.stop()
            if ((gesture == "down" || gesture == "right") && root.appActive) {
                state = "swipe"
            }
        }

        onGestureFinished: {
            if ((gesture == "down" || gesture == "right") && root.appActive) {
                if (gestureArea.progress >= swipeThreshold) {
                    swipeAnimation.valueTo = inverted ? -max : max
                    swipeAnimation.start()
                    if (gesture == "down") {
                        Lipstick.compositor.closeClientForWindowId(topmostWindow.window.windowId)
                    }
                } else {
                    cancelAnimation.start()
                }
            } else if (root.homeActive){
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
                    target: root.topmostAlarmWindow == null ? appLayer : alarmsLayer
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
                script: setCurrentWindow(root.homeWindow)
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

    Component {
        id: mysticWrapper
        WindowWrapperMystic { }
    }

    onDisplayOff:
        if (root.topmostAlarmWindow == null)
            setCurrentWindow(root.homeWindow)

    onWindowAdded: {
        console.log("Compositor: Window added \"" + window.title + "\"" + " category: " + window.category)

        var isHomeWindow = window.isInProcess && root.homeWindow == null && window.title === "Home"
        var isDialogWindow = window.category === "dialog"
        var isNotificationWindow = window.category == "notification"
        var isOverlayWindow =  window.category == "overlay"
        var isAlarmWindow = window.category == "alarm"
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
            root.homeWindow = w
            setCurrentWindow(homeWindow)
        } else if (isNotificationWindow || isOverlayWindow) {

        } else if (isDialogWindow){
            setCurrentWindow(window)
        } else if (isAlarmWindow){
            root.topmostAlarmWindow = window
            w = mysticWrapper.createObject(parent, {window: window})
            window.userData = w
            setCurrentWindow(w)
        } else {
            if (!root.topmostAlarmWindow) {
                w = mysticWrapper.createObject(parent, {window: window})
                window.userData = w
                setCurrentWindow(w)
            }
        }
    }

    onWindowRaised: {
        console.log("Compositor: Raising window: " + window.title + " category: " + window.category)
        windowToFront(window.windowId)
    }

    onWindowRemoved: {
        console.log("Compositor: Window removed \"" + window.title + "\"" + " category: " + window.category)
        Desktop.instance.switcher.switchModel.removeWindowForTitle(window.title)
        var w = window.userData;
        if (window.category == "alarm") {
            root.topmostAlarmWindow = null
            setCurrentWindow(root.homeWindow)
        }
        if (root.topmostWindow == w)
            setCurrentWindow(root.homeWindow);

        if (window.userData)
            window.userData.destroy()
    }
}
