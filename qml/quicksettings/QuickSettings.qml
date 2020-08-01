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
import org.freedesktop.contextkit 1.0
import Nemo.DBus 2.0
import org.nemomobile.systemsettings 1.0
import Nemo.Ngf 1.0
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Item {
    id: rootitem
    width: parent.width
    height: parent.height

    property bool forbidLeft:  true
    property bool forbidRight: true

    ContextProperty {
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        value: "100"
        Component.onCompleted: batteryChargePercentage.subscribe()
    }

    ContextProperty {
        id: batteryIsCharging
        key: "Battery.IsCharging"
        value: false
    }

    DBusInterface {
        id: mce_dbus

        service: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"

        bus: DBus.SystemBus
    }

    QuickSettingsToggle {
        id: lockedToggle
        anchors.top: rootitem.top
        anchors.horizontalCenter: rootitem.horizontalCenter
        icon: "ios-unlock"
        togglable: false
        toggled: false
        onUnchecked: mce_dbus.call("req_display_state_lpm", undefined)
    }

    DisplaySettings {
        id: displaySettings
        onBrightnessChanged: updateBrightnessToggle()
    }

    QuickSettingsToggle {
        id: brightnessToggle
        anchors.left: rootitem.left
        anchors.verticalCenter: rootitem.verticalCenter
        icon: "ios-sunny"
        onChecked: displaySettings.brightness = 100
        onUnchecked: displaySettings.brightness = 0
        Component.onCompleted: updateBrightnessToggle()
    }

    function updateBrightnessToggle() {
        brightnessToggle.toggled = displaySettings.brightness > 80
    }

    BluetoothStatus {
        id: btStatus
        onPoweredChanged: bluetoothToggle.toggled = btStatus.powered
    }

    QuickSettingsToggle {
        id: bluetoothToggle
        anchors.centerIn: parent
        icon: btStatus.connected ? "ios-bluetooth-connected" : "ios-bluetooth"
        onChecked:   btStatus.powered = true
        onUnchecked: btStatus.powered = false
        Component.onCompleted: toggled = btStatus.powered
    }

    NonGraphicalFeedback {
        id: feedback
        event: "press"
    }

    ProfileControl {
         id: profileControl
    }

    Timer {
        id: delayTimer
        interval: 125
        repeat: false
        onTriggered: feedback.play()
    }

    QuickSettingsToggle {
        id: hapticsToggle
        anchors.right: rootitem.right
        anchors.verticalCenter: rootitem.verticalCenter
        icon: "ios-watch-vibrating"
        onChecked: {
            profileControl.profile = "general";
            delayTimer.start();
        }
        onUnchecked: profileControl.profile = "silent";
        Component.onCompleted: toggled = profileControl.profile == "general"
    }

    Item {
        id: battery
        anchors.horizontalCenter: rootitem.horizontalCenter
        anchors.bottom: rootitem.bottom
        height: parent.height/3
        width: batteryIcon.width + batteryIndicator.width

        Icon {
            id: batteryIcon
            name: {
                if(batteryIsCharging.value)                 return "ios-battery-charging"
                else if(batteryChargePercentage.value > 15) return "ios-battery-full"
                else                                        return "ios-battery-dead"
            }
            width:  parent.height/2
            height: width
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }
        Label {
            id: batteryIndicator
            font.pixelSize: parent.height/4
            text: batteryChargePercentage.value + "%"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
