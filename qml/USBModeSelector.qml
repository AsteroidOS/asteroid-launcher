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

import QtQuick 2.0
import org.nemomobile.lipstick 0.1

Item {
    property bool isPortrait: (orientationAngleContextProperty.value == 90 || orientationAngleContextProperty.value == 270)
    id: usbWindow
    width: initialSize.width
    height: initialSize.height

/*
 TODO
    ContextProperty {
        id: orientationAngleContextProperty
        key: "/Screen/CurrentWindow/OrientationAngle"
    }
*/
    QtObject {
        id: orientationAngleContextProperty
        property int value: 0
    }

    Item {
        property bool shouldBeVisible
        id: usbDialog
        width: usbWindow.isPortrait ? usbWindow.height : usbWindow.width
        height: usbWindow.isPortrait ? usbWindow.width : usbWindow.height
        transform: Rotation {
            origin.x: { switch(orientationAngleContextProperty.value) {
                      case 270:
                          return usbWindow.height / 2
                      case 180:
                      case 90:
                          return usbWindow.width / 2
                      default:
                          return 0
                      } }
            origin.y: { switch(orientationAngleContextProperty.value) {
                case 270:
                case 180:
                    return usbWindow.height / 2
                case 90:
                    return usbWindow.width / 2
                default:
                    return 0
                } }
            angle: (orientationAngleContextProperty.value === undefined || orientationAngleContextProperty.value == 0) ? 0 : -360 + orientationAngleContextProperty.value
        }
        opacity: shouldBeVisible ? 1 : 0

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.8
            border.color: "white"
        }

        MouseArea {
            id: usbDialogBackground
            anchors.fill: parent
            onClicked: { usbModeSelector.setUSBMode(4); usbDialog.shouldBeVisible = false }

            Rectangle {
                id: chargingOnly
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: parent.height / 4
                }
                height: 102
                color: "black"
                radius: 5
                border {
                    color: "gray"
                    width: 2
                }

                Text {
                    anchors {
                        fill: parent
                    }
                    text: "Current mode: Charging only"
                    color: "white"
                    font.pixelSize: 30
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                id: button1
                anchors {
                    top: chargingOnly.bottom
                    topMargin: 40
                    left: parent.left
                    right: parent.right
                }
                text: "MTP Mode"
                color: "white"
                font.pixelSize: 30
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: { usbModeSelector.setUSBMode(11); usbDialog.shouldBeVisible = false }
                }
            }

            Text {
                id: button2
                anchors {
                    top: button1.bottom
                    topMargin: 40
                    left: parent.left
                    right: parent.right
                }
                text: "Mass Storage Mode"
                color: "white"
                font.pixelSize: 30
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: { usbModeSelector.setUSBMode(3); usbDialog.shouldBeVisible = false }
                }
            }

            Text {
                id: button3
                anchors {
                    top: button2.bottom
                    topMargin: 40
                    left: parent.left
                    right: parent.right
                }
                text: "Developer Mode"
                color: "white"
                font.pixelSize: 30
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: { usbModeSelector.setUSBMode(10); usbDialog.shouldBeVisible = false }
                }
            }
        }

        Connections {
            target: usbModeSelector
            onWindowVisibleChanged: if (usbModeSelector.windowVisible) usbDialog.shouldBeVisible = true
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                onRunningChanged: if (!running && usbDialog.opacity == 0) usbModeSelector.windowVisible = false
            }
        }
    }
}
