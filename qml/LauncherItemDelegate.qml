/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2013 Jolla Ltd <robin.burchell@jollamobile.com>
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

import QtQuick 2.0
import QtGraphicalEffects 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: wrapper
    property alias source: iconImage.source
    property alias iconCaption: iconText.text

    GridView {
        id: folderLoader
        anchors.top: parent.bottom
        width: appsListView.width
        height: childrenRect.height
        cellWidth: 115
        cellHeight: cellWidth + 30
        Rectangle {
            anchors.fill: parent
            opacity: 0.75
            color: "white"
        }

        delegate: MouseArea {
            width: appsListView.cellWidth
            height: appsListView.cellHeight
            Image {
                id: iconimage
                source: model.object.iconId == "" ? "image://theme/help" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
            }
            Text {
                id: icontext
                // elide only works if an explicit width is set
                width: parent.width
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18
                color: 'white'
                anchors {
                    left: parent.left
                    right: parent.right
                    top: iconimage.bottom
                    topMargin: 5
                }

                DropShadow {
                    anchors.fill: icontext
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8.0
                    samples: 16
                    color: "#80000000"
                    source: icontext
                }
            }
            onClicked: {
                model.object.launchApplication()
            }
        }
    }

    // Application icon for the launcher
    MouseArea {
        id: launcherItem
        width: wrapper.width
        height: wrapper.height
        transformOrigin: Item.Center

        onClicked: {
            // TODO: disallow if close mode enabled
            if (model.object.type !== LauncherModel.Folder) {
                var winId = switcher.switchModel.getWindowIdForTitle(model.object.title)
                console.log("Window id found: " + winId)
                if (winId == 0)
                    model.object.launchApplication()
                else
                    Lipstick.compositor.windowToFront(winId)
            } else {
                if (!folderLoader.visible) {
                    folderLoader.visible = true
                    folderLoader.model = model.object
                } else {
                    folderLoader.visible = false
                }
            }
        }

        onPressAndHold: {
            // Show a similar cross as AppSwitcher
        }

        Image {
            id: iconImage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 8
            }
            width: wrapper.width* 0.8
            height: width
            asynchronous: true
        }
        BrightnessContrast {
            anchors.fill: iconImage
            source: iconImage
            visible: launcherItem.pressed
            brightness: -0.3
        }

        // Caption for the icon
        Text {
            id: iconText
            // elide only works if an explicit width is set
            width: parent.width
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 23
            color: 'white'
            anchors {
                left: parent.left
                right: parent.right
                top: iconImage.bottom
                topMargin: 5
            }
        }
        DropShadow {
            anchors.fill: iconText
            horizontalOffset: 3
            verticalOffset: 3
            radius: 8.0
            samples: 16
            color: "#80000000"
            source: iconText
        }
    }
}
