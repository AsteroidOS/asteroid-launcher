/*
 * Copyright (C) 2025 Timo Könnecke <github.com/eLtMosen>
 *               2015 Florent Revest <revestflo@gmail.com>
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
import QtGraphicalEffects 1.15
import QtMultimedia 5.8
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.Configuration 1.0
import Nemo.Mce 1.0
import Nemo.DBus 2.0
import Nemo.Ngf 1.0
import Connman 0.2

Item {
    id: rootitem
    width: parent.width
    height: parent.height

    property bool forbidLeft: true
    property bool forbidRight: true
    property int toggleSize: Dims.l(28)  // Increased toggle size

    MceBatteryLevel { id: batteryChargePercentage }
    MceBatteryState { id: batteryChargeState }
    MceChargerType { id: mceChargerType }

    ConfigurationValue {
        id: preMuteLevel
        key: "/desktop/asteroid/pre-mute-level"
        defaultValue: 0
    }

    ConfigurationValue {
        id: topToggles
        key: "/desktop/asteroid/quicksettings/top"
        defaultValue: ["lockButton", "settingsButton"]
    }

    ConfigurationValue {
        id: mainToggles
        key: "/desktop/asteroid/quicksettings/main"
        defaultValue: ["brightnessToggle", "bluetoothToggle", "hapticsToggle", "wifiToggle", "soundToggle", "cinemaToggle"]
    }

    ConfigurationValue {
        id: toggleEnabled
        key: "/desktop/asteroid/quicksettings/enabled"
        defaultValue: {
            "lockButton": true,
            "settingsButton": true,
            "brightnessToggle": true,
            "bluetoothToggle": true,
            "hapticsToggle": true,
            "wifiToggle": true,
            "soundToggle": true,
            "cinemaToggle": true
        }
    }

    DBusInterface {
        id: mce_dbus
        service: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"
        bus: DBus.SystemBus
    }

    DisplaySettings { id: displaySettings }
    NonGraphicalFeedback { id: feedback; event: "press" }
    ProfileControl { id: profileControl }

    SoundEffect {
        id: unmuteSound
        source: "file:///usr/share/sounds/notification.wav"
        volume: 0.8
    }

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

    ListView {
        id: topButtonsView
        anchors {
            bottom: quickSettingsView.top
            horizontalCenter: parent.horizontalCenter
        }
        width: toggleSize * 2 + spacing // Two toggles
        height: toggleSize
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        clip: true
        interactive: false // No scrolling needed for two items
        boundsBehavior: Flickable.StopAtBounds
        spacing: Dims.l(4)

        property var toggleRegistry: ({
            "lockButton": { component: lockButtonComponent, toggleAvailable: true },
            "settingsButton": { component: settingsButtonComponent, toggleAvailable: true },
            "brightnessToggle": { component: brightnessToggleComponent, toggleAvailable: true },
            "bluetoothToggle": { component: bluetoothToggleComponent, toggleAvailable: true },
            "hapticsToggle": { component: hapticsToggleComponent, toggleAvailable: true },
            "wifiToggle": { component: wifiToggleComponent, toggleAvailable: DeviceInfo.hasWlan },
            "soundToggle": { component: soundToggleComponent, toggleAvailable: DeviceInfo.hasSpeaker },
            "cinemaToggle": { component: cinemaToggleComponent, toggleAvailable: true }
        })

        property var allToggles: {
            var toggles = [];
            var usedIds = [];
            for (var i = 0; i < topToggles.value.length; i++) {
                var toggleId = topToggles.value[i];
                if (toggleId && toggleRegistry[toggleId] && toggleRegistry[toggleId].toggleAvailable && toggleEnabled.value[toggleId] && usedIds.indexOf(toggleId) === -1) {
                    toggles.push(toggleRegistry[toggleId]);
                    usedIds.push(toggleId);
                }
            }
            return toggles;
        }

        property var availableToggles: allToggles
        property int rowCount: 1 // Always one row

        model: [availableToggles] // Single row of two or fewer toggles

        contentWidth: width

        delegate: Item {
            id: pageItem
            width: topButtonsView.width
            height: topButtonsView.height

            Row {
                id: toggleRow
                spacing: Dims.l(8)
                Repeater {
                    model: modelData
                    delegate: Loader {
                        width: toggleSize - Dims.l(4)
                        height: width
                        sourceComponent: modelData.component
                    }
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Component.onCompleted: positionViewAtBeginning()
    }

    ListView {
        id: quickSettingsView
        anchors.centerIn: parent
        width: toggleSize * 3 + spacing * 2
        height: toggleSize
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: Dims.l(4)

        property var toggleRegistry: topButtonsView.toggleRegistry

        property var allToggles: {
            var toggles = [];
            var usedIds = [];
            for (var i = 0; i < mainToggles.value.length; i++) {
                var toggleId = mainToggles.value[i];
                if (toggleId && toggleRegistry[toggleId] && toggleRegistry[toggleId].toggleAvailable && toggleEnabled.value[toggleId] && usedIds.indexOf(toggleId) === -1) {
                    toggles.push(toggleRegistry[toggleId]);
                    usedIds.push(toggleId);
                }
            }
            return toggles;
        }

        property var availableToggles: allToggles
        property int rowCount: Math.ceil(availableToggles.length / 3)

        model: {
            var rows = [];
            for (var i = 0; i < availableToggles.length; i += 3) {
                rows.push(availableToggles.slice(i, i + 3));
            }
            return rows;
        }

        contentWidth: width * rowCount

        delegate: Item {
            id: pageItem
            width: quickSettingsView.width
            height: quickSettingsView.height

            Row {
                id: toggleRow
                spacing: quickSettingsView.spacing
                Repeater {
                    model: modelData
                    delegate: Loader {
                        width: toggleSize
                        height: toggleSize
                        sourceComponent: modelData.component
                    }
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Component.onCompleted: positionViewAtBeginning()

        onContentXChanged: {
            var newIndex = Math.round(contentX / width)
            if (newIndex >= 0 && newIndex < rowCount) currentIndex = newIndex
        }
    }

    Item {
        id: batteryMeter
        width: toggleSize * 1.8
        height: Dims.l(8)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: quickSettingsView.bottom
        anchors.topMargin: Dims.l(12)

        Rectangle {
            id: batteryOutline
            width: parent.width
            height: parent.height
            color: "#FFF"
            opacity: 0.2
            radius: height / 2
        }

        Rectangle {
            id: batteryFill
            height: parent.height
            width: {
                var baseWidth = parent.width * (batteryChargePercentage.percent / 100)
                if (mceChargerType.type != MceChargerType.None) {
                    var waveAmplitude = parent.width * 0.05
                    return baseWidth + waveAmplitude * Math.sin(waveTime)
                }
                return baseWidth
            }
            color: "#FFF"
            anchors.left: parent.left
            opacity: mceChargerType.type == MceChargerType.None ? 0.4 : 0.45

            property real waveTime: 0

            NumberAnimation on waveTime {
                id: waveAnimation
                running: mceChargerType.type != MceChargerType.None
                from: 0
                to: 2 * Math.PI
                duration: 1500
                loops: Animation.Infinite
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: batteryMeter.width
                height: batteryMeter.height
                Rectangle { anchors.fill: parent; radius: batteryOutline.radius }
            }
        }
    }

    Label {
        id: batteryPercentText
        opacity: mceChargerType.type == MceChargerType.None ? 0.4 : 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: batteryMeter.bottom
        anchors.topMargin: Dims.l(1)
        font {
            pixelSize: Dims.l(8)
            family: "Noto Sans"
            styleName: "Condensed Medium"
        }
        text: batteryChargePercentage.percent + "%"
    }

    Icon {
        id: flashIcon
        width: Dims.l(8)
        height: Dims.l(8)
        name: "ios-flash"
        anchors.centerIn: batteryMeter
        y: -Dims.l(10)
        visible: mceChargerType.type != MceChargerType.None
    }

    PageDot {
        id: pageDots
        height: Dims.l(4)
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: quickSettingsView.bottom
            topMargin: Dims.l(4)
        }
        currentIndex: quickSettingsView.currentIndex
        dotNumber: quickSettingsView.rowCount
        opacity: 0.5
    }

    Component {
        id: brightnessToggleComponent
        QuickSettingsToggle {
            id: brightnessToggle
            icon: "ios-sunny"
            onChecked: displaySettings.brightness = 100
            onUnchecked: displaySettings.brightness = 0
            Component.onCompleted: toggled = displaySettings.brightness > 80

            Connections {
                target: displaySettings
                function onBrightnessChanged() {
                    brightnessToggle.toggled = displaySettings.brightness > 80
                }
            }
        }
    }

    Component {
        id: hapticsToggleComponent
        QuickSettingsToggle {
            icon: "ios-watch-vibrating"
            onChecked: { profileControl.profile = "general"; delayTimer.start() }
            onUnchecked: profileControl.profile = "silent"
            Component.onCompleted: toggled = profileControl.profile == "general"
        }
    }

    Component {
        id: wifiToggleComponent
        QuickSettingsToggle {
            icon: wifiStatus.connected ? "ios-wifi" : "ios-wifi-outline"
            toggled: wifiStatus.powered
            onChecked: wifiStatus.powered = true
            onUnchecked: wifiStatus.powered = false
            Component.onCompleted: Qt.callLater(function() { toggled = wifiStatus.powered })
            Connections { target: wifiStatus; function onPoweredChanged() { toggled = wifiStatus.powered } }
        }
    }

    Component {
        id: bluetoothToggleComponent
        QuickSettingsToggle {
            icon: btStatus.connected ? "ios-bluetooth-connected" : "ios-bluetooth"
            onChecked: btStatus.powered = true
            onUnchecked: btStatus.powered = false
            Component.onCompleted: toggled = btStatus.powered
        }
    }

    Component {
        id: soundToggleComponent
        QuickSettingsToggle {
            id: soundToggle
            function linearVolume() {
                if (volumeControl.volume <= 0 || volumeControl.maximumVolume <= 0)
                    return 0;
                return Math.round((volumeControl.volume / volumeControl.maximumVolume) * 100);
            }

            function toPulseVolume(linear) {
                return Math.round((linear / 100) * volumeControl.maximumVolume);
            }

            icon: preMuteLevel.value > 0 ? "ios-sound-indicator-mute" :
                  volumeControl.volume > toPulseVolume(70) ? "ios-sound-indicator-high" :
                  volumeControl.volume > toPulseVolume(30) ? "ios-sound-indicator-mid" :
                  volumeControl.volume > 0 ? "ios-sound-indicator-low" : "ios-sound-indicator-off"

            onChecked: {
                var tempVolume = linearVolume();
                volumeControl.volume = toPulseVolume(preMuteLevel.value);
                preMuteLevel.value = tempVolume;
                unmuteSound.play();
            }

            onUnchecked: {
                var tempVolume = linearVolume();
                volumeControl.volume = toPulseVolume(preMuteLevel.value);
                preMuteLevel.value = tempVolume;
            }

            Component.onCompleted: {
                toggled = !(preMuteLevel.value > 0);
            }

            Connections {
                target: volumeControl
                function onVolumeChanged() {
                    soundToggle.icon = preMuteLevel.value > 0 ? "ios-sound-indicator-mute" :
                                       volumeControl.volume > toPulseVolume(70) ? "ios-sound-indicator-high" :
                                       volumeControl.volume > toPulseVolume(30) ? "ios-sound-indicator-mid" :
                                       volumeControl.volume > 0 ? "ios-sound-indicator-low" : "ios-sound-indicator-off";
                }
            }

            Connections {
                target: preMuteLevel
                function onValueChanged() {
                    soundToggle.toggled = !(preMuteLevel.value > 0);
                    soundToggle.icon = preMuteLevel.value > 0 ? "ios-sound-indicator-mute" :
                                       volumeControl.volume > toPulseVolume(70) ? "ios-sound-indicator-high" :
                                       volumeControl.volume > toPulseVolume(30) ? "ios-sound-indicator-mid" :
                                       volumeControl.volume > 0 ? "ios-sound-indicator-low" : "ios-sound-indicator-off";
                }
            }
        }
    }

    Component {
        id: cinemaToggleComponent
        QuickSettingsToggle {
            icon: "ios-film-outline"
            toggled: true
        }
    }

    Component {
        id: lockButtonComponent
        QuickSettingsToggle {
            id: lockedToggle
            icon: "ios-unlock"
            togglable: false
            toggled: true
            onChecked: mce_dbus.call("req_display_state_lpm", undefined)
        }
    }

    Component {
        id: settingsButtonComponent
        QuickSettingsToggle {
            icon: "ios-settings"
            togglable: false
            toggled: true
            onChecked: appLauncher.launchApp("asteroid-settings")
        }
    }
}
