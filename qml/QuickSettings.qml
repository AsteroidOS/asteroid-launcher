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

import QtQuick 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.freedesktop.contextkit 1.0
import MeeGo.Connman 0.2

Item {
    id: rootitem
    width: parent.width
    height: parent.height

    Connections {
        target: lipstickSettings;
        onLockscreenVisibleChanged: {
            if(lipstickSettings.lockscreenVisible) {
                batteryChargePercentage.subscribe()
            } else {
                batteryChargePercentage.unsubscribe()
            }
        }
    }

    ContextProperty {
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        value: "100"
    }

    NetworkManager {
        id: networkManager
        function updateTechnologies() {
            if (available && technologiesEnabled) {
                bt.path = networkManager.technologyPathForType("bluetooth")
            }
        }
        onAvailableChanged: updateTechnologies()
        onTechnologiesEnabledChanged: updateTechnologies()
        onTechnologiesChanged: updateTechnologies()

    }

    NetworkTechnology {
        id: bt
    }

    ColumnLayout {
        anchors.fill: parent

        // Bluetooth Indicator
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Image {
                id: icon
                source: "qrc:/qml/images/icon_bt_normal.png"
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (icon.source.toString().match("normal")) {
                        icon.source = icon.source.toString().replace("normal","focused")
                    } else {
                        icon.source = icon.source.toString().replace("focused","normal")
                    }
                }
            }
        }

        // Battery Indicator
        Image {
            anchors.centerIn: parent
            source: {
                if(batteryChargePercentage.value > 85) {
                    return "qrc:/qml/images/battery6.png"
                } else if (batteryChargePercentage.value <= 5) {
                    return "qrc:/qml/images/battery0.png"
                } else if (batteryChargePercentage.value <= 10) {
                    return "qrc:/qml/images/battery1.png"
                } else if (batteryChargePercentage.value <= 25) {
                    return "qrc:/qml/images/battery2.png"
                } else if (batteryChargePercentage.value <= 40) {
                    return "qrc:/qml/images/battery3.png"
                } else if (batteryChargePercentage.value <= 65) {
                    return "qrc:/qml/images/battery4.png"
                } else if (batteryChargePercentage.value <= 80) {
                    return "qrc:/qml/images/battery5.png"
                } else {
                    return "qrc:/qml/images/battery6.png"
                }
            }
        }
        Label {
            id: batteryIndicator
            font.pointSize: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: batteryChargePercentage.value + "%"
            color: "white"
        }
        DropShadow {
            anchors.fill: batteryIndicator
            horizontalOffset: 3
            verticalOffset: 3
            radius: 8.0
            samples: 16
            color: "#80000000"
            source: batteryIndicator
        }

        // TODO: Brightness?? Vibrator??
    }
}
