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
import QtQuick.Layouts 1.0
import org.freedesktop.contextkit 1.0
import MeeGo.Connman 0.2
import org.nemomobile.dbus 1.0

Item {
    id: rootitem
    width: parent.width
    height: parent.height

    Connections {
        target: lipstickSettings;
        onLockscreenVisibleChanged: {
            if(lipstickSettings.lockscreenVisible) batteryChargePercentage.subscribe()
            else batteryChargePercentage.unsubscribe()
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
            if (available && technologiesEnabled) 
                bt.path = networkManager.technologyPathForType("bluetooth")
        }
        onAvailableChanged: updateTechnologies()
        onTechnologiesEnabledChanged: updateTechnologies()
        onTechnologiesChanged: updateTechnologies()
    }

    NetworkTechnology { id: bt }

    property DBusInterface _dbus: DBusInterface {
        id: mce_dbus

        destination: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"

        busType: DBusInterface.SystemBus
    }

    GridLayout {
        id : grid
        anchors.fill: parent
        rows    : 3
        columns : 3
        columnSpacing : 0
        rowSpacing    : 0

        MouseArea {
            id: lockedMA
            Layout.rowSpan    : 1
            Layout.columnSpan : 3
            Layout.preferredWidth  : grid.width
            Layout.preferredHeight : grid.height/3
            onClicked: mce_dbus.call("req_display_state_off", undefined)
            Image {
                id: lockedIcon
                source: "qrc:/qml/images/lock.png"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.margins: 25
            }
        }
        DropShadow {
            anchors.fill: lockedMA
            horizontalOffset: 3
            verticalOffset: 3
            radius: 8.0
            samples: 16
            color: "#80000000"
            source: lockedMA
        }

        MouseArea {
            id: brightnessMA
            Layout.preferredWidth  : grid.width/3
            Layout.preferredHeight : grid.height/3
            onClicked: {
                if (brightnessIcon.source.toString().match("brightness1")) brightnessIcon.source = brightnessIcon.source.toString().replace("brightness1","brightness2")
                else if (brightnessIcon.source.toString().match("brightness2")) brightnessIcon.source = brightnessIcon.source.toString().replace("brightness2","brightness3")
                else brightnessIcon.source = brightnessIcon.source.toString().replace("brightness3","brightness1")
            }
            Rectangle {
                anchors.fill: parent
                radius: width/2
                anchors.margins: 10
                color : brightnessMA.pressed ? '#66222222' : '#99222222'
                Image {
                    id: brightnessIcon
                    source: "qrc:/qml/images/brightness1.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.fill: parent
                    anchors.margins: 20
                }
            }
        }
        MouseArea {
            id: bluetoothMA
            Layout.preferredWidth  : grid.width/3
            Layout.preferredHeight : grid.height/3
            onClicked: {
                if (bluetoothIcon.source.toString().match("off")) bluetoothIcon.source = bluetoothIcon.source.toString().replace("off","on")
                else bluetoothIcon.source = bluetoothIcon.source.toString().replace("on","off")
            }
            Rectangle {
                anchors.fill: parent
                radius: width/2
                anchors.margins: 10
                color : bluetoothMA.pressed ? '#66222222' : '#99222222'
                Image {
                    id: bluetoothIcon
                    source: "qrc:/qml/images/bluetooth_off.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.fill: parent
                    anchors.margins: 20
                }
            }
        }
        MouseArea {
            id: airplaneMA
            Layout.preferredWidth  : grid.width/3
            Layout.preferredHeight : grid.height/3
            onClicked: {
                if (airplaneIcon.source.toString().match("off")) airplaneIcon.source = airplaneIcon.source.toString().replace("off","on")
                else airplaneIcon.source = airplaneIcon.source.toString().replace("on","off")
            }
            Rectangle {
                anchors.fill: parent
                radius: width/2
                anchors.margins: 10
                color : airplaneMA.pressed ? '#66222222' : '#99222222'
                Image {
                    id: airplaneIcon
                    source: "qrc:/qml/images/airplane_off.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.fill: parent
                    anchors.margins: 20
                }
            }
        }
        MouseArea {
            id : batteryMA
            Layout.rowSpan    : 1
            Layout.columnSpan : 3
            Layout.preferredWidth  : grid.width
            Layout.preferredHeight : grid.height/3
            Item {
                id: battery
                anchors.centerIn: parent
                height: parent.height
                width: batteryIcon.width + batteryIndicator.width
                Image {
                    id: batteryIcon
                    source: {
                        if(batteryChargePercentage.value > 85)        return "qrc:/qml/images/battery6.png"
                        else if (batteryChargePercentage.value <= 5)  return "qrc:/qml/images/battery0.png"
                        else if (batteryChargePercentage.value <= 10) return "qrc:/qml/images/battery1.png"
                        else if (batteryChargePercentage.value <= 25) return "qrc:/qml/images/battery2.png"
                        else if (batteryChargePercentage.value <= 40) return "qrc:/qml/images/battery3.png"
                        else if (batteryChargePercentage.value <= 65) return "qrc:/qml/images/battery4.png"
                        else if (batteryChargePercentage.value <= 80) return "qrc:/qml/images/battery5.png"
                        else                                          return "qrc:/qml/images/battery6.png"
                    }
                    fillMode: Image.PreserveAspectFit
                    height: parent.height-66
                    width: height
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: batteryIndicator
                    font.pointSize: 8
                    text: batteryChargePercentage.value + "%"
                    color: "white"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            DropShadow {
                anchors.fill: battery
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8.0
                samples: 16
                color: "#80000000"
                source: battery
            }
        }
    }
}
