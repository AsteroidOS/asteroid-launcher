/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
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
import Nemo.Time 1.0
import Nemo.Configuration 1.0
import org.nemomobile.lipstick 0.1
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import org.asteroid.launcher 1.0
import "desktop.js" as Desktop

Item {
    id: desktop
    width: Dims.w(100)
    height: Dims.h(100)

    AppLauncherBackground { id: alb }

    property var defaultCenterColor: alb.centerColor("/usr/share/asteroid-launcher/default-colors.desktop")
    property var defaultOuterColor: alb.outerColor("/usr/share/asteroid-launcher/default-colors.desktop")

    property var bgCenterColor: defaultCenterColor
    property var bgOuterColor: defaultOuterColor

    property var launcherCenterColor: defaultCenterColor
    property var launcherOuterColor: defaultOuterColor

    property var displayAmbient: Lipstick.compositor.displayAmbient

    property var compositor: Lipstick.compositor

    Component.onCompleted: {
        Desktop.panelsGrid = grid
        LipstickSettings.lockScreen(true)
        if(firstRun.isFirstRun())
            firstRunComponent.createObject(desktop)
    }

    Component {
        id: firstRunComponent
        Item {
            anchors.fill: parent
            z: 8
            Tutorial { }
            FirstRunConfig { }
        }
    }

    ConfigurationValue {
        id: useBip
        key: "/org/asteroidos/settings/use-burn-in-protection"
        defaultValue: DeviceInfo.needsBurnInProtection
    }

    Item {
        id: burnInProtectionManager

        // Maximum offset before components from other grid becomes visible.
        property int maximumWidthOffset: Dims.w(27)
        property int maximumHeightOffset: Dims.h(27)

        property int leftOffset: Dims.w(2)
        property int rightOffset: Dims.w(2)
        property int topOffset: Dims.h(2)
        property int bottomOffset: Dims.h(2)

        // The maximum allowed movement in x and y direction.
        property int widthOffset
        property int heightOffset

        // Enable/disable burn in protection.
        enabled: DeviceInfo.needsBurnInProtection && useBip.value

        onHeightOffsetChanged: {
            topOffset = heightOffset/2
            bottomOffset = topOffset
        }

        onWidthOffsetChanged: {
            leftOffset = widthOffset/2
            rightOffset = leftOffset
        }

        onLeftOffsetChanged: if (leftOffset > maximumWidthOffset/2) leftOffset = maximumWidthOffset/2
        onRightOffsetChanged: if (rightOffset > maximumWidthOffset/2) rightOffset = maximumWidthOffset/2
        onTopOffsetChanged: if (topOffset > maximumHeightOffset/2) topOffset = maximumHeightOffset/2
        onBottomOffsetChanged: if (bottomOffset > maximumHeightOffset/2) bottomOffset = maximumHeightOffset/2

        function setActiveWatchFaceArea(x, y, w, h) {
            leftOffset = Math.min(x, maximumWidthOffset/2)
            topOffset = Math.min(y, maximumHeightOffset/2)
            rightOffset = Math.min(Dims.w(100)-w-x, maximumWidthOffset/2)
            bottomOffset = Math.min(Dims.h(100)-h-y, maximumHeightOffset/2)
        }
        function setCenterWatchFaceArea(w, h) {
            widthOffset = Dims.w(100)-w
            heightOffset = Dims.h(100)-h
        }
        function resetOffsets() {
            leftOffset = Dims.w(2)
            rightOffset = Dims.w(2)
            topOffset = Dims.h(2)
            bottomOffset = Dims.h(2)
        }
    }

    WallClock {
        id: wallClock
        enabled: true
        updateFrequency: WallClock.Second
    }

    ConfigurationValue {
        id: use12H
        key: "/org/asteroidos/settings/use-12h-format"
        defaultValue: false
    }

    Timer {
        id: wallClockAmbientTimeout
        interval: 200
        repeat: false
        onTriggered: Lipstick.compositor.setAmbientUpdatesEnabled(false)
    }

    Connections {
        target: Lipstick.compositor
        function onDisplayAboutToBeOn() {
            wallClockAmbientTimeout.stop()
            wallClock.enabled = true
        }
        function onDisplayAboutToBeOff() { wallClock.enabled = false }
        function onDisplayOn() {
            grid.animateIndicators()
            if (Lipstick.compositor.ambientEnabled) grid.moveTo(0, 0)
        }
        function onDisplayAmbientChanged() { wallpaperAnimation.duration = 300 }
        function onDisplayAmbientEntered() { wallpaperDarkener.opacity = 1 }
        function onDisplayAmbientLeft() {
            wallpaperDarkener.opacity = 0
            if (burnInProtectionManager.enabled) leftIndicator.anchors.verticalCenterOffset = 0
        }
        function onDisplayAmbientUpdate() {
            // Perform burn in protection
            if (burnInProtectionManager.enabled) {
                grid.contentX = Math.random()*(burnInProtectionManager.leftOffset + burnInProtectionManager.rightOffset)-burnInProtectionManager.leftOffset
                grid.contentY = Math.random()*(burnInProtectionManager.topOffset + burnInProtectionManager.bottomOffset)-burnInProtectionManager.topOffset

                leftIndicator.anchors.horizontalCenterOffset = (Math.random()*2)*leftIndicator.finWidth
                leftIndicator.anchors.verticalCenterOffset = (Math.random()-0.5)*4*leftIndicator.finWidth
            }
            // Give watchface some time to update, then go back to deep sleep.
            wallClockAmbientTimeout.start();
        }
    }

    ConfigurationValue {
        id: watchFaceSource
        key: "/desktop/asteroid/watchface"
        defaultValue: "file:///usr/share/asteroid-launcher/watchfaces/000-default-digital.qml"
        onValueChanged: burnInProtectionManager.resetOffsets()
    }

    Connections {
        target: localeManager
        function onChangesObserverChanged() {
            var bkp = watchFaceSource.value
            watchFaceSource.value = ""
            watchFaceSource.value = bkp
        }
    }

    Component { id: topPanel;    QuickSettings      { } }
    Component { id: leftPanel;   NotificationsPanel { panelsGrid: grid } }
    Component { id: centerPanel; Loader             { source: watchFaceSource.value } }
    Component { id: rightPanel;  Today              { } }
    Component { id: bottomPanel; AppLauncher        { } }

    PanelsGrid {
        id: grid 
        anchors.fill: parent
        Component.onCompleted: {
            addPanel(0, 0, centerPanel)
            var al = addPanel(0, 1, bottomPanel)
            addPanel(1, 0, rightPanel)
            var np = addPanel(-1, 0, leftPanel)
            addPanel(0, -1, topPanel)

            rightIndicator.visible  = Qt.binding(function() { return ((grid.toLeftAllowed   || (grid.currentVerticalPos == 1 && al.toLeftAllowed )) && !displayAmbient)})
            leftIndicator.visible   = Qt.binding(function() { return ((grid.toRightAllowed  || (grid.currentVerticalPos == 1 && al.toRightAllowed)) && (!displayAmbient || !np.modelEmpty))})
            topIndicator.visible    = Qt.binding(function() { return (grid.toBottomAllowed && !displayAmbient)   })
            bottomIndicator.visible = Qt.binding(function() { return (grid.toTopAllowed  && !displayAmbient)})

            leftIndicator.keepExpanded = Qt.binding(function() { return !np.modelEmpty && grid.currentHorizontalPos == 0 && grid.currentVerticalPos == 0 })

            Desktop.appLauncher = al
        }

        onNormalizedHorOffsetChanged: {
            if (displayAmbient) return
            wallpaperAnimation.duration = 0

            wallpaper.anchors.horizontalCenterOffset = normalizedHorOffset*width*(-0.05)
            wallpaperDarkener.opacity = Math.abs(normalizedHorOffset)*0.4
        }
        onNormalizedVerOffsetChanged: {
            if (!displayAmbient) {
                wallpaperAnimation.duration = 0

                wallpaper.anchors.verticalCenterOffset = height*normalizedVerOffset*(-0.05)
            }

            if(normalizedVerOffset == 1) {
                bgCenterColor = Qt.binding(function() { return launcherCenterColor })
                bgOuterColor = Qt.binding(function() { return launcherOuterColor })
            }

            else if(normalizedVerOffset > 0) {
                bgCenterColor = Qt.rgba(
                            launcherCenterColor.r * normalizedVerOffset + defaultCenterColor.r * (1-normalizedVerOffset),
                            launcherCenterColor.g * normalizedVerOffset + defaultCenterColor.g * (1-normalizedVerOffset),
                            launcherCenterColor.b * normalizedVerOffset + defaultCenterColor.b * (1-normalizedVerOffset)
                        );

                bgOuterColor = Qt.rgba(
                            launcherOuterColor.r * normalizedVerOffset + defaultOuterColor.r * (1-normalizedVerOffset),
                            launcherOuterColor.g * normalizedVerOffset + defaultOuterColor.g * (1-normalizedVerOffset),
                            launcherOuterColor.b * normalizedVerOffset + defaultOuterColor.b * (1-normalizedVerOffset)
                        );
            }
            else {
                bgCenterColor = Qt.binding(function() { return defaultCenterColor })
                bgOuterColor = Qt.binding(function() { return defaultOuterColor })
                if (!displayAmbient) wallpaperDarkener.opacity = Math.abs(normalizedVerOffset)*0.4
            }
        }
    }

    NotificationIndicator {
        id: notifIndic
        anchors.top: parent.top
        anchors.topMargin: Dims.h(5)
        height: Dims.h(8)
        width: parent.width
        panelsGrid: grid
    }

    Indicator { id: rightIndicator; edge: Qt.RightEdge }
    Indicator { id: leftIndicator; edge: Qt.LeftEdge }
    Indicator { id: topIndicator; edge: Qt.TopEdge }
    Indicator { id: bottomIndicator; edge: Qt.BottomEdge }

    Timer {
        id: lockscreenDelay
        interval: 150
        repeat: false
        onTriggered: Desktop.onAboutToClose()
    }

    Connections {
        target: Lipstick.compositor
        function onDisplayOff() { lockscreenDelay.start() }
     }

// Wallpaper
    ConfigurationValue {
        id: wallpaperSource
        key: "/desktop/asteroid/background-filename"
        defaultValue: "file:///usr/share/asteroid-launcher/wallpapers/000-flatmesh.qml"

        function updateWallpaper() {
            var endsWithQml = /qml$/;
            if (endsWithQml.test(wallpaperSource.value)) {
                wallpaperLoader.sourceComponent = undefined
                wallpaperLoader.source = wallpaperSource.value
            } else {
                wallpaperLoader.source = ""
                wallpaperLoader.sourceComponent = imageWallpaper
            }
        }

        Component.onCompleted: updateWallpaper()
        onValueChanged: updateWallpaper()
    }

    Item {
        id: wallpaper
        width: Dims.w(110)
        height:  Dims.h(110)
        z: -100
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Component {
            id: imageWallpaper
            Image { source: wallpaperSource.value }
        }

        Loader {
            id: wallpaperLoader
            anchors.fill: parent
        }
    }

    Rectangle {
        id: wallpaperDarkener
        anchors.fill: wallpaper
        z: -99
        color: "#000000"
        opacity: 0.0
        visible: opacity != 0.0
        Behavior on opacity { NumberAnimation { id:wallpaperAnimation } }
    }
}
