/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Window 2.1
import org.nemomobile.time 1.0
import org.nemomobile.configuration 1.0
import org.freedesktop.contextkit 1.0

Page {

    // This is used in the favorites page and in the lock screen
    WallClock {
        id: wallClock
        enabled: true /* XXX: Disable when display is off */
        updateFrequency: WallClock.Minute
    }
    // This is used in the lock screen
    ConfigurationValue {
        id: wallpaperSource
        key: desktop.isPortrait ? "/desktop/meego/background/portrait/picture_filename" : "/desktop/meego/background/landscape/picture_filename"
        defaultValue: "images/graphics-wallpaper-home.jpg"
    }
    id: desktop

    // Implements back key navigation
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            if (pageStack.depth > 1) {
                pageStack.pop();
                event.accepted = true;
            } else { Qt.quit(); }
        }
    }
    Connections {
        target: batterystatus
        onValueChanged: {
            if(batterystatus.value > 85) {
                batteryimg.source = "images/battery6.png"
            } else if (batterystatus.value <= 70) {
                batteryimg.source = "images/battery5.png"
            } else if (batterystatus.value <= 55) {
                batteryimg.source = "images/battery4.png"
            } else if (batterystatus.value <= 40) {
                batteryimg.source = "images/battery3.png"
            } else if (batterystatus.value <= 25) {
                batteryimg.source = "images/battery2.png"
            } else if (batterystatus.value <= 10) {
                batteryimg.source = "images/battery1.png"
            } else if (batterystatus.value <= 5) {
                batteryimg.source = "images/battery0.png"
            }
            batterylbl.text = batterystatus.value + "%"
        }
    }

    ContextProperty {
        id: batterystatus
        key: "Battery.ChargePercentage"
        value: "100"
    }

    tools: Item {
        Image {
            id: batteryimg
            width: 32
            height: 32
        }
        Label {
            anchors.left: batteryimg.right
            id: batterylbl
            color: "black"
            font.pointSize: 8
        }
    }

    Pager {
        id: pager

        scale: 0.7 + 0.3 * lockScreen.openingState
        opacity: lockScreen.openingState

        anchors.fill: parent

        model: VisualItemModel {
            AppLauncher {
                id: launcher
                height: pager.height
            }
            AppSwitcher {
                id: switcher
                width: pager.width
                height: pager.height
                visibleInHome: x > -width && x < desktop.width
            }
        }

        // Initial view should be the AppLauncher
        currentIndex: 1
    }
    Lockscreen {
        id: lockScreen

        width: parent.width
        height: parent.height

        z: 200

        onOpeningStateChanged: {
            // When fully closed, reset the current page
            if (openingState !== 0)
                return

            // Focus the switcher if any applications are running, otherwise the launcher
            if (switcher.runningAppsCount > 0) {
                pager.currentIndex = 2
            } else {
                pager.currentIndex = 1
            }
        }
    }
}
