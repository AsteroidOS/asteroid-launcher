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
                cellularSignalBars.subscribe()
                cellularRegistrationStatus.subscribe()
                cellularNetworkName.subscribe()
                cellularDataTechnology.subscribe()
            } else {
                batteryChargePercentage.unsubscribe()
                cellularSignalBars.unsubscribe()
                cellularRegistrationStatus.unsubscribe()
                cellularNetworkName.unsubscribe()
                cellularDataTechnology.unsubscribe()
            }
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

    NetworkManager {
        id: networkManager
        function updateTechnologies() {
            if (available && technologiesEnabled) {
                wlan.path = networkManager.technologyPathForType("wifi")
            }
        }
        onAvailableChanged: updateTechnologies()
        onTechnologiesEnabledChanged: updateTechnologies()
        onTechnologiesChanged: updateTechnologies()

    }

    NetworkTechnology {
        id: wlan
    }

    ContextProperty {
        id: cellularNetworkName
        key: "Cellular.NetworkName"
    }

    ContextProperty {
        id: cellularDataTechnology
        key: "Cellular.DataTechnology"
    }

    TechnologyModel {
        id: wifimodel
        name: "wifi"
        onPoweredChanged: {
            if (powered)
                wifimodel.requestScan()
        }
    }

    Loader {
        id: panel_loader
        anchors.bottom: rootItem.top
        height: 240
        width: parent.width
        visible: false
    }

    GridLayout {
        anchors.fill: parent
        columns: 3
        QuickSetItem {
            source: (cellularSignalBars.value > 0) ? "qrc:/qml/images/icon_cell.png" + cellularSignalBars.value : "qrc:/qml/images/icon_cell1.png"
        }

        QuickSetItem {
            Label {
                id: tech
                width: 32
                height: 32
                font.pointSize: 6
                font.bold: true
                color: "white"
                wrapMode: Text.ElideRight
                text: (cellularNetworkName.value !== "") ? cellularNetworkName.value.substring(0,3).toUpperCase() : "NA"
            }

            Label {
                anchors.top: tech.bottom
                anchors.topMargin: 4
                width: 32
                height: 32
                font.pointSize: 6
                color: "white"
                text: {
                    var techToG = {gprs: "2", egprs: "2.5", umts: "3", hspa: "3.5", lte: "4", unknown: "0"}
                    return techToG[cellularDataTechnology.value ? cellularDataTechnology.value : "unknown"] + "G"
                }
            }
            panel: SimPanel {}
        }

        QuickSetItem {
            source: {
                if (wlan.connected) {
                    if (networkManager.defaultRoute.type !== "wifi")
                        return "qrc:/qml/images/icon_wifi_0.png"
                    if (networkManager.defaultRoute.strength >= 59) {
                        return "qrc:/qml/images/icon_wifi_normal4.png"
                    } else if (networkManager.defaultRoute.strength >= 55) {
                        return "qrc:/qml/images/icon_wifi_normal3.png"
                    } else if (networkManager.defaultRoute.strength >= 50) {
                        return "qrc:/qml/images/icon_wifi_normal2.png"
                    } else if (networkManager.defaultRoute.strength >= 40) {
                        return "qrc:/qml/images/icon_wifi_normal1.png"
                    } else {
                        return "qrc:/qml/images/icon_wifi_0.png"
                    }
                } else {
                    return "qrc:/qml/images/icon_wifi_0.png"
                }
            }
            panel: WifiPanel {}
        }
        QuickSetItem {
            source: "qrc:/qml/images/icon_bt_normal.png"
        }
        QuickSetItem {
            source: "qrc:/qml/images/icon_nfc_normal.png"
        }
        QuickSetItem {
            source: "qrc:/qml/images/icon_gps_normal.png"
        }

        QuickSetItem {
            panel: BatteryPanel {}
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
    }
}
