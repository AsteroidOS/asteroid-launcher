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
import org.nemomobile.lipstick 0.1
import org.asteroid.controls 1.0

Item {
    id: notifIndic
    property QtObject panelsGrid
    property real iconSize: height
    property int currentIndex
    property var icons: []
    visible: false

    Item {
        id: content
        x: notifIndic.width/2
        
        Rectangle {
            id: separator
            visible: notifModel.itemCount !== 0
            x: iconSize*1.1
            width: 1
            height: iconSize
            color: "#8e8e8e"
        }

        Icon {
            visible: notifModel.itemCount !== 0
            name: "ios-time"
            color: "#8e8e8e"
            width: iconSize
            height: iconSize
            anchors.leftMargin: iconSize/10
            anchors.left: separator.right
        }
    }

    Component {
        id: iconComponent;
        Icon {
            property QtObject notification
            property int index: 0
            
            name: {
                if(notification==null)
                    return "";

                function noicon(str) {
                    return str === "" || str === null || str === undefined;
                }
                if(noicon(notification.icon) && noicon(notification.appIcon))
                    return "ios-mail-outline";
                if(noicon(notification.icon) && !noicon(notification.appIcon))
                    return notification.appIcon;
                if(!noicon(notification.icon) && noicon(notification.appIcon))
                    return notification.icon;

                return notification.icon;
            }
            color: index == notifIndic.currentIndex ? "#FFFFFF" : "#8e8e8e"
        }
    }

    function addIcon(pos, item) {
        if (iconComponent.status === Component.Ready) {
            var icon = iconComponent.createObject(content)
            icon.x = iconSize*pos
            icon.y = 0
            icon.width = iconSize
            icon.height = iconSize
            icon.notification = item
            icon.index = pos
            icons[pos] = icon
        }
    }

    function moveIcon(originPos, destPos) {
        var icon = icons[originPos]
        if(icon !== undefined) {
            icons[destPos] = icon
            icon.x = iconSize*destPos
            icon.index = destPos
            icons[originPos] = undefined
        }
    }

    function removeIcon(pos) {
        var icon = icons[pos]
        if(icon !== undefined)
            icon.destroy()
        icons[pos] = undefined
    }

    function moveTo(pos) {
        content.x = notifIndic.width/2 - iconSize/2 -iconSize*pos
        currentIndex = pos
    }

    Connections {
        target: panelsGrid

        function makeVisible() {
            if((panelsGrid.currentVerticalPos == 0 && panelsGrid.currentHorizontalPos < 0) && !Lipstick.compositor.displayAmbient) {
                notifIndic.visible = true
                moveTo(panelsGrid.currentHorizontalPos+1)
            } else
                notifIndic.visible = false
        }

        onCurrentHorizontalPosChanged: makeVisible()
        onCurrentVerticalPosChanged: makeVisible()
    }

    NotificationListModel {
        id: notifModel
        onItemAdded: {
            var index = notifModel.indexOf(item)

            var leftIconIndex = notifModel.itemCount
            while(leftIconIndex > index) {
                moveIcon(-leftIconIndex+1, (-leftIconIndex))
                leftIconIndex--
            }

            addIcon(-index, item)
        }

        onRowsRemoved: {
            for (var i = first ; i <= last; i++)
                removeIcon(-i)

            for (var i = last+1 ; i <= notifModel.itemCount+1; i++)
                moveIcon(-i, -i+(last-first+1))
        }
    }
}
