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
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.freedesktop.contextkit 1.0

Item {
    id: root
    z: 201
    height: 48
    width: parent.width
    anchors.bottom: parent.bottom

    Rectangle {
        id: statusbar
        color: "black"
        anchors.fill: parent
        opacity: 0.5
        z: 200
    }

    Connections {
        target: batteryChargePercentage
        onValueChanged: {
            if(batteryChargePercentage.value > 85) {
                batteryimg.source = "images/battery6.png"
            } else if (batteryChargePercentage.value <= 5) {
                batteryimg.source = "images/battery0.png"
            } else if (batteryChargePercentage.value <= 10) {
                batteryimg.source = "images/battery1.png"
            } else if (batteryChargePercentage.value <= 25) {
                batteryimg.source = "images/battery2.png"
            } else if (batteryChargePercentage.value <= 40) {
                batteryimg.source = "images/battery3.png"
            } else if (batteryChargePercentage.value <= 65) {
                batteryimg.source = "images/battery4.png"
            } else if (batteryChargePercentage.value <= 80) {
                batteryimg.source = "images/battery5.png"
            }
        }
    }

    Connections {
        target: cellularSignalBars
        onValueChanged: {
            cellularbars.text = cellularSignalBars.value
        }
    }


    ContextProperty {
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        value: "100"
    }

    ContextProperty {
        id: cellularSignalBars
        key: "Cellular.SignalBars"
    }

    ContextProperty {
        id: cellularRegistrationStatus
        key: "Cellular.RegistrationStatus"
    }

    Rectangle {
        id: cellular
        anchors.left: parent.left
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
        Label {
            id: cellularbars
            width: 32
            height: 32
            font.pointSize: 8
        }
    }
    Rectangle {
        id: wifi
        anchors.left: cellular.right
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
    }
    Rectangle {
        id: bluetooth
        anchors.left: wifi.right
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
        Image {
            source: bluetoothConnected.value !== undefined && bluetoothConnected.value ? "image://theme/icon-status-bluetooth-connected" : "image://theme/icon-status-bluetooth"

            ContextProperty {
                id: bluetoothEnabled
                key: "Bluetooth.Enabled"
            }
            ContextProperty {
                id: bluetoothConnected
                key: "Bluetooth.Connected"
            }
        }
    }
    Rectangle {
        id: nfc
        anchors.left: bluetooth.right
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
        Image {
            source: "image://theme/icon-nfc-enabled"
        }
    }
    Rectangle {
        id: gps
        anchors.left: nfc.right
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
        Image {
            source: "image://theme/icon-gps-enabled"
        }
    }
    Rectangle {
        id: playlist
        anchors.left: gps.right
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
        Image {
            source: "image://theme/icon-playlist-playpause"
        }
    }
    Rectangle {
        id: clock
        anchors.left: playlist.right
        color: "transparent"
        height: 48
        width: 48
        anchors.margins: 8
        Label {
            id: hours
            width: 16
            height: 16
            font.pointSize: 6
            text: Qt.formatDateTime(wallClock.time, "hh")
        }
        Label {
            id: minutes
            anchors.top: hours.bottom
            anchors.topMargin: 4
            width: 16
            height: 16
            font.pointSize: 6
            text: Qt.formatDateTime(wallClock.time, "mm")
        }
    }

    Rectangle {
        anchors.right: parent.right
        height: 48
        width: 48
        color: "transparent"
        anchors.margins: 8
        Image {
            id: batteryimg
            width: 32
            height: 32
        }
    }
}
