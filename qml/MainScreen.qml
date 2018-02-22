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
import org.asteroid.launcher 1.0
import "desktop.js" as Desktop

Item {
    id: desktop
    anchors.fill: parent;

    AppLauncherBackground { id: alb }

    property var defaultCenterColor: alb.centerColor("/usr/share/asteroid-launcher/default-colors.desktop")
    property var defaultOuterColor: alb.outerColor("/usr/share/asteroid-launcher/default-colors.desktop")

    property var bgCenterColor: defaultCenterColor
    property var bgOuterColor: defaultOuterColor

    property var launcherCenterColor: defaultCenterColor
    property var launcherOuterColor: defaultOuterColor

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

    Connections {
        target: Lipstick.compositor
        onDisplayAboutToBeOn: wallClock.enabled = true
        onDisplayAboutToBeOff: wallClock.enabled = false
    }

    ConfigurationValue {
        id: watchFaceSource
        key: "/desktop/asteroid/watchface"
        defaultValue: "file:///usr/share/asteroid-launcher/watchfaces/000-default-digital.qml"
    }

    Connections {
        target: localeManager
        onChangesObserverChanged: {
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

            rightIndicator.visible  = Qt.binding(function() { return grid.toLeftAllowed   || (grid.currentVerticalPos == 1 && al.toLeftAllowed )})
            leftIndicator.visible   = Qt.binding(function() { return grid.toRightAllowed  || (grid.currentVerticalPos == 1 && al.toRightAllowed)})
            topIndicator.visible    = Qt.binding(function() { return grid.toBottomAllowed    })
            bottomIndicator.visible = Qt.binding(function() { return grid.toTopAllowed })

            leftIndicator.keepExpanded = Qt.binding(function() { return !np.modelEmpty && grid.currentHorizontalPos == 0 && grid.currentVerticalPos == 0 })

            Desktop.appLauncher = al
        }

        onNormalizedHorOffsetChanged: {
                wallpaper.anchors.horizontalCenterOffset = normalizedHorOffset*width*(-0.05)
                wallpaperDarkener.opacity = Math.abs(normalizedHorOffset)*0.4
        }
        onNormalizedVerOffsetChanged: {
            wallpaper.anchors.verticalCenterOffset = height*normalizedVerOffset*(-0.05)

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
                wallpaperDarkener.opacity = Math.abs(normalizedVerOffset)*0.4
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
        onDisplayOff: lockscreenDelay.start();
     }

// Wallpaper
    ConfigurationValue {
        id: wallpaperSource
        key: "/desktop/asteroid/background-filename"
        defaultValue: "file:///usr/share/asteroid-launcher/wallpapers/000-flatmesh.qml"

        function updateWallpaper() {
            var endsWithQml = /qml$/;
            if(endsWithQml.test(wallpaperSource.value)) {
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
    }
}
