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
    property int toggleSize: Dims.l(28)

    MceBatteryLevel { id: batteryChargePercentage }
    MceBatteryState { id: batteryChargeState }
    MceChargerType { id: mceChargerType }

    ConfigurationValue {
        id: preMuteLevel
        key: "/desktop/asteroid/pre-mute-level"
        defaultValue: 0
    }

    ConfigurationValue {
        id: preCinemaAodState
        key: "/desktop/asteroid/quicksettings/pre-cinema-aod-state"
        defaultValue: true
    }

    ConfigurationValue {
        id: fixedToggles
        key: "/desktop/asteroid/quicksettings/fixed"
        defaultValue: ["lockButton", "settingsButton"]
    }

    ConfigurationValue {
        id: sliderToggles
        key: "/desktop/asteroid/quicksettings/slider"
        defaultValue: ["brightnessToggle", "bluetoothToggle", "hapticsToggle", "wifiToggle", "soundToggle", "cinemaToggle", "aodToggle", "powerOffToggle", "rebootToggle", "musicButton", "flashlightButton"]
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
        key: "/desktop/asteroid/quicksettings/options"
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
            "wifiToggle": { component: wifiToggleComponent, toggleAvailable: DeviceInfo.hasWlan },
            "soundToggle": { component: soundToggleComponent, toggleAvailable: DeviceInfo.hasSpeaker },
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

    Item {
        id: batteryMeter
        width: toggleSize * 1.8
        height: Dims.l(8)
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        states: [
            State {
                name: "topPosition"
                when: !options.value.batteryBottom
                AnchorChanges {
                    target: batteryMeter
                    anchors.top: undefined
                    anchors.bottom: slidingRow.top
                }
                PropertyChanges {
                    target: batteryMeter
                    anchors.topMargin: 0
                    anchors.bottomMargin: Dims.l(12)
                }
            },
            State {
                name: "bottomPosition"
                when: options.value.batteryBottom
                AnchorChanges {
                    target: batteryMeter
                    anchors.top: slidingRow.bottom
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: batteryMeter
                    anchors.topMargin: Dims.l(12)
                    anchors.bottomMargin: 0
                }
            }
        ]

        Rectangle {
            id: batteryOutline
            width: parent.width
            height: parent.height
            color: Qt.rgba(1, 1, 1, 0.2)
            radius: height / 2
        }

        Rectangle {
            id: batteryFill
            height: parent.height
            width: {
                var baseWidth = parent.width * (batteryChargePercentage.percent / 100)
                if (mceChargerType.type != MceChargerType.None && options.value.batteryAnimation && batteryFill.isVisible) {
                    var waveAmplitude = parent.width * 0.05
                    return baseWidth + waveAmplitude * Math.sin(waveTime)
                }
                return baseWidth
            }
            color: {
                if (!options.value.batteryColored) return Qt.rgba(1, 1, 1, 0.3) // Reduced alpha from 0.4
                var percent = batteryChargePercentage.percent
                if (percent > 50) return Qt.rgba(0, 1, 0, 0.3) // Reduced alpha from 0.4
                if (percent > 20) {
                    var t = (50 - percent) / 30
                    return Qt.rgba(t, 1 - (t * 0.35), 0, 0.3) // Reduced alpha from 0.4
                }
                var t = (20 - percent) / 20
                return Qt.rgba(1, 0.65 * (1 - t), 0, 0.3) // Reduced alpha from 0.4
            }
            anchors.left: parent.left
            opacity: 1.0
            clip: true

            property real waveTime: 0
            property bool isVisible: rootitem.visible && Qt.application.active

            NumberAnimation on waveTime {
                id: waveAnimation
                running: mceChargerType.type != MceChargerType.None && batteryFill.isVisible
                from: 0
                to: 2 * Math.PI
                duration: 1500
                loops: Animation.Infinite
            }

            SequentialAnimation on color {
                running: mceChargerType.type == MceChargerType.None && options.value.batteryAnimation && batteryChargePercentage.percent < 30 && batteryFill.isVisible
                loops: Animation.Infinite
                ColorAnimation {
                    to: options.value.batteryColored ? Qt.rgba(1, 0, 0, 0.7) : Qt.rgba(1, 1, 1, 0.7) // Reduced alpha from 0.8
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                ColorAnimation {
                    to: options.value.batteryColored ? Qt.rgba(1, 0, 0, 0.3) : Qt.rgba(1, 1, 1, 0.3) // Reduced alpha from 0.4
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            Item {
                id: particleContainer
                anchors.fill: parent
                visible: options.value.batteryAnimation

                property int particleCount: 5
                property bool isCharging: mceChargerType.type != MceChargerType.None
                property int activeParticles: 0
                // Track horizontal spawn alternation (0 = left half, 1 = right half)
                property int nextHorizontalBand: 0
                // Dynamic spawn interval based on charging state
                property int spawnInterval: 300

                Component {
                    id: cleanupTimerComponent
                    Timer {
                        id: cleanupTimer
                        interval: 0
                        running: true
                        repeat: false
                        onTriggered: {
                            particleContainer.activeParticles--;
                        }
                    }
                }

                function createParticle() {
                    if (!particleContainer.visible || !batteryFill.isVisible || activeParticles >= 16) {
                        return;
                    }
                    var component = Qt.createComponent("qrc:///org/asteroid/controls/qml/BatteryParticles.qml");
                    if (component.status === Component.Ready) {
                        var isCharging = mceChargerType.type != MceChargerType.None;
                        // Define speed (px/s) and calculate lifetime based on path length
                        var speed = isCharging ? 60 : 20; // 60px/s charging, 20px/s discharging
                        var pathLength = isCharging ? batteryFill.width / 2 : batteryFill.width;
                        var lifetime = isCharging ? 2500 : 8500; // Charging: +50% (~1667ms -> 2500ms), Discharging: -15% (~10000ms -> 8500ms)
                        particleContainer.spawnInterval = isCharging ? 200 : 750;
                        var maxSize = batteryFill.height / 2;
                        var minSize = batteryFill.height / 6;
                        var designType = options.value.particleDesign || "diamonds";
                        var isLogoOrFlash = designType === "logos" || designType === "flashes";
                        var sizeMultiplier = isLogoOrFlash ? 1.3 : 1.0;
                        var opacity = 0.6; // Unified maxOpacity

                        // Horizontal stratification: alternate between left (0) and right (1) halves
                        var horizontalBand = particleContainer.nextHorizontalBand;
                        var startX = isCharging ?
                            (horizontalBand === 0 ? Math.random() * (batteryFill.width / 4) : (batteryFill.width / 4) + Math.random() * (batteryFill.width / 4)) :
                            (horizontalBand === 0 ? batteryFill.width / 2 + Math.random() * (batteryFill.width / 4) : (3 * batteryFill.width / 4) + Math.random() * (batteryFill.width / 4));
                        particleContainer.nextHorizontalBand = (horizontalBand + 1) % 2; // Alternate

                        var endX = isCharging ?
                            startX + pathLength :
                            startX - pathLength;

                        var band = Math.floor(Math.random() * 3); // 0, 1, 2
                        var startY = (band * batteryFill.height / 3) + (Math.random() * batteryFill.height / 3);

                        var size = (minSize + Math.random() * (maxSize - minSize)) * sizeMultiplier;

                        var particle = component.createObject(particleContainer, {
                            "x": startX,
                            "y": startY,
                            "targetX": endX,
                            "maxSize": size,
                            "lifetime": lifetime,
                            "isCharging": isCharging,
                            "design": designType,
                            "opacity": opacity,
                            // Destroy if outside batteryFill bounds
                            "clipBounds": Qt.rect(0, 0, batteryFill.width, batteryFill.height)
                        });
                        if (particle !== null) {
                            activeParticles++;
                            var cleanupTimer = cleanupTimerComponent.createObject(particleContainer, {
                                "interval": lifetime
                            });
                        }
                    } else {
                        // Handle component loading failure silently
                    }
                }

                Timer {
                    id: particleTimer
                    interval: particleContainer.spawnInterval
                    running: batteryFill.width > 0 && options.value.batteryAnimation && particleContainer.visible && batteryFill.isVisible
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: {
                        particleContainer.createParticle();
                    }
                }
            }

            Connections {
                target: rootitem
                function onVisibleChanged() {
                    batteryFill.isVisible = rootitem.visible && Qt.application.active
                }
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
        opacity: mceChargerType.type == MceChargerType.None ? 0.6 : 0.9
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        states: [
            State {
                name: "topPosition"
                when: !options.value.batteryBottom
                AnchorChanges {
                    target: batteryPercentText
                    anchors.top: undefined
                    anchors.bottom: batteryMeter.top
                }
                PropertyChanges {
                    target: batteryPercentText
                    anchors.topMargin: 0
                    anchors.bottomMargin: Dims.l(1)
                }
            },
            State {
                name: "bottomPosition"
                when: options.value.batteryBottom
                AnchorChanges {
                    target: batteryPercentText
                    anchors.top: batteryMeter.bottom
                    anchors.bottom: undefined
                }
                PropertyChanges {
                    target: batteryPercentText
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
        text: batteryChargePercentage.percent + "%"

        Component.onCompleted: {
            if (options.value.batteryBottom) {
                anchors.top = batteryMeter.bottom
                anchors.topMargin = Dims.l(1)
            } else {
                anchors.bottom = batteryMeter.top
                anchors.bottomMargin = Dims.l(1)
            }
        }
    }

    Icon {
        id: flashIcon
        width: Dims.l(8)
        height: Dims.l(8)
        name: "ios-flash"
        anchors.centerIn: batteryMeter
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
        interval: 3000
        gaugeSegmentAmount: 6
        gaugeStartDegree: -130
        gaugeEndFromStartDegree: 265
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

                batteryMeter.anchors.top = slidingRow.bottom
                batteryMeter.anchors.topMargin = Dims.l(12)
                batteryMeter.anchors.bottom = undefined
                batteryMeter.anchors.bottomMargin = 0

                batteryPercentText.anchors.top = batteryMeter.bottom
                batteryPercentText.anchors.topMargin = Dims.l(1)
                batteryPercentText.anchors.bottom = undefined
                batteryPercentText.anchors.bottomMargin = 0

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

                batteryMeter.anchors.bottom = slidingRow.top
                batteryMeter.anchors.bottomMargin = Dims.l(12)
                batteryMeter.anchors.top = undefined
                batteryMeter.anchors.topMargin = 0

                batteryPercentText.anchors.bottom = batteryMeter.top
                batteryPercentText.anchors.bottomMargin = Dims.l(1)
                batteryPercentText.anchors.top = undefined
                batteryPercentText.anchors.topMargin = 0

                pageDots.anchors.bottom = slidingRow.top
                pageDots.anchors.bottomMargin = Dims.l(4)
                pageDots.anchors.top = undefined
                pageDots.anchors.topMargin = 0
            }
        }
    }

    Component {
        id: brightnessToggleComponent
        QuickSettingsToggle {
            id: brightnessToggle
            icon: "ios-sunny"
            onChecked: {
                if (displaySettings.brightness === 0) {
                    displaySettings.brightness = 100
                } else if (displaySettings.brightness < 100) {
                    displaySettings.brightness = 100
                }
            }
            onUnchecked: displaySettings.brightness = 0
            Component.onCompleted: toggled = displaySettings.brightness > 10

            property bool isIncreasing: true // Current direction for adjustment
            property string lastDirection: "increasing" // Persist last pressAndHold direction
            property int elapsedTime: 0 // Tracks elapsed time in ms
            property int frameCount: 0
            property int targetBrightness: 0 // Track desired brightness for updates
            property bool isReleased: false // Flag to prevent updates after release

            MouseArea {
                anchors.fill: parent
                pressAndHoldInterval: 300
                onClicked: parent.toggled ? parent.unchecked() : parent.checked()
                onPressAndHold: {
                    // Continue last direction unless at boundary
                    if (displaySettings.brightness === 100) {
                        isIncreasing = false
                        lastDirection = "decreasing"
                    } else if (displaySettings.brightness === 0) {
                        isIncreasing = true
                        lastDirection = "increasing"
                    } else {
                        isIncreasing = (lastDirection === "increasing")
                    }
                    elapsedTime = 0
                    frameCount = 0
                    targetBrightness = displaySettings.brightness
                    isReleased = false
                    brightnessHoldTimer.start()
                }
                onReleased: {
                    isReleased = true
                    brightnessHoldTimer.stop()
                }
            }

            Timer {
                id: brightnessHoldTimer
                interval: 300
                repeat: true
                onTriggered: {
                    frameCount++
                    elapsedTime += interval // Increment by timer interval (300ms)

                    // Skip brightness change if released
                    if (isReleased) {
                        return
                    }

                    // Calculate brightness change (10 units per 300ms)
                    var brightnessChange = 10 // Fixed 10-unit step per interval
                    if (brightnessChange > 0) {
                        var oldBrightness = displaySettings.brightness
                        if (isIncreasing) {
                            targetBrightness = Math.round(Math.min(100, targetBrightness + brightnessChange))
                            displaySettings.brightness = targetBrightness
                            if (displaySettings.brightness === 100) {
                                lastDirection = "decreasing" // Prepare to decrease next
                                brightnessHoldTimer.stop()
                            }
                        } else {
                            targetBrightness = Math.round(Math.max(0, targetBrightness - brightnessChange))
                            displaySettings.brightness = targetBrightness
                            if (displaySettings.brightness === 0) {
                                lastDirection = "increasing" // Prepare to increase next
                                brightnessHoldTimer.stop()
                            }
                        }
                    }
                }
            }

            Connections {
                target: displaySettings
                function onBrightnessChanged() {
                    brightnessToggle.toggled = displaySettings.brightness > 10
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
            id: cinemaToggle
            icon: "ios-film-outline"
            toggled: false
            onChecked: {
                // Store pre-cinema states
                preCinemaAodState.value = alwaysOnDisplay.value;
                // Mute sound if available
                if (DeviceInfo.hasSpeaker) {
                    var tempVolume = volumeControl.volume > 0 ? (volumeControl.volume / volumeControl.maximumVolume) * 100 : 0;
                    if (tempVolume > 0) {
                        preMuteLevel.value = tempVolume;
                        volumeControl.volume = 0;
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
                if (DeviceInfo.hasSpeaker && preMuteLevel.value > 0) {
                    volumeControl.volume = (preMuteLevel.value / 100) * volumeControl.maximumVolume;
                    preMuteLevel.value = 0;
                    unmuteSound.play();
                }
            }
            Component.onCompleted: {
                // Check initial state
                var isMuted = DeviceInfo.hasSpeaker ? preMuteLevel.value > 0 : true; // Consider muted if sound unavailable
                toggled = isMuted && displaySettings.brightness <= 10 && !alwaysOnDisplay.value;
            }
            Connections {
                target: preMuteLevel
                function onValueChanged() {
                    var isMuted = DeviceInfo.hasSpeaker ? preMuteLevel.value > 0 : true;
                    cinemaToggle.toggled = isMuted && displaySettings.brightness <= 10 && !alwaysOnDisplay.value;
                }
            }
            Connections {
                target: displaySettings
                function onBrightnessChanged() {
                    var isMuted = DeviceInfo.hasSpeaker ? preMuteLevel.value > 0 : true;
                    cinemaToggle.toggled = isMuted && displaySettings.brightness <= 10 && !alwaysOnDisplay.value;
                }
            }
            Connections {
                target: alwaysOnDisplay
                function onValueChanged() {
                    var isMuted = DeviceInfo.hasSpeaker ? preMuteLevel.value > 0 : true;
                    cinemaToggle.toggled = isMuted && displaySettings.brightness <= 10 && !alwaysOnDisplay.value;
                }
            }
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

    Component {
        id: musicButtonComponent
        QuickSettingsToggle {
            icon: "ios-musical-notes-outline"
            togglable: false
            toggled: true
            onChecked: appLauncher.launchApp("asteroid-music")
        }
    }

    Component {
        id: flashlightButtonComponent
        QuickSettingsToggle {
            icon: "ios-bulb-outline"
            togglable: false
            toggled: true
            onChecked: appLauncher.launchApp("asteroid-flashlight")
        }
    }

    Component {
        id: aodToggleComponent
        QuickSettingsToggle {
            icon: alwaysOnDisplay.value ? "ios-watch-aod-on" : "ios-watch-aod-off"
            toggled: alwaysOnDisplay.value
            onChecked: {
                alwaysOnDisplay.value = true;
                displaySettings.lowPowerModeEnabled = true;
            }
            onUnchecked: {
                alwaysOnDisplay.value = false;
                displaySettings.lowPowerModeEnabled = false;
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
        QuickSettingsToggle {
            icon: "ios-power"
            togglable: false
            toggled: true
            onChecked: {
                //% "Powering off in"
                remorseTimer.action = qsTrId("id-power-off");
                //% "Tap to cancel"
                remorseTimer.cancelText = qsTrId("id-tap-to-cancel");
                remorseTimer.start();
                remorseTimer.onTriggered.connect(function() {
                    login1DBus.call("PowerOff", [false]);
                });
            }
        }
    }

    Component {
        id: rebootToggleComponent
        QuickSettingsToggle {
            icon: "ios-refresh"
            togglable: false
            toggled: true
            onChecked: {
                //% "Rebooting in"
                remorseTimer.action = qsTrId("id-reboot");
                //% "Tap to cancel"
                remorseTimer.cancelText = qsTrId("id-tap-to-cancel");
                remorseTimer.start();
                remorseTimer.onTriggered.connect(function() {
                    login1DBus.call("SetRebootParameter", [""]);
                    login1DBus.call("Reboot", [false]);
                });
            }
        }
    }
}
