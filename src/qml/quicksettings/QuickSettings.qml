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
import Nemo.Mce 1.0
import Nemo.DBus 2.0
import org.nemomobile.systemsettings 1.0
import Nemo.Ngf 1.0
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Connman 0.2
import QtGraphicalEffects 1.15


Item {
    id: rootitem
    width: parent.width
    height: parent.height

    property bool forbidLeft: true
    property bool forbidRight: true
    property int toggleSize: Dims.l(28)

    MceBatteryLevel {
        id: batteryChargePercentage
    }

    MceBatteryState {
        id: batteryChargeState
    }

    MceChargerType {
        id: mceChargerType
    }

    // Sync brightness toggle with display settings
    DisplaySettings {
        id: displaySettings
        onBrightnessChanged: updateBrightnessToggle()
    }

    NonGraphicalFeedback {
        id: feedback
        event: "press"
    }

    ProfileControl {
        id: profileControl
    }

    // Haptic feedback delay timer
    Timer {
        id: delayTimer
        interval: 125
        repeat: false
        onTriggered: feedback.play()
    }

    BluetoothStatus {
        id: btStatus
        onPoweredChanged: bluetoothToggle.toggled = btStatus.powered
    }

    NetworkTechnology {
        id: wifiStatus
        path: "/net/connman/technology/wifi"
    }

    function updateBrightnessToggle() {
        brightnessToggle.toggled = displaySettings.brightness > 80
    }

    Item {
        id: batteryMeter
        width: rootitem.width
        anchors.bottom: rootitem.bottom
        clip: true  // Clip contents to batteryMeter bounds

        // Base height based on battery percentage
        property real baseHeight: rootitem.height * (batteryChargePercentage.percent / 100)
        property real waveAmplitude: rootitem.height * 0.05  // Wave wiggle range (5% of screen height)
        property real waveTime: 0  // Timing for sine wave animation

        // Sine wave animation for top edge wiggle
        NumberAnimation on waveTime {
            from: 0
            to: 2 * Math.PI  // Full sine wave cycle
            duration: 3000  // Matches waveDown duration
            loops: Animation.Infinite
            running: true
        }

        height: baseHeight + waveAmplitude * Math.sin(waveTime)

        Rectangle {
            id: chargeLayer
            width: parent.width
            height: parent.height
            color: {
                if (batteryChargePercentage.percent < 10) return "red"
                else if (batteryChargePercentage.percent <= 30) return "orange"
                else return "green"
            }
            opacity: 0.33
            visible: mceChargerType.type != MceChargerType.None  // Charger connected

            Item {
                id: waveUp
                width: batteryMeter.width
                height: rootitem.height / 2  // Half screen height for subtle emission
                y: chargeLayer.height

                Rectangle {
                    id: waveUpBase
                    width: parent.width
                    height: parent.height
                    color: "#222222"
                    visible: false
                }

                LinearGradient {
                    anchors.fill: waveUpBase
                    source: waveUpBase
                    start: Qt.point(0, 0)
                    end: Qt.point(0, height)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00FFFFFF" }
                        GradientStop { position: 0.5; color: "#22FFFFFF" }
                        GradientStop { position: 1.0; color: "#00FFFFFF" }
                    }
                }

                NumberAnimation on y {
                    from: chargeLayer.height
                    to: -waveUp.height
                    duration: 1000
                    easing.type: Easing.OutSine
                    loops: Animation.Infinite
                    running: chargeLayer.visible
                }
            }
        }

        Rectangle {
            id: dischargeLayer
            width: parent.width
            height: parent.height
            color: {
                if (batteryChargePercentage.percent < 10) return "red"
                else if (batteryChargePercentage.percent <= 30) return "orange"
                else return "green"
            }
            opacity: 0.33
            visible: mceChargerType.type == MceChargerType.None  // No charger connected

            Item {
                id: waveDown
                width: batteryMeter.width
                height: rootitem.height / 2  // Half screen height for subtle emission
                y: -height

                Rectangle {
                    id: waveDownBase
                    width: parent.width
                    height: parent.height
                    color: "#222222"
                    visible: false
                }

                LinearGradient {
                    anchors.fill: waveDownBase
                    source: waveDownBase
                    start: Qt.point(0, 0)
                    end: Qt.point(0, height)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00FFFFFF" }
                        GradientStop { position: 0.5; color: "#22FFFFFF" }
                        GradientStop { position: 1.0; color: "#00FFFFFF" }
                    }
                }

                SequentialAnimation on y {
                    id: waveDownAnimation
                    loops: Animation.Infinite
                    running: dischargeLayer.visible
                    PauseAnimation {
                        duration: 1500  // Sync with downward peak of wiggle
                    }
                    NumberAnimation {
                        from: -waveDown.height
                        to: dischargeLayer.height
                        duration: 3000
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    Item {
        id: batteryChargeIndicator
        anchors.horizontalCenter: rootitem.horizontalCenter
        anchors.top: rootitem.top
        height: parent.height/4
        width: batteryIndicator.width
        opacity: mceChargerType.type == MceChargerType.None ? 0.4 : 0.8

        Label {
            id: batteryChargeText
            font {
                pixelSize: parent.height/5
                bold: true
            }
            text: mceChargerType.type == MceChargerType.None ? "Discharging" : "Charging"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Item {
        id: batteryPercent
        anchors.horizontalCenter: rootitem.horizontalCenter
        anchors.bottom: rootitem.bottom
        height: parent.height/4
        width: batteryIndicator.width
        opacity: mceChargerType.type == MceChargerType.None ? 0.4 : 0.8

        Label {
            id: batteryPercentText
            font {
                pixelSize: parent.height/3
                styleName: "SemiBold"
            }
            text: batteryChargePercentage.percent + "%"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Grid {
        id: quickSettingsGrid
        anchors.centerIn: parent
        rows: 2
        columns: 3
        spacing: Dims.l(2)

        QuickSettingsToggle {
            id: brightnessToggle
            width: toggleSize
            height: toggleSize
            icon: "ios-sunny"
            onChecked: displaySettings.brightness = 100
            onUnchecked: displaySettings.brightness = 0
            Component.onCompleted: updateBrightnessToggle()
        }

        QuickSettingsToggle {
            id: soundToggle
            width: toggleSize
            height: toggleSize
            icon: "ios-sound-indicator-high"
            toggled: true
        }

        QuickSettingsToggle {
            id: hapticsToggle
            width: toggleSize
            height: toggleSize
            icon: "ios-watch-vibrating"
            onChecked: {
                profileControl.profile = "general"
                delayTimer.start()
            }
            onUnchecked: profileControl.profile = "silent"
            Component.onCompleted: toggled = profileControl.profile == "general"
        }

        QuickSettingsToggle {
            id: wifiToggle
            width: toggleSize
            height: toggleSize
            icon: wifiStatus.connected ? "ios-wifi" : "ios-wifi-outline"
            toggled: wifiStatus.powered
            onChecked: wifiStatus.powered = true
            onUnchecked: wifiStatus.powered = false
            Component.onCompleted: Qt.callLater(function() { toggled = wifiStatus.powered })
            Connections {
                target: wifiStatus
                function onPoweredChanged() { wifiToggle.toggled = wifiStatus.powered }
            }
        }

        QuickSettingsToggle {
            id: bluetoothToggle
            width: toggleSize
            height: toggleSize
            icon: btStatus.connected ? "ios-bluetooth-connected" : "ios-bluetooth"
            onChecked: btStatus.powered = true
            onUnchecked: btStatus.powered = false
            Component.onCompleted: toggled = btStatus.powered
        }

        QuickSettingsToggle {
            id: settingsButton
            width: toggleSize
            height: toggleSize
            icon: "ios-settings"
        }
    }
}
