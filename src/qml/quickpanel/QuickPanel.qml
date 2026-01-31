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

    property bool showingBrightness: false
    property bool showingVolume: false
    readonly property bool showingBattery: !showingBrightness && !showingVolume

    onShowingBrightnessChanged: {
        valueMeter.animate = true
        valueMeterCaption.animate = true
    }

    onShowingVolumeChanged: {
        valueMeter.animate = true
        valueMeterCaption.animate = true
    }

    readonly property int volume: volumeControl ? (volumeControl.maximumVolume ? Math.round((volumeControl.volume / volumeControl.maximumVolume) * 100) : 0) :0

    function setVolume(volume) {
        volumeControl.volume = Math.round((volume / 100) * volumeControl.maximumVolume);
    }

    readonly property bool isCharging: mceChargerType.type != MceChargerType.None

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

    BluetoothStatus {
        id: btStatus
        onPoweredChanged: bluetoothToggle.toggled = btStatus.powered
    }

    NetworkTechnology {
        id: wifiStatus
        path: "/net/connman/technology/wifi"
    }

    states: [
        State {
            name: "batteryBottom"
            when: options.value.batteryBottom

            AnchorChanges {
                target: fixedRow
                anchors.top: undefined
                anchors.bottom: slidingRow.top
            }
            PropertyChanges {
                target: fixedRow
                anchors.topMargin: 0
                anchors.bottomMargin: 0
            }

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
        },
        State {
            name: "batteryTop"
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
        }
    ]

    readonly property var toggleRegistry: {
        const map = {
            "lockButton": lockButtonComponent,
            "settingsButton": settingsButtonComponent,
            "brightnessToggle": brightnessToggleComponent,
            "bluetoothToggle": bluetoothToggleComponent,
            "hapticsToggle": hapticsToggleComponent,
            "cinemaToggle": cinemaToggleComponent,
            "aodToggle": aodToggleComponent,
            "powerOffToggle": powerOffToggleComponent,
            "rebootToggle": rebootToggleComponent,
            "musicButton": musicButtonComponent,
            "flashlightButton": flashlightButtonComponent
        };

        if (DeviceSpecs.hasWlan) {
            map["wifiToggle"] = wifiToggleComponent;
        }
        if (DeviceSpecs.hasSpeaker) {
            map["soundToggle"] = soundToggleComponent;
        }

        const toggles = {};
        for (const key in map) {
            if (toggleEnabled.value[key]) {
                toggles[key] = map[key];
            }
        }

        return toggles;
    }

    ListView {
        id: fixedRow
        anchors.horizontalCenter: parent.horizontalCenter
        width: toggleSize * 2 + spacing
        height: toggleSize
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        clip: true
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        spacing: Dims.l(4)

        readonly property var allToggles: {
            return fixedToggles.value
                .map(id => toggleRegistry[id])
                .filter(Boolean)
        }

        model: [allToggles]

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
                        sourceComponent: modelData
                    }
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Component.onCompleted: positionViewAtBeginning()
    }

    Connections {
        target: grid
        function onCurrentVerticalPosChanged() {
            if (grid.currentVerticalPos === -1) {
                slidingRow.positionViewAtBeginning()
            }
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

        readonly property var allToggles: {
            return sliderToggles.value
                .map(id => toggleRegistry[id])
                .filter(Boolean)
        }

        property int rowCount: Math.ceil(allToggles.length / 3)

        model: {
            const rows = [];
            for (let i = 0; i < allToggles.length; i += 3) {
                rows.push(allToggles.slice(i, i + 3));
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
                        sourceComponent: modelData
                    }
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Component.onCompleted: positionViewAtBeginning()

        onContentXChanged: {
            const newIndex = Math.round(contentX / width)
            if (newIndex >= 0 && newIndex < rowCount) currentIndex = newIndex
        }
    }

    ValueMeter {
        id: valueMeter
        width: toggleSize * 1.8
        height: Dims.l(8)
        valueLowerBound: 0
        valueUpperBound: 100
        anchors.horizontalCenter: parent.horizontalCenter

        value: showingBrightness ? displaySettings.brightness :
                                showingVolume ? volume :
                                batteryChargePercentage.percent

        // Signal to notify toggles to reset direction
        signal resetDirection

        // Animate value changes for smooth fill width transitions
        Behavior on value {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        isIncreasing: showingBattery ? isCharging : false
        enableAnimations: options.value.batteryAnimation && showingBattery
        particleDesign: options.value.particleDesign

        Timer {
            id: fadeOutTimer
            interval: 2000
            onTriggered: {
                // Reset display mode with explicit scope
                showingBrightness = false
                showingVolume = false

                // Signal toggles to reset direction
                valueMeter.resetDirection()
            }
        }

        opacity: animate ? 0 : 1

        property bool animate: false
        onOpacityChanged: animate = opacity > 0.5 ? animate : false

        // Opacity transitions for value change
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        fillColor: {
            if (!options.value.batteryColored) return Qt.rgba(1, 1, 1, 0.3)
            if (!showingBattery) return "#4CA6005F"

            const percent = batteryChargePercentage.percent
            if (percent <= 20) {
                const t = (20 - percent) / 20
                return Qt.rgba(1, 0.65 * (1 - t), 0, 0.3)
            }
            if (percent <= 50) {
                const t = (50 - percent) / 30
                return Qt.rgba(t, 1 - (t * 0.35), 0, 0.3)
            }
            return Qt.rgba(0, 1, 0, 0.3)
        }

        // Use behavior for fill color transitions
        Behavior on fillColor {
            ColorAnimation { duration: 300 }
        }
    }

    Label {
        id: valueMeterCaption
        anchors.horizontalCenter: parent.horizontalCenter

        font {
            pixelSize: Dims.l(9)
            family: "Noto Sans"
            styleName: "Condensed Medium"
        }

        opacity: animate ? 0 : (!isCharging ? 0.8 : 1.0)

        property bool animate: false
        onOpacityChanged: animate = opacity > 0.6 ? animate : false

        //% "Brightness"
        text: showingBrightness ? qsTrId("id-brightness") :
        //% "Volume"
            showingVolume ? qsTrId("id-volume") :
            batteryChargePercentage.percent + "%"

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
        visible: isCharging
        opacity: 1.0

        SequentialAnimation on opacity {
            running: isCharging && options.value.batteryAnimation
            loops: Animation.Infinite
            NumberAnimation { to: 0.7; duration: 1500; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutQuad }
        }
    }

    PageDot {
        id: pageDots
        height: Dims.l(4)
        anchors.horizontalCenter: parent.horizontalCenter
        currentIndex: slidingRow.currentIndex
        dotNumber: slidingRow.rowCount
        opacity: 0.5
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

            onPressAndHold: rangeValue = displaySettings.brightness

            onReleased: fadeOutTimer.restart()

            onRangeValueChanged: {
                displaySettings.brightness = rangeValue

                showingBrightness = true
                showingVolume = false

                fadeOutTimer.restart()
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
            onChecked: {
                profileControl.profile = "general";
                feedbackDelayTimer.start();
            }
            onUnchecked: profileControl.profile = "silent"

            Component.onCompleted: toggled = profileControl.profile == "general"

            Timer {
                id: feedbackDelayTimer
                interval: 125
                repeat: false
                onTriggered: feedback.play()
            }
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

                showingBrightness = false
                showingVolume = true

                fadeOutTimer.restart()
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

            Connections {
                target: volumeControl
                function onVolumeChanged() {
                    soundToggle.toggled = !(preMuteLevel.value > 0);
                }
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
            property bool actualState: isMuted && !alwaysOnDisplay.value;

            onActualStateChanged: toggled = actualState

            toggled: false
            onChecked: {
                // Store pre-cinema states
                preCinemaAodState.value = alwaysOnDisplay.value;
                // Mute sound if available
                if (DeviceSpecs.hasSpeaker && !isMuted) {
                    preMuteLevel.value = volume;
                    setVolume(0);
                }
                alwaysOnDisplay.value = false;
                displaySettings.lowPowerModeEnabled = false;
            }

            onUnchecked: {
                // Restore pre-cinema states
                alwaysOnDisplay.value = preCinemaAodState.value;
                displaySettings.lowPowerModeEnabled = alwaysOnDisplay.value;
                // Restore sound
                if (DeviceSpecs.hasSpeaker && isMuted) {
                    setVolume(preMuteLevel.value);
                    preMuteLevel.value = 0;
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
