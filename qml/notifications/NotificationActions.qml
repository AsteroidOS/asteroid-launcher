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

    property QtObject notification
    property QtObject notificationModel

    property bool forbidLeft:  true
    property bool forbidRight: true

    Column {
        id: column
        anchors.centerIn: parent

        width: Dims.w(55)
        spacing: Dims.h(8)

        NotificationSnoozer { id: snoozer }

        NotificationButton {
            text: qsTr("Snooze")
            width: parent.width
            height: Dims.h(20)
            onClicked: {
                if (notification.userRemovable) {
                    if(snoozer.snooze(notification, 5))
                        notification.removeRequested()
                }
            }
        }

        NotificationButton {
            text: qsTr("Dismiss all")
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
            text: qsTr("Dismiss")
            width: parent.width
            height: Dims.h(20)
            onClicked: if (notification.userRemovable) notification.removeRequested()
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
            color: "#FFFFFF"
        }

        Text {
            id: timestamp
            color: "#b0b0b0"
            text: "35m"
            font.pixelSize: Dims.l(6)
        }
    }
}
