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
import org.asteroid.launcher 1.0
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
    property int toggleSize: Dims.l(28)

    MceBatteryLevel { id: batteryChargePercentage }
    MceBatteryState { id: batteryChargeState }
    MceChargerType { id: mceChargerType }

    readonly property int volume: volumeControl.maximumVolume ? Math.round((volumeControl.volume / volumeControl.maximumVolume) * 100) : 0

    function setVolume(volume) {
        volumeControl.volume = Math.round((volume / 100) * volumeControl.maximumVolume);
    }

    AppLauncher { id: appLauncher }

    ConfigurationValue {
        id: preMuteLevel
        key: "/desktop/asteroid/pre-mute-level"
        defaultValue: 0
    }

    ConfigurationValue {
        id: preCinemaAodState
        key: "/desktop/asteroid/quickpanel/pre-cinema-aod-state"
        defaultValue: true
    }

    ConfigurationValue {
        id: fixedToggles
        key: "/desktop/asteroid/quickpanel/fixed"
        defaultValue: ["lockButton", "settingsButton"]
    }

    ConfigurationValue {
        id: sliderToggles
        key: "/desktop/asteroid/quickpanel/slider"
        defaultValue: ["brightnessToggle", "bluetoothToggle", "hapticsToggle", "wifiToggle", "soundToggle", "cinemaToggle", "aodToggle", "powerOffToggle", "rebootToggle", "musicButton", "flashlightButton"]
    }

    ConfigurationValue {
        id: toggleEnabled
        key: "/desktop/asteroid/quickpanel/enabled"
        defaultValue: {
            "lockButton": true,
            "settingsButton": true,
            "brightnessToggle": true,
            "bluetoothToggle": true,
            "hapticsToggle": true,
            "wifiToggle": true,
            "soundToggle": true,
            "cinemaToggle": true,
            "aodToggle": true,
            "powerOffToggle": true,
            "rebootToggle": true,
            "musicButton": false,
            "flashlightButton": false
        }
    }

    ConfigurationValue {
        id: options
        key: "/desktop/asteroid/quickpanel/options"
        defaultValue: {
            "batteryBottom": true,
            "batteryAnimation": true,
            "batteryColored": false,
            "particleDesign": "diamonds"
        }
    }

    DBusInterface {
        id: mce_dbus
        service: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"
        bus: DBus.SystemBus
    }

    DBusInterface {
        id: login1DBus
        bus: DBus.SystemBus
        service: "org.freedesktop.login1"
        path: "/org/freedesktop/login1"
        iface: "org.freedesktop.login1.Manager"
    }

    NonGraphicalFeedback { id: feedback; event: "press" }
    ProfileControl { id: profileControl }
    DisplaySettings { id: displaySettings }

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
        id: fixedRow
        anchors {
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

        states: [
            State {
                name: "topPosition"
                when: !options.value.batteryBottom
                AnchorChanges {
                    target: fixedRow
                    anchors.top: slidingRow.bottom
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: fixedRow
                    anchors.topMargin: Dims.l(4)
                    anchors.bottomMargin: 0
                }
            },
            State {
                name: "bottomPosition"
                when: options.value.batteryBottom
                AnchorChanges {
                    target: fixedRow
                    anchors.top: undefined
                    anchors.bottom: slidingRow.top
                }
                PropertyChanges {
                    target: fixedRow
                    anchors.topMargin: 0
                    anchors.bottomMargin: Dims.l(0)
                }
            }
        ]

        property var toggleRegistry: ({
            "lockButton": { component: lockButtonComponent, toggleAvailable: true },
            "settingsButton": { component: settingsButtonComponent, toggleAvailable: true },
            "brightnessToggle": { component: brightnessToggleComponent, toggleAvailable: true },
            "bluetoothToggle": { component: bluetoothToggleComponent, toggleAvailable: true },
            "hapticsToggle": { component: hapticsToggleComponent, toggleAvailable: true },
            "wifiToggle": { component: wifiToggleComponent, toggleAvailable: DeviceSpecs.hasWlan },
            "soundToggle": { component: soundToggleComponent, toggleAvailable: DeviceSpecs.hasSpeaker },
            "cinemaToggle": { component: cinemaToggleComponent, toggleAvailable: true },
            "aodToggle": { component: aodToggleComponent, toggleAvailable: true },
            "powerOffToggle": { component: powerOffToggleComponent, toggleAvailable: true },
            "rebootToggle": { component: rebootToggleComponent, toggleAvailable: true },
            "musicButton": { component: musicButtonComponent, toggleAvailable: true },
            "flashlightButton": { component: flashlightButtonComponent, toggleAvailable: true }
        })

        property var allToggles: {
            var toggles = [];
            var usedIds = [];
            for (var i = 0; i < fixedToggles.value.length; i++) {
                var toggleId = fixedToggles.value[i];
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
            width: fixedRow.width
            height: fixedRow.height

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

        Component.onCompleted: {
            positionViewAtBeginning()
        }
    }

    ListView {
        id: slidingRow
        anchors.centerIn: parent
        width: toggleSize * 3 + spacing * 2
        height: toggleSize
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: Dims.l(4)

        property var toggleRegistry: fixedRow.toggleRegistry

        property var allToggles: {
            var toggles = [];
            var usedIds = [];
            for (var i = 0; i < sliderToggles.value.length; i++) {
                var toggleId = sliderToggles.value[i];
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
            width: slidingRow.width
            height: slidingRow.height

            Row {
                id: toggleRow
                spacing: slidingRow.spacing
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

    ValueMeter {
        id: valueMeter
        width: toggleSize * 1.8
        height: Dims.l(8)
        valueLowerBound: 0
        valueUpperBound: 100

        // Signal to notify toggles to reset direction
        signal resetDirection

        // Use a property for volume to avoid direct soundToggle reference
        property int volumeValue: 0

        // Force update the value with separate property to ensure binding triggers
        property int currentValue: showingBrightness ? displaySettings.brightness :
                                showingVolume ? volumeValue :
                                batteryChargePercentage.percent

        // Use onCurrentValueChanged to ensure the value is updated
        onCurrentValueChanged: {
            value = currentValue
        }

        // Animate value changes for smooth fill width transitions
        Behavior on value {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        isIncreasing: showingBrightness || showingVolume ? false : mceChargerType.type != MceChargerType.None
        enableAnimations: options.value.batteryAnimation && !(showingBrightness || showingVolume) // Particles only for battery
        enableColoredFill: options.value.batteryColored
        particleDesign: options.value.particleDesign
        property bool showingBrightness: false
        property bool showingVolume: false

        Timer {
            id: fadeOutTimer
            interval: 2000
            onTriggered: {
                // Reset display mode with explicit scope
                valueMeter.showingBrightness = false
                valueMeter.showingVolume = false
                valueMeterCaption.showingBrightness = false
                valueMeterCaption.showingVolume = false

                // Signal toggles to reset direction
                valueMeter.resetDirection()

                // Transition opacity
                valueMeter.opacity = 0.5
                valueMeterCaption.opacity = 0.3

                // Start fade-in timer
                fadeInTimer.start()
            }
        }

        Timer {
            id: fadeInTimer
            interval: 250
            onTriggered: {
                // Restore opacity
                valueMeter.opacity = 1.0
                valueMeterCaption.opacity = mceChargerType.type == MceChargerType.None ? 0.8 : 1.0
            }
        }

        // Opacity transitions for value change
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        fillColor: {
            if (!options.value.batteryColored) return Qt.rgba(1, 1, 1, 0.3)
            if (showingBrightness) return "#4CA6005F" // Purple with 0.3 alpha
            if (showingVolume) return "#4C9800A6" // Blue with 0.3 alpha
            var percent = batteryChargePercentage.percent
            if (percent > 50) return Qt.rgba(0, 1, 0, 0.3)
            if (percent > 20) {
                var t = (50 - percent) / 30
                return Qt.rgba(t, 1 - (t * 0.35), 0, 0.3)
            }
            var t = (20 - percent) / 20
            return Qt.rgba(1, 0.65 * (1 - t), 0, 0.3)
        }

        // Use behavior for fill color transitions
        Behavior on fillColor {
            ColorAnimation { duration: 300 }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: options.value.batteryBottom ? slidingRow.bottom : undefined
            bottom: !options.value.batteryBottom ? slidingRow.top : undefined
            topMargin: options.value.batteryBottom ? Dims.l(12) : 0
            bottomMargin: !options.value.batteryBottom ? Dims.l(12) : 0
        }

        states: [
            State {
                name: "topPosition"
                when: !options.value.batteryBottom
                AnchorChanges {
                    target: valueMeter
                    anchors.top: undefined
                    anchors.bottom: slidingRow.top
                }
                PropertyChanges {
                    target: valueMeter
                    anchors.topMargin: 0
                    anchors.bottomMargin: Dims.l(12)
                }
            },
            State {
                name: "bottomPosition"
                when: options.value.batteryBottom
                AnchorChanges {
                    target: valueMeter
                    anchors.top: slidingRow.bottom
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: valueMeter
                    anchors.topMargin: Dims.l(12)
                    anchors.bottomMargin: 0
                }
            }
        ]
    }

    Label {
        id: valueMeterCaption
        opacity: mceChargerType.type == MceChargerType.None ? 0.8 : 1.0
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: options.value.batteryBottom ? valueMeter.bottom : undefined
            bottom: !options.value.batteryBottom ? valueMeter.top : undefined
            topMargin: options.value.batteryBottom ? Dims.l(1) : 0
            bottomMargin: !options.value.batteryBottom ? Dims.l(1) : 0
        }

        states: [
            State {
                name: "topPosition"
                when: !options.value.batteryBottom
                AnchorChanges {
                    target: valueMeterCaption
                    anchors.top: undefined
                    anchors.bottom: valueMeter.top
                }
                PropertyChanges {
                    target: valueMeterCaption
                    anchors.topMargin: 0
                    anchors.bottomMargin: Dims.l(1)
                }
            },
            State {
                name: "bottomPosition"
                when: options.value.batteryBottom
                AnchorChanges {
                    target: valueMeterCaption
                    anchors.top: valueMeter.bottom
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: valueMeterCaption
                    anchors.topMargin: Dims.l(1)
                    anchors.bottomMargin: 0
                }
            }
        ]

        font {
            pixelSize: Dims.l(9)
            family: "Noto Sans"
            styleName: "Condensed Medium"
        }

        property bool showingBrightness: false
        property bool showingVolume: false
        //% "Brightness"
        text: showingBrightness ? qsTrId("id-brightness") :
        //% "Volume"
            showingVolume ? qsTrId("id-volume") :
            batteryChargePercentage.percent + "%"

        // Timer to handle text transitions
        property Timer textFadeInTimer: Timer {
            interval: 250
            onTriggered: {
                valueMeterCaption.opacity = mceChargerType.type == MceChargerType.None ? 0.8 : 1.0
            }
        }

        // Monitor state changes to trigger opacity transitions
        onShowingBrightnessChanged: {
            if (showingBrightness) {
                opacity = 0.3
                textFadeInTimer.start()
            }
        }

        onShowingVolumeChanged: {
            if (showingVolume) {
                opacity = 0.3
                textFadeInTimer.start()
            }
        }

        // Opacity transitions for text change
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Icon {
        id: flashIcon
        width: Dims.l(8)
        height: Dims.l(8)
        name: "ios-flash"
        anchors.centerIn: valueMeter
        y: -Dims.l(10)
        visible: mceChargerType.type != MceChargerType.None
        opacity: 1.0

        SequentialAnimation on opacity {
            running: mceChargerType.type != MceChargerType.None && options.value.batteryAnimation
            loops: Animation.Infinite
            NumberAnimation { to: 0.7; duration: 1500; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutQuad }
        }
    }

    PageDot {
        id: pageDots
        height: Dims.l(4)
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        states: [
            State {
                name: "topPosition"
                when: !options.value.batteryBottom
                AnchorChanges {
                    target: pageDots
                    anchors.top: undefined
                    anchors.bottom: slidingRow.top
                }
                PropertyChanges {
                    target: pageDots
                    anchors.topMargin: 0
                    anchors.bottomMargin: Dims.l(4)
                }
            },
            State {
                name: "bottomPosition"
                when: options.value.batteryBottom
                AnchorChanges {
                    target: pageDots
                    anchors.top: slidingRow.bottom
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: pageDots
                    anchors.topMargin: Dims.l(4)
                    anchors.bottomMargin: 0
                }
            }
        ]

        currentIndex: slidingRow.currentIndex
        dotNumber: slidingRow.rowCount
        opacity: 0.5

        Component.onCompleted: {
            if (options.value.batteryBottom) {
                anchors.top = slidingRow.bottom
                anchors.topMargin = Dims.l(4)
            } else {
                anchors.bottom = slidingRow.top
                anchors.bottomMargin = Dims.l(4)
            }
        }
    }

    RemorseTimer {
        id: remorseTimer
        duration: 3000
        gaugeSegmentAmount: 6
        gaugeStartDegree: -130
        gaugeEndFromStartDegree: 265
        //% "Tap to cancel"
        cancelText: qsTrId("id-tap-to-cancel")
    }

    // Initialize components on options value change
    Connections {
        target: options
        function onValueChanged() {
            if (options.value.batteryBottom) {
                // Bottom configuration
                fixedRow.anchors.bottom = slidingRow.top
                fixedRow.anchors.bottomMargin = Dims.l(0)
                fixedRow.anchors.top = undefined
                fixedRow.anchors.topMargin = 0

                valueMeter.anchors.top = slidingRow.bottom
                valueMeter.anchors.topMargin = Dims.l(12)
                valueMeter.anchors.bottom = undefined
                valueMeter.anchors.bottomMargin = 0

                valueMeterCaption.anchors.top = valueMeter.bottom
                valueMeterCaption.anchors.topMargin = Dims.l(1)
                valueMeterCaption.anchors.bottom = undefined
                valueMeterCaption.anchors.bottomMargin = 0

                pageDots.anchors.top = slidingRow.bottom
                pageDots.anchors.topMargin = Dims.l(4)
                pageDots.anchors.bottom = undefined
                pageDots.anchors.bottomMargin = 0
            } else {
                // Top configuration
                fixedRow.anchors.top = slidingRow.bottom
                fixedRow.anchors.topMargin = Dims.l(4)
                fixedRow.anchors.bottom = undefined
                fixedRow.anchors.bottomMargin = 0

                valueMeter.anchors.bottom = slidingRow.top
                valueMeter.anchors.bottomMargin = Dims.l(12)
                valueMeter.anchors.top = undefined
                valueMeter.anchors.topMargin = 0

                valueMeterCaption.anchors.bottom = valueMeter.top
                valueMeterCaption.anchors.bottomMargin = Dims.l(1)
                valueMeterCaption.anchors.top = undefined
                valueMeterCaption.anchors.topMargin = 0

                pageDots.anchors.bottom = slidingRow.top
                pageDots.anchors.bottomMargin = Dims.l(4)
                pageDots.anchors.top = undefined
                pageDots.anchors.topMargin = 0
            }
        }
    }

Component {
        id: brightnessToggleComponent
        QuickPanelToggle {
            id: brightnessToggle
            icon: "ios-sunny"
            rangeBased: true
            rangeMin: 0
            rangeMax: 100
            rangeStepSize: 10

            onChecked: displaySettings.brightness = rangeMax
            onUnchecked: displaySettings.brightness = rangeMin
            Component.onCompleted: toggled = displaySettings.brightness > 10

            function showInValueMeter() {
                if (!valueMeter.showingBrightness) {
                    valueMeter.opacity = 0.5
                    valueMeterCaption.opacity = 0.3

                    valueMeter.showingBrightness = true
                    valueMeterCaption.showingBrightness = true
                    valueMeter.showingVolume = false
                    valueMeterCaption.showingVolume = false

                    fadeInTimer.start()
                }
                fadeOutTimer.restart()
            }

            onPressAndHold: rangeValue = displaySettings.brightness

            onReleased: fadeOutTimer.restart()

            onRangeValueChanged: {
                displaySettings.brightness = rangeValue
                showInValueMeter()
            }

            Connections {
                target: displaySettings
                function onBrightnessChanged() {
                    brightnessToggle.toggled = displaySettings.brightness > 10
                }
            }

            Connections {
                target: valueMeter
                function onResetDirection() {
                    isIncreasing = true
                }
            }
        }
    }

    Component {
        id: hapticsToggleComponent
        QuickPanelToggle {
            icon: "ios-watch-vibrating"
            onChecked: { profileControl.profile = "general"; delayTimer.start() }
            onUnchecked: profileControl.profile = "silent"
            Component.onCompleted: toggled = profileControl.profile == "general"
        }
    }

    Component {
        id: wifiToggleComponent
        QuickPanelToggle {
            icon: wifiStatus.connected ? "ios-wifi" : "ios-wifi-outline"
            onChecked: wifiStatus.powered = true
            onUnchecked: wifiStatus.powered = false

            Connections {
                target: wifiStatus
                function onPoweredChanged() {
                    toggled = wifiStatus.powered
                }
            }
        }
    }

    Component {
        id: bluetoothToggleComponent
        QuickPanelToggle {
            icon: btStatus.connected ? "ios-bluetooth-connected" : "ios-bluetooth"
            onChecked: btStatus.powered = true
            onUnchecked: btStatus.powered = false
            Component.onCompleted: toggled = btStatus.powered
        }
    }

    Component {
        id: soundToggleComponent
        QuickPanelToggle {
            id: soundToggle

            rangeBased: true
            rangeMin: 0
            rangeMax: 100
            rangeStepSize: 10

            onPressAndHold: {
                rangeValue = volume

                if (preMuteLevel.value > 0) {
                    const tempVolume = volume;
                    setVolume(preMuteLevel.value);
                    preMuteLevel.value = tempVolume;

                    toggled = true;
                }
            }

            onReleased: {
                fadeOutTimer.restart()

                if (volume > 0 && preMuteLevel.value === 0) {
                    soundDelayTimer.start();
                }
            }

            onRangeValueChanged: {
                setVolume(rangeValue);
                showInValueMeter();
            }

            icon: preMuteLevel.value > 0 ? "ios-sound-indicator-mute" :
                  volume > 70 ? "ios-sound-indicator-high" :
                  volume > 30 ? "ios-sound-indicator-mid" :
                  volume > 0 ? "ios-sound-indicator-low" : "ios-sound-indicator-off"

            onClicked: {
                const tempVolume = volume;
                const targetVolume = preMuteLevel.value;
                setVolume(targetVolume);
                preMuteLevel.value = tempVolume;

                if (targetVolume > 0) {
                    soundDelayTimer.start();
                }
            }

            Component.onCompleted: toggled = !(preMuteLevel.value > 0)

            Timer {
                id: soundDelayTimer
                interval: 150
                repeat: false
                onTriggered: unmuteSound.play()
            }

            function showInValueMeter() {
                if (!valueMeter.showingVolume) {
                    valueMeter.opacity = 0.5
                    valueMeterCaption.opacity = 0.3

                    valueMeter.showingBrightness = false
                    valueMeterCaption.showingBrightness = false
                    valueMeter.showingVolume = true
                    valueMeterCaption.showingVolume = true

                    fadeInTimer.start()
                }
                fadeOutTimer.restart()
                valueMeter.volumeValue = volume
            }

            Connections {
                target: preMuteLevel
                function onValueChanged() {
                    soundToggle.toggled = !(preMuteLevel.value > 0);
                }
            }

            Connections {
                target: valueMeter
                function onResetDirection() {
                    isIncreasing = true
                }
            }
        }
    }

    Component {
        id: cinemaToggleComponent
        QuickPanelToggle {
            id: cinemaToggle
            icon: "ios-film-outline"

            property bool isMuted: DeviceSpecs.hasSpeaker ? preMuteLevel.value > 0 : true
            property bool actualState: isMuted && displaySettings.brightness <= 10 && !alwaysOnDisplay.value;

            onActualStateChanged: toggled = actualState

            toggled: false
            onChecked: {
                // Store pre-cinema states
                preCinemaAodState.value = alwaysOnDisplay.value;
                // Mute sound if available
                if (DeviceSpecs.hasSpeaker) {
                    if (volume > 0) {
                        preMuteLevel.value = volume;
                        setVolume(0);
                    }
                }
                displaySettings.brightness = 10;
                alwaysOnDisplay.value = false;
                displaySettings.lowPowerModeEnabled = false;
            }

            onUnchecked: {
                // Restore pre-cinema states
                displaySettings.brightness = 100;
                alwaysOnDisplay.value = preCinemaAodState.value;
                displaySettings.lowPowerModeEnabled = alwaysOnDisplay.value;
                // Restore sound
                if (DeviceSpecs.hasSpeaker && preMuteLevel.value > 0) {
                    setVolume(preMuteLevel.value);
                    preMuteLevel.value = 0;
                    unmuteSound.play();
                }
            }
        }
    }

    Component {
        id: lockButtonComponent
        QuickPanelToggle {
            id: lockedToggle
            icon: "ios-unlock"
            togglable: false
            toggled: true
            onChecked: mce_dbus.call("req_display_state_lpm", undefined)
        }
    }

    Component {
        id: settingsButtonComponent
        QuickPanelToggle {
            icon: "ios-settings"
            togglable: false
            toggled: true
            onChecked: appLauncher.launchApp("asteroid-settings")
        }
    }

    Component {
        id: musicButtonComponent
        QuickPanelToggle {
            icon: "ios-musical-notes-outline"
            togglable: false
            toggled: true
            onChecked: appLauncher.launchApp("asteroid-music")
        }
    }

    Component {
        id: flashlightButtonComponent
        QuickPanelToggle {
            icon: "ios-bulb-outline"
            togglable: false
            toggled: true
            onChecked: appLauncher.launchApp("asteroid-flashlight")
        }
    }

    Component {
        id: aodToggleComponent
        QuickPanelToggle {
            icon: alwaysOnDisplay.value ? "ios-watch-aod-on" : "ios-watch-aod-off"
            toggled: alwaysOnDisplay.value

            onToggledChanged: {
                alwaysOnDisplay.value = toggled;
                displaySettings.lowPowerModeEnabled = toggled;
            }

            Connections {
                target: alwaysOnDisplay
                function onValueChanged() {
                    toggled = alwaysOnDisplay.value;
                }
            }
        }
    }

    Component {
        id: powerOffToggleComponent
        QuickPanelToggle {
            icon: "ios-power"
            togglable: false
            toggled: true
            onChecked: {
                //% "Powering off in"
                remorseTimer.action = qsTrId("id-power-off");
                remorseTimer.onTriggered.connect(function() {
                    login1DBus.call("PowerOff", [false]);
                });
                remorseTimer.start();
            }
        }
    }

    Component {
        id: rebootToggleComponent
        QuickPanelToggle {
            icon: "ios-refresh"
            togglable: false
            toggled: true
            onChecked: {
                //% "Rebooting in"
                remorseTimer.action = qsTrId("id-reboot");
                remorseTimer.onTriggered.connect(function() {
                    login1DBus.call("SetRebootParameter", [""]);
                    login1DBus.call("Reboot", [false]);
                });
                remorseTimer.start();
            }
        }
    }
}
