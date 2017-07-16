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
import org.nemomobile.lipstick 0.1
import org.asteroid.controls 1.0

Item {
    id: notifPanel

    property QtObject panelsGrid
    property QtObject firstNotifView
    property bool forbidTop: firstNotifView !== null ? firstNotifView.forbidTop : false

    onForbidTopChanged: panelsGrid.changeAllowedDirections()

    NotificationListModel {
        id: notifmodel
        onItemAdded: {
            var index = notifmodel.indexOf(item)

            var leftPanelIndex = notifmodel.itemCount-1
            var leftPanel = notifmodel.get(leftPanelIndex)
            while(leftPanelIndex > index) {
                if(leftPanelIndex == 1 && firstNotifView !== undefined) {
                    panelsGrid.movePanel(-1, -1, -2, -1)
                    var notif = firstNotifView.notification
                    firstNotifView.destroy()
                    var notifView = panelsGrid.addPanel(-2, 0, notificationViewComp)
                    notifView.notification = notif
                    notifView.panelsGrid = panelsGrid
                } else {
                    panelsGrid.movePanel(-leftPanelIndex, 0, (-leftPanelIndex-1), 0)
                    panelsGrid.movePanel(-leftPanelIndex, -1, (-leftPanelIndex-1), -1)
                }

                leftPanelIndex--
                leftPanel = notifmodel.get(leftPanelIndex) 
            }
                    
            var notifActions = panelsGrid.addPanel(-index-1, -1, notificationActionsComp)
            notifActions.notification = item
            notifActions.notificationModel = notifmodel
            if(index > 0) {
                var notifView = panelsGrid.addPanel(-index-1, 0, notificationViewComp)
                notifView.notification = item
                notifView.panelsGrid = panelsGrid
            } else {
                firstNotifView = notificationViewComp.createObject(notifPanel)

                firstNotifView.x = 0
                firstNotifView.y = 0
                firstNotifView.width = Qt.binding(function() { return notifPanel.width })
                firstNotifView.height = Qt.binding(function() { return notifPanel.height })
                firstNotifView.notification = item
                firstNotifView.panelsGrid = panelsGrid
            }

            panelsGrid.changeAllowedDirections()
        }

        onRowsRemoved: {
            for (var i = first+1 ; i <= last+1; i++) {
                if(i!==1)
                    panelsGrid.removePanel(-i, 0)
                else
                    firstNotifView.destroy()

                panelsGrid.removePanel(-i, -1)
            }

            for (var i = last+2 ; i <= notifmodel.itemCount+1; i++) {
                if(i == last-first+2) {
                    panelsGrid.removePanel(-i, 0)
                    panelsGrid.removePanel(-i, -1)

                    var notifActions = panelsGrid.addPanel(-1, -1, notificationActionsComp)
                    notifActions.notification = notifmodel.get(0)
                    notifActions.notificationModel = notifmodel

                    firstNotifView = notificationViewComp.createObject(notifPanel)
                    firstNotifView.x = 0
                    firstNotifView.y = 0
                    firstNotifView.width = Qt.binding(function() { return notifPanel.width })
                    firstNotifView.height = Qt.binding(function() { return notifPanel.height })
                    firstNotifView.notification = notifmodel.get(0)
                    firstNotifView.panelsGrid = panelsGrid
                } else {
                    panelsGrid.movePanel(-i, 0, -i+(last-first+1), 0)
                    panelsGrid.movePanel(-i, -1, -i+(last-first+1), -1)
                }
            }

            panelsGrid.moveTo(-first, 0)
        }
    }

    Component {
        id: notificationActionsComp
        NotificationActions {}
    }
    Component {
        id: notificationViewComp
        NotificationView    {}
    }

    NotificationIndicator {
        anchors.top: parent.top
        anchors.topMargin: parent.height*0.05
        anchors.horizontalCenter: parent.horizontalCenter
        height: notifPanel.width * 0.08
        visible: !emptyIndicator.visible
    }

    Icon {
        id: emptyIndicator
        visible: notifmodel.itemCount === 0
        width: parent.width*0.27
        height: parent.height*0.27
        name: "ios-mail-outline"
        color: "lightgrey"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height*0.09
    }

    Text {
        visible: notifmodel.itemCount === 0
        anchors.topMargin: parent.height*0.04
        anchors.top: emptyIndicator.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("No notifications")
        font.pixelSize: parent.height*0.06
        color: "lightgrey"
    }
}

