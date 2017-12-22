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

import QtQuick 2.9
import org.asteroid.controls 1.0
import org.asteroid.launcher 1.0

Item {
    id: actions

    property QtObject panelsGrid
    property QtObject notification
    property QtObject notificationModel

    property bool forbidLeft:  true
    property bool forbidRight: true
    property bool forbidBottom: false

    property string timestampStr: ""

    onNotificationChanged: {
        if(notification !== undefined && notification !== null)
            updateTimestamp()
    }

    function updateTimestamp() {
        var currentTime = new Date
        var delta = (currentTime.getTime() - notification.timestamp.getTime())

        if(delta < 60*1000)
            //% "Now"
            timestampStr = qsTrId("id-now") + localeManager.changesObserver
        else {
            delta = parseInt(delta/(1000*60))
            if(delta < 60) {
                //% "m"
                timestampStr = delta + qsTrId("id-minute-abbrev") + localeManager.changesObserver
            } else {
                delta = parseInt(delta/60)
                if(delta < 60) {
                    //% "h"
                    timestampStr = delta + qsTrId("id-hour-abbrev") + localeManager.changesObserver
                } else {
                    delta = parseInt(delta/24)
                    //% "d"
                    timestampStr = delta + qsTrId("id-day-abbrev") + localeManager.changesObserver
                }
            }
        }
    }

    Connections {
        target: panelsGrid
        onCurrentHorizontalPosChanged: {
            if(forbidBottom)
                layerStack.pop(layerStack.currentLayer)
            updateTimestamp()
        }
    }

    NotificationSnoozer { id: snoozer }

    LayerStack {
        id: layerStack
        win: null
        firstPage: actionsComponent
        onLayersChanged: {
            actions.forbidBottom = layers.length > 0
            leftIndicator.visible = layers.length > 0
            leftIndicator.animateFar()
            panelsGrid.changeAllowedDirections()
        }
    }

    Component {
        id: actionsComponent

        Item {
            Column {
                id: column

                anchors.centerIn: parent
                width: Dims.w(55)
                spacing: Dims.h(8)

                NotificationButton {
                    //% "Snooze"
                    text: qsTrId("id-snooze") + localeManager.changesObserver
                    width: parent.width
                    height: Dims.h(20)
                    onClicked: layerStack.push(snoozeLayer)
                }

                NotificationButton {
                    //% "Dismiss all"
                    text: qsTrId("id-dismiss-all") + localeManager.changesObserver
                    width: parent.width
                    height: Dims.h(20)
                    onClicked: {
                        for(var i = 0 ; i < notificationModel.itemCount ; i++) {
                            var notifI = notificationModel.get(i)
                            if (notifI.userRemovable) {
                                notifI.removeRequested()
                            }
                        }
                    }
                }

                NotificationButton {
                    //% "Dismiss"
                    text: qsTrId("id-dismiss") + localeManager.changesObserver
                    width: parent.width
                    height: Dims.h(20)
                    onClicked: if (notification.userRemovable) notification.removeRequested()
                }
            }
        }
    }

    Component {
        id: snoozeLayer

        Item {
            id: snoozeLayerContent
            property var pop

            PageHeader {
                id: title
                //% "Snooze"
                text: qsTrId("id-snooze")
            }

            Grid {
                anchors.fill: parent
                columns: 2
                spacing: Dims.l(8)
                anchors.margins: Dims.l(20)

                NotificationButton {
                    //% "m"
                    text: "10" + qsTrId("id-minute-abbrev") + localeManager.changesObserver
                    onClicked: {
                        if(snoozer.snooze(notification, 10))
                            notification.removeRequested()
                    }
                    width: Dims.l(26)
                    height: width
                }

                NotificationButton {
                    //% "m"
                    text: "30" + qsTrId("id-minute-abbrev") + localeManager.changesObserver
                    onClicked: {
                        if(snoozer.snooze(notification, 30))
                            notification.removeRequested()
                    }
                    width: Dims.l(26)
                    height: width
                }

                NotificationButton {
                    //% "h"
                    text: "1" + qsTrId("id-hour-abbrev") + localeManager.changesObserver
                    onClicked: {
                        if(snoozer.snooze(notification, 60))
                            notification.removeRequested()
                    }
                    width: Dims.l(26)
                    height: width
                }

                NotificationButton {
                    //% "h"
                    text: "3" + qsTrId("id-hour-abbrev") + localeManager.changesObserver
                    onClicked: {
                        if(snoozer.snooze(notification, 180))
                            notification.removeRequested()
                    }
                    width: Dims.l(26)
                    height: width
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Dims.h(3)
        anchors.horizontalCenter: parent.horizontalCenter

        Icon {
            name: {
                if(notification==null)
                    return "";

                function noicon(str) {
                    return str === "" || str === null || str === undefined;
                }
                // icon for asteroid internal, appIcon for notifications from android
                if(noicon(notification.icon) && noicon(notification.appIcon))
                    return "ios-mail-outline";
                if(noicon(notification.icon) && !noicon(notification.appIcon))
                    return notification.appIcon;
                if(!noicon(notification.icon) && noicon(notification.appIcon))
                    return notification.icon;

                // prefer asteroid internal
                return notification.icon;
            }
            height: timestamp.height
            width: height
        }

        Label {
            id: timestamp
            color: "#b0b0b0"
            text: timestampStr
            font.pixelSize: Dims.l(6)
        }
    }

    Indicator { id: leftIndicator; edge: Qt.LeftEdge }
}
