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

import QtQuick
import org.asteroid.controls
import org.asteroid.utils
import Nemo.Ngf

MouseArea {
    id: view

    property QtObject panelsGrid
    property QtObject notification
    property var appsTable: [
            ["whatsapp", "logo-whatsapp", "#25D366", "#0F5F32"],
            ["mail", "ios-mail", "#FF6B5E", "#6B1A14"],
            ["signal", "logo-signal", "#5B8DF5", "#17306B"],
            ["instagram", "logo-instagram", "#C084DC", "#4B2363"],
            ["facebook", "logo-facebook", "#4C9BFF", "#0F3A7A"],
            ["telegram", "ios-paper-plane", "#4FC3F7", "#0E5F85"],
            ["linkedin", "logo-linkedin", "#6DB8F0", "#0F4C75"],
            ["mess", "ios-chatbubbles", "#5CB3FF", "#1B4F8F"],
            ["sms", "ios-chatbubbles", "#5CB3FF", "#1B4F8F"]
    ]
    function appInfo(n) {
        var a = n ? n.toLowerCase() : ""
        for (var i = 0; i < appsTable.length; i++)
            if (a.indexOf(appsTable[i][0]) >= 0) return appsTable[i]
        return ["", "ios-mail-outline", "#FFFFFF", "#000000"]
    }
    property color accent: appInfo(notification ? notification.appName : "")[2]
    property bool forbidTop: column.y < 0
    property real prevY: 0

    NonGraphicalFeedback {
        id: notifSound
        event: "notification"
    }

    onNotificationChanged: {
        if(notification !== undefined && notification !== null) {
            appName.text = notification.appName
            summary.text = notification.summary
            body.text = notification.body
            notifSound.play()
            updateTimestamp()
        }
    }

    function updateTimestamp() {
        var currentTime = new Date
        var delta = (currentTime.getTime() - notification.timestamp.getTime())

        if(delta < 60*1000)
            //% "Now"
            timestamp.text = qsTrId("id-now") + localeManager.changesObserver
        else {
            delta = parseInt(delta/(1000*60))
            if(delta < 60) {
                //% "m"
                timestamp.text = delta + qsTrId("id-minute-abbrev") + localeManager.changesObserver
            } else {
                delta = parseInt(delta/60)
                if(delta < 60) {
                    //% "h"
                    timestamp.text = delta + qsTrId("id-hour-abbrev") + localeManager.changesObserver
                } else {
                    delta = parseInt(delta/24)
                    //% "d"
                    timestamp.text = delta + qsTrId("id-day-abbrev") + localeManager.changesObserver
                }
            }
        }
    }

    onPressed: (mouse) => prevY = mouse.y

    onPositionChanged: (mouse) => {
        var newY = column.y + mouse.y-prevY
        newY = Math.max(newY, -column.height+view.height)
        newY = Math.min(newY, 0)
        column.y = newY
        prevY = mouse.y
    }

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        // 0.9 uses the corners a square panel has. A round one does not,
        // so it keeps the narrower column the layout was built around.
        width: view.width * (DeviceSpecs.hasRoundScreen ? 0.7 : 0.9)

        Item {
            id: spacing1
            height: Dims.h(15)
            width: 1
        }

        Row {
            height: Dims.h(10)
            spacing: Dims.w(2)
            Icon {
                width: Dims.h(10)
                height: Dims.h(10)
                name: view.appInfo(notification ? notification.appName : "")[1]
                color: view.accent
            }
            Label {
                id: appName
                color: view.accent
                width: Dims.w(54)
                font.pixelSize: Dims.l(6)
                elide: Text.ElideRight

                Connections {
                    target: panelsGrid
                    function onCurrentHorizontalPosChanged() { updateTimestamp() }
                }
            }

            Label {
                id: timestamp
                font.pixelSize: appName.font.pixelSize
                horizontalAlignment: Text.AlignRight
                width: Dims.w(22)
            }
        }

        Item {
            id: spacing3
            height: Dims.h(3)
            width: 1
        }

        Label {
            id: summary
            font.bold: true
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: DeviceSpecs.hasRoundScreen ? Text.AlignHCenter : Text.AlignLeft
        }

        Item {
            id: spacing4
            height: Dims.h(1)
            width: 1
        }

        Label {
            id: body
            font.pixelSize: Dims.l(9)
            wrapMode: Text.Wrap
            width: parent.width
            horizontalAlignment: DeviceSpecs.hasRoundScreen ? Text.AlignHCenter : Text.AlignLeft
        }

        Item {
            id: spacing5
            height: Dims.h(10)
            width: 1
        }

        NotificationButton {
            //% "Dismiss"
            text: qsTrId("id-dismiss") + localeManager.changesObserver
            anchors.horizontalCenter: parent.horizontalCenter
            width: Dims.w(55)
            height: Dims.h(14)
            onClicked: if (notification !== undefined && notification.userRemovable) notification.actionInvoked("default")
        }

        Item {
            id: spacing6
            height: Dims.h(10)
            width: 1
        }
    }
}
