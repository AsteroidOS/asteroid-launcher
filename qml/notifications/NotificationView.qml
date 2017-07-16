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

import QtQuick 2.0

MouseArea {
    id: view

    property QtObject panelsGrid
    property QtObject notification
    property bool forbidTop: column.y < 0
    property real prevY: 0

    onNotificationChanged: {
        if(notification !== undefined && notification !== null) {
            appName.text = notification.appName
            summary.text = notification.summary
            body.text = notification.body
            updateTimestamp()
        }
    }

    function updateTimestamp() {
            var currentTime = new Date
            var delta = (currentTime.getTime() - notification.timestamp.getTime())

            if(delta < 60*1000)
                timestamp.text = qsTr("Now")
            else {
                delta = parseInt(delta/(1000*60))
                if(delta < 60)
                    timestamp.text = delta + qsTr("m")
                else {
                    delta = parseInt(delta/60)
                    if(delta < 60)
                        timestamp.text = delta + qsTr("h")
                    else {
                        delta = parseInt(delta/24)
                        timestamp.text = delta + qsTr("d")
                    }
                }
            }
    }

    onPressed: {
        prevY = mouse.y
    }

    onPositionChanged: {
        var newY = column.y + mouse.y-prevY
        newY = Math.max(newY, -column.height+view.height)
        newY = Math.min(newY, 0)
        column.y = newY
        prevY = mouse.y
    }

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        width: view.width * 0.7

        Item {
            id: spacing1
            height: view.height * 0.15
            width: 1
        }

        Text {
            id: appName
            color: "white"
            width: parent.width
            font.pixelSize: view.height * 0.06

            Connections {
                target: panelsGrid
                onCurrentHorizontalPosChanged: updateTimestamp()
            }

            Text {
                id: timestamp
                color: "white"
                font.pixelSize: appName.font.pixelSize
                anchors.fill: parent
                horizontalAlignment: Text.AlignRight
            }
        }

        Item {
            id: spacing3
            height: view.height * 0.03
            width: 1
        }

        Text {
            id: summary
            color: "white"
            font.bold: true
            font.pixelSize: view.height * 0.085
            width: parent.width
        }

        Item {
            id: spacing4
            height: view.height * 0.01
            width: 1
        }

        Text {
            id: body
            color: "white"
            font.pixelSize: view.height * 0.08
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.Wrap
            width: parent.width
        }

        Item {
            id: spacing5
            height: view.height * 0.1
            width: 1
        }

        NotificationButton {
            text: qsTr("Dismiss")
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.55
            height: view.height * 0.2
            onClicked: if (notification !== undefined && notification.userRemovable) notification.actionInvoked("default")
        }

        Item {
            id: spacing6
            height: view.height * 0.1
            width: 1
        }
    }
}
