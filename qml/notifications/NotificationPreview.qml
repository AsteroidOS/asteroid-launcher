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

import QtQuick 2.9
import org.asteroid.controls 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: notificationWindow
    width: initialSize.width
    height: initialSize.height

    MouseArea {
        id: notificationArea
        anchors.fill: parent
        enabled: state == "show"
        onClicked: notificationArea.state = "hide"

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: notificationArea.pressed ? 0.85 : 0.8
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: icon.anchors.topMargin + icon.height + summary.anchors.topMargin + summary.height + body.anchors.topMargin + body.height

            Icon {
                id: icon
                anchors.top: parent.top
                anchors.topMargin: Dims.iconButtonMargin
                anchors.horizontalCenter: parent.horizontalCenter
                width: Dims.w(20)
                height: width
                color: "#FFFFFF"
                name: {
                    var notif = notificationPreviewPresenter.notification;
                    if(notif==null)
                        return "";

                    function noicon(str) {
                        return str === "" || str === null || str === undefined;
                    }
                    if(noicon(notif.icon) && noicon(notif.appIcon))
                        return "ios-mail-outline";
                    if(noicon(notif.icon) && !noicon(notif.appIcon))
                        return notif.appIcon;
                    if(!noicon(notif.icon) && noicon(notif.appIcon))
                        return notif.icon;

                    return notif.icon;
                }
            }

            Label {
                id: summary
                anchors.top: icon.bottom
                height: text == "" ? 0 : undefined
                width: Dims.w(90)
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: text == "" ? 0 : Dims.h(3)
                color: "#FFFFFF"
                font.pixelSize: Dims.l(6)
                font.bold: true
                clip: true
                elide: Text.ElideRight
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewSummary : ""
            }

            Label {
                id: body
                anchors.top: summary.bottom
                width: Dims.w(80)
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: Dims.h(3)
                color: "#FFFFFF"
                font.pixelSize: Dims.h(6)
                font.bold: summary.text == ""
                clip: true
                maximumLineCount: 4
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewBody : ""
            }
        }

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
            interval: 5000
            repeat: false
            onTriggered: notificationArea.state = "hide"
        }

        Connections {
            target: notificationPreviewPresenter;
            onNotificationChanged: notificationArea.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide"
        }
    }
}
