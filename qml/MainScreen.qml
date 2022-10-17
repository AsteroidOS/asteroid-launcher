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
import Nemo.Mce 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.systemsettings 1.0
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import org.asteroid.launcher 1.0
import "desktop.js" as Desktop

Item {
    id: desktop
    width: Dims.w(100)
    height: Dims.h(100)
    z: splash.visible ? 10 : 0

    visible: Lipstick.compositor.homeActive || aboutToOpen || aboutToClose || aboutToMinimize
    enabled: visible

    AppLauncherBackground { id: alb }

    property var defaultCenterColor: alb.centerColor("/usr/share/asteroid-launcher/default-colors.desktop")
    property var defaultOuterColor: alb.outerColor("/usr/share/asteroid-launcher/default-colors.desktop")

    property var bgCenterColor: defaultCenterColor
    property var bgOuterColor: defaultOuterColor

    property var launcherCenterColor: defaultCenterColor
    property var launcherOuterColor: defaultOuterColor
    property var launcherColorOverride: false

    property var displayAmbient: Lipstick.compositor.displayAmbient

    property var compositor: Lipstick.compositor

    property bool aboutToOpen: false
    property bool aboutToClose: false
    property bool aboutToMinimize: false

    /*
     * The nightstand property is for use by watchfaces to signal them to, for example,
     * enable a visual display of battery charge level, as with a ring around the perimeter
     * of the watch that wouldn't normally be displayed.
     */
    property alias nightstand: nightstandMode.active

    onAboutToCloseChanged: grid.moveTo(0, 0)
    onAboutToMinimizeChanged: grid.moveTo(0, 1)

    Component.onCompleted: {
        Desktop.desktop = desktop
        Desktop.panelsGrid = grid
        LipstickSettings.lockScreen(true)
        if(firstRun.isFirstRun())
            firstRunComponent.createObject(desktop)
    }

    Splash {
        id: splash
        z: 9
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

    MceCableState {
        id: mceCableState
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

    LauncherModel {
        id: launcherModel
    }

    DisplaySettings { 
        id: displaySettings
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

    ConfigurationValue {
        id: appLauncherSource
        key: "/desktop/asteroid/applauncher"
        defaultValue: "file:///usr/share/asteroid-launcher/applauncher/000-default-horizontal.qml"
    }

    ConfigurationValue {
        id: watchfaceNightstandSource
        key: "/desktop/asteroid/nightstand/watchface"
        defaultValue: "file:///usr/share/asteroid-launcher/watchfaces/005-analog-nordic.qml"
    }

    ConfigurationValue {
        id: nightstandBrightness
        key: "/desktop/asteroid/nightstand/brightness"
        defaultValue: 30
    }

    ConfigurationValue {
        id: nightstandDelay
        key: "/desktop/asteroid/nightstand/delay"
        defaultValue: 5
    }

    ConfigurationValue {
        id: nightstandEnabled
        key: "/desktop/asteroid/nightstand/enabled"
        defaultValue: false
    }

    Item {
        id: nightstandMode
        readonly property bool active: ready || nightstandDelayTimer.running
        readonly property bool ready: nightstandEnabled.value && mceCableState.connected
        property int oldBrightness: 100
        onReadyChanged: {
            if (ready) {
                if (nightstandDelayTimer.running) {
                    // timer was holding off, so cancel timer
                    nightstandDelayTimer.stop()
                } else {
                    // enter nightstand mode
                    oldBrightness = displaySettings.brightness
                    displaySettings.brightness = nightstandBrightness.value
                }
            } else {
                if (nightstandEnabled.value) {
                    // start off-charger timer
                    nightstandDelayTimer.restart()
                } else {
                    // mode disabled, so 
                    // exit nightstand mode immediately
                    nightstandDelayTimer.stop()
                    displaySettings.brightness = oldBrightness
                }
            }
        }
        Timer {
            id: nightstandDelayTimer
            interval: nightstandDelay.value * 1000
            repeat: false
            onTriggered: {
                // timer expired, so restore brightness
                displaySettings.brightness = nightstandMode.oldBrightness
            }
        }
    }

    Connections {
        target: localeManager
        function onChangesObserverChanged() {
            var watchFaceSourceBackup = watchFaceSource.value
            watchFaceSource.value = ""
            watchFaceSource.value = watchFaceSourceBackup
            var appLauncherSourceBackup = appLauncherSource.value
            appLauncherSource.value = ""
            appLauncherSource.value = appLauncherSourceBackup
        }
    }

    Component { id: topPanel;    QuickSettings      { } }
    Component { id: leftPanel;   NotificationsPanel { panelsGrid: grid } }
    Component { id: rightPanel;  Today              { } }
    Component {
        id: centerPanel;
        Item {
            property bool nightstandWatchfaceActive: nightstandMode.active && watchfaceNightstandSource.value != watchFaceSource.value
            Loader {
                id: nightstandWatchfaceLoader
                opacity: nightstandWatchfaceActive ? 1.0 : 0.0
                visible: opacity
                anchors.fill: parent
                source: watchfaceNightstandSource.value
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InCirc } }
            }
            Loader {
                id: watchfaceLoader
                opacity: !nightstandWatchfaceActive ? 1.0 : 0.0
                visible: opacity
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InCirc} }
                anchors.fill: parent
                source: watchFaceSource.value
            }
        }
    }
    Component {
        id: bottomPanel
        Loader {
            id: appLauncher
            property bool fakePressed:     false
            property bool toTopAllowed:    true
            property bool toBottomAllowed: true
            property bool toLeftAllowed:   true
            property bool toRightAllowed:  true
            property bool forbidTop: false
            property bool forbidBottom: false
            property bool forbidLeft: false
            property bool forbidRight: false
            source: appLauncherSource.value
            onStatusChanged: {
                if (appLauncher.status == Loader.Ready) {
                    Desktop.appLauncher = appLauncher.item
                }
            }
        }
    }

    onLauncherColorOverrideChanged: {
        if (launcherColorOverride) {
            bgCenterColor = Qt.binding(function() { return defaultCenterColor })
            bgOuterColor = Qt.binding(function() { return defaultOuterColor })
            wallpaperDarkener.opacity = Math.abs(grid.normalizedVerOffset)*0.4
        } else {
            if (normalizedVerOffset > 0) {
                bgCenterColor = Qt.binding(function() { return launcherCenterColor })
                bgOuterColor = Qt.binding(function() { return launcherOuterColor })
            }
            wallpaperDarkener.opacity = 0
        }
    }

    PanelsGrid {
        id: grid 
        anchors.fill: parent
        Component.onCompleted: {
            addPanel(0, 0, centerPanel)
            var al = addPanel(0, 1, bottomPanel)
            addPanel(1, 0, rightPanel)
            var np = addPanel(-1, 0, leftPanel)
            addPanel(0, -1, topPanel)

            rightIndicator.visible  = Qt.binding(function() { return ((grid.toLeftAllowed   || (grid.currentVerticalPos == 1 && al.toLeftAllowed ))   && !displayAmbient)})
            leftIndicator.visible   = Qt.binding(function() { return ((grid.toRightAllowed  || (grid.currentVerticalPos == 1 && al.toRightAllowed))   && (!displayAmbient || !np.modelEmpty))})
            topIndicator.visible    = Qt.binding(function() { return ((grid.toBottomAllowed || (grid.currentVerticalPos == 1 && al.toBottomAllowed )) && !displayAmbient)})
            bottomIndicator.visible = Qt.binding(function() { return ((grid.toTopAllowed    || (grid.currentVerticalPos == 1 && al.toTopAllowed ))    && !displayAmbient)})

            leftIndicator.keepExpanded = Qt.binding(function() { return !np.modelEmpty && grid.currentHorizontalPos == 0 && grid.currentVerticalPos == 0 })
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

            if(normalizedVerOffset == 1 && !launcherColorOverride) {
                bgCenterColor = Qt.binding(function() { return launcherCenterColor })
                bgOuterColor = Qt.binding(function() { return launcherOuterColor })
            }

            else if(normalizedVerOffset > 0 && !launcherColorOverride) {
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
        onTriggered: grid.moveTo(0, 0)
    }

    Connections {
        target: Lipstick.compositor
        function onDisplayOff() { lockscreenDelay.start() }
     }

// Wallpaper
    ConfigurationValue {
        id: wallpaperSource
        key: "/desktop/asteroid/background-filename"
        defaultValue: "file:///usr/share/asteroid-launcher/wallpapers/full/000-flatmesh.qml"

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
        visible: wallpaperDarkener.opacity != 1.0
        enabled: visible
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
