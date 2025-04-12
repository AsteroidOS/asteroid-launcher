/*
 * Copyright (C) 2017 Florent Revest <revestflo@gmail.com>
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

import QtQml 2.2
import QtQuick 2.8
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import "qrc:/qml/compositor/";
import Nemo.Time 1.0
import Nemo.Configuration 1.0

FlatMesh {
    centerColor: "#CC9800"
    outerColor: "#0C0500"
    animated: false /* For some reason we can not have two animated flatmeshes in the same process ? */

    property alias contentX: contentArea.contentX
    property bool fakePressed: false

    Indicator { id: leftIndicator; edge: Qt.LeftEdge }
    Indicator { id: topIndicator; edge: Qt.TopEdge }

    function animIndicators() {
        leftIndicator.animate();
        topIndicator.animate();
    }

    Flickable {
        id: contentArea
        anchors.fill: parent
        interactive: false
        Row {
            id: content
            width: 2*contentArea.width
            height: contentArea.height

            Item {
                width: contentArea.width
                height: parent.height

                Rectangle {
                    id: addAlarmBackground
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -Dims.h(5)
                    color: fakePressed ? "#333333": "black"
                    radius: width/2
                    opacity: 0.2
                    width: Dims.w(25)
                    height: width
                }
                Icon {
                    anchors.fill: addAlarmBackground
                    anchors.margins: Dims.l(3)
                    name: "ios-add"
                }

                Label {
                    //% "Add an alarm"
                    text: qsTrId("id-add-alarm") + localeManager.changesObserver
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    anchors.left: parent.left; anchors.right: parent.right
                    anchors.leftMargin: Dims.w(2); anchors.rightMargin: Dims.w(2)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: Dims.h(15)
                }

                MouseArea {
                    id: ma
                    width: Dims.w(70)
                    height: Dims.h(70)
                    anchors.centerIn: parent
                    onClicked: layerStack.push(timePickerLayer)
                }
            }

            Item {
                id: root
                property var alarmObject
                property var pop
                width: contentArea.width
                height: contentArea.height

                function zeroPadding(x) {
                    if (x<10) return "0"+x;
                    else      return x;
                }

                ConfigurationValue {
                    id: use12H
                    key: "/org/asteroidos/settings/use-12h-format"
                    defaultValue: false
                }

                PageHeader {
                    id: title
                    //% "Time"
                    text: qsTrId("id-time") + localeManager.changesObserver
                }

                Row {
                    id: timeSelector
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: title.bottom
                    height: Dims.h(60)

                    property int spinnerWidth: use12H.value ? width/3 : width/2

                    CircularSpinner {
                        id: hourLV
                        height: parent.height
                        width: parent.spinnerWidth
                        model: use12H.value ? 12 : 24
                        showSeparator: true
                    }

                    CircularSpinner {
                        id: minuteLV
                        height: parent.height
                        width: parent.spinnerWidth
                        model: 60
                        showSeparator: use12H.value
                    }

                    Spinner {
                        id: amPmLV
                        height: parent.height
                        width: parent.spinnerWidth
                        model: 2
                        delegate: SpinnerDelegate { text: index == 0 ? "AM" : "PM" }
                    }
                }

                IconButton {
                    iconName: "ios-arrow-dropright"
                    anchors { 
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                        bottomMargin: Dims.iconButtonMargin
                    }
                }

                WallClock { id: wallClock }

                Component.onCompleted: {
                    var hour = wallClock.time.getHours();
                    if(use12H.value) {
                        amPmLV.currentIndex = hour / 12;
                        hour = hour % 12;
                    }
                    hourLV.currentIndex = hour;
                    minuteLV.currentIndex = wallClock.time.getMinutes();
                }
            }
        }
    }

    layer.enabled: DeviceSpecs.hasRoundScreen
    layer.effect: CircleMaskShader { }
}
