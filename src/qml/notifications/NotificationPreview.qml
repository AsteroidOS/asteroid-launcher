/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2012 Jolla Ltd.
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
import org.nemomobile.lipstick

Item {
    id: notificationWindow
    width: initialSize.width
    height: initialSize.height

    MouseArea {
        id: notificationArea
        anchors.fill: parent
        enabled: state == "show"
        onClicked: notificationArea.state = "hide"

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
        property var notif: notificationPreviewPresenter.notification
        property var info: appInfo(notif != null ? notif.appName : "")

        Rectangle {
            anchors.fill: parent
            color: notificationArea.info[3]
            opacity: notificationArea.pressed ? 0.9 : 0.95
        }

        Item {
            anchors.fill: parent
            anchors.margins: Dims.w(3)

            Icon {
                id: icon
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: Dims.w(14)
                height: width
                color: notificationArea.info[2]
                name: {
                    var n = notificationArea.notif;
                    if (n == null)
                        return "";
                    if (notificationArea.info[0] !== "")
                        return notificationArea.info[1];
                    if (n.icon !== "" && n.icon !== null && n.icon !== undefined)
                        return n.icon;
                    if (n.appIcon !== "" && n.appIcon !== null && n.appIcon !== undefined)
                        return n.appIcon;
                    return "ios-mail-outline";
                }
            }

            Label {
                id: summary
                anchors.top: icon.bottom
                anchors.topMargin: text == "" ? 0 : Dims.h(1)
                anchors.left: parent.left
                anchors.right: parent.right
                height: text == "" ? 0 : undefined
                horizontalAlignment: Text.AlignHCenter
                color: "#FFFFFF"
                font.pixelSize: Dims.l(6)
                font.bold: true
                clip: true
                maximumLineCount: 2
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                text: notificationArea.notif != null ? notificationArea.notif.previewSummary : ""
            }

            Label {
                id: body
                anchors.top: summary.bottom
                anchors.topMargin: Dims.h(2)
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: DeviceSpecs.hasRoundScreen ? Text.AlignHCenter : Text.AlignLeft
                color: "#FFFFFF"
                font.pixelSize: Dims.h(12)
                font.bold: summary.text == ""
                clip: true
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                text: notificationArea.notif != null ? notificationArea.notif.previewBody : ""
            }
        }

        state: "hide"
        states: [
            State {
                name: "show"
                PropertyChanges {
                    target: notificationArea
                    opacity: 1
                }
                StateChangeScript {
                    name: "notificationShown"
                    script: {
                        notificationTimer.start()
                    }
                }
            },
            State {
                name: "hide"
                PropertyChanges {
                    target: notificationArea
                    opacity: 0
                }
                StateChangeScript {
                    name: "notificationHidden"
                    script: {
                        notificationTimer.stop()
                        notificationPreviewPresenter.showNextNotification()
                    }
                }
            }
        ]

        transitions: [
            Transition {
                to: "show"
                SequentialAnimation {
                    OpacityAnimator { duration: 300 }
                    ScriptAction { scriptName: "notificationShown" }
                }
            },
            Transition {
                to: "hide"
                SequentialAnimation {
                    OpacityAnimator { duration: 300 }
                    ScriptAction { scriptName: "notificationHidden" }
                }
            }
        ]

        Timer {
            id: notificationTimer
            interval: 8000
            repeat: false
            onTriggered: notificationArea.state = "hide"
        }

        Connections {
            target: notificationPreviewPresenter;
            function onNotificationChanged() { notificationArea.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide" }
        }
    }
}
