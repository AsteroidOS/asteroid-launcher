/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2012 Timur Kristóf <venemo@fedoraproject.org>
 *               2011 Tom Swindell <t.swindell@rubyx.co.uk>
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
import org.nemomobile.lipstick 0.1

Item {
    Flickable {
        id: mainFlickable
        contentHeight: notifmodel.itemCount * 80
        anchors.fill: parent

        Column {
            anchors.fill: parent
            spacing: 10
            Repeater {
                model: NotificationListModel { id: notifmodel }
                delegate:
                    MouseArea {
                        height: 80
                        width: parent.width

                        onClicked: if (modelData.userRemovable) modelData.actionInvoked("default")

                        Image {
                            id: appIcon
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 10
                            width: 50
                            height: width
                            source: {
                                if(modelData == null || modelData.icon == "")
                                    return "image://theme/user-info";
                                else if(modelData.icon.indexOf("/") == 0)
                                    return "file://" + modelData.icon;
                                else
                                    return "image://theme/" + modelData.icon;
                            }
                        }

                        Text {
                            id: appSummary
                            text: modelData.summary
                            color: "white"
                            font.pixelSize: 36
                            clip: true
                            elide: Text.ElideRight
                            anchors.top: parent.top
                            anchors.left: appIcon.right
                            anchors.right: parent.right
                            anchors.topMargin: 7
                            anchors.leftMargin: 26
                            anchors.rightMargin: 5
                        }
                        Text {
                            id: appBody
                            text: modelData.body
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            clip: true
                            elide: Text.ElideRight
                            anchors.bottom: parent.bottom
                            anchors.left: appSummary.left
                            anchors.right: parent.right
                            anchors.bottomMargin: 7
                        }
                    }
            }
        }
    }

    Image {
        id: emptyIndicator
        visible: notifmodel.itemCount === 0
        width: parent.width*0.4
        height: parent.height*0.4
        fillMode: Image.PreserveAspectFit
        source: "qrc:/qml/images/no_notification.png"
        anchors.centerIn: parent
    }
    DropShadow {
        visible: notifmodel.itemCount === 0
        anchors.fill: emptyIndicator
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 16
        color: "#80000000"
        source: emptyIndicator
    }
}
