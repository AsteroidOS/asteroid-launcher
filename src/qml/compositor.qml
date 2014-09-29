// Copyright (C) 2013 Jolla Ltd.
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
import org.nemomobile.lipstick 0.1

import "compositor"
import "scripts/desktop.js" as Desktop

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

    ScreenGestureArea {
        id: gestureArea
        z: 7
        anchors.fill: parent


        property real swipeThreshold: 0.15
        property real lockThreshold: 0.25

        onGestureStarted: {
            swipeAnimation.stop()
            cancelAnimation.stop()
            lockAnimation.stop()
            if (root.appActive) {
                state = "swipe"
            } else if (root.homeActive) {
                state = "lock"
            }
        }

        onGestureFinished: {
            if (root.appActive) {
                if (gestureArea.progress >= swipeThreshold) {
                    swipeAnimation.valueTo = inverted ? -max : max
                    swipeAnimation.start()
                    if (gestureArea.gesture == "down") {
                        Lipstick.compositor.closeClientForWindowId(topmostWindow.window.windowId)
                    }
                } else {
                    cancelAnimation.start()
                }
            } else if (root.homeActive){
                if (gestureArea.progress >= lockThreshold) {
                    lockAnimation.valueTo = (gestureArea.gesture == "left" ?
                                                 Desktop.instance.lockscreen.width :
                                                 -Desktop.instance.lockscreen.width)
                    lockAnimation.start()
                    // Locks or unlocks depending if the screen is locked.
                    if (!Desktop.instance.lockscreenVisible()) {
                        Desktop.instance.setLockScreen(true)
                    } else {
                        Desktop.instance.setLockScreen(false)
                    }
                } else {
                    cancelAnimation.start()
                }
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
            },
            State {
                name: "lock"
                PropertyChanges {
                    target: Desktop.instance.lockscreen
                    visible: true
                }
                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }
                PropertyChanges {
                    target: Desktop.instance.lockscreen
                    x: gestureArea.horizontal ? (Desktop.instance.lockscreenVisible()?(gestureArea.value):
                                                                                       (gestureArea.gesture == "right" ?
                                                                                       -Desktop.instance.lockscreen.width+Math.abs(gestureArea.value) :
                                                                                       Desktop.instance.lockscreen.width+gestureArea.value) ) : 0
                    y: gestureArea.horizontal ? 0 : (Desktop.instance.lockscreenVisible()?(gestureArea.value):
                                                                                       (gestureArea.gesture == "down" ?
                                                                                       -Desktop.instance.lockscreen.height+Math.abs(gestureArea.value) :
                                                                                       Desktop.instance.lockscreen.height+gestureArea.value) )
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
            id: lockAnimation
            property alias valueTo: valueAnimationLock.to

            SmoothedAnimation {
                id: valueAnimationLock
                target: Desktop.instance.lockscreen
                property: "x"
                easing.type: Easing.OutQuint
            }

            ScriptAction {
                script: Desktop.instance.setLockScreen(Desktop.instance.lockscreenVisible())
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
