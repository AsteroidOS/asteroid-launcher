
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2013, Jolla Ltd <robin.burchell@jollamobile.com>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>

import QtQuick 2.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Item {
    id: wrapper
    property alias source: iconImage.source
    property alias iconCaption: iconText.text
    property bool reordering
    property int newIndex: -1
    property real oldY

    onXChanged: moveTimer.start()
    onYChanged: moveTimer.start()

    Timer {
        id: moveTimer
        interval: 1
        onTriggered: moveIcon()
    }

    function moveIcon() {
        if (!reordering) {
            if (!slideMoveAnim.running) {
                slideMoveAnim.start()
            }
        }
    }

    // Application icon for the launcher
    MouseArea {
        id: launcherItem
        width: wrapper.width
        height: wrapper.height
        parent: gridview.contentItem
        scale: reordering ? 1.3 : 1
        transformOrigin: Item.Center
        onXChanged: moved()
        onYChanged: moved()

        onClicked: {
            // TODO: disallow if close mode enabled
            model.object.launchApplication()
        }

        onPressAndHold: {
            reparent(gridview)
            reorderItem = launcherItem
            drag.target = launcherItem
            z = 1000
            reordering = true

            // don't allow dragging an icon out of pages with a horizontal flick
            pager.interactive = false
        }

        onReleased: {
            if (reordering) {
                reordering = false
                reorderTimer.stop()
                drag.target = null
                reorderItem = null
                reparent(gridview.contentItem)
                slideMoveAnim.start()
                pager.interactive = true
            }
        }

        function reparent(newParent) {
            var newPos = mapToItem(newParent, 0, 0)
            parent = newParent
            x = newPos.x - width/2 * (1-scale)
            y = newPos.y - height/2 * (1-scale)
        }

        function moved() {
            if (reordering) {
                var gridViewPos = gridview.contentItem.mapFromItem(launcherItem, width/2, height/2)
                var idx = gridview.indexAt(gridViewPos.x, gridViewPos.y)
                if (newIndex !== idx) {
                    reorderTimer.restart()
                    newIndex = idx
                }
/*
                var globalY = desktop.mapFromItem(launcherItem, 0, 0).y
                if (globalY < 70) {
                    pageChangeTimer.start()
                } else {
                    pageChangeTimer.stop()
                }
*/
            }
        }

        Timer {
            id: reorderTimer
            interval: 100
            onTriggered: {
                if (newIndex != -1 && newIndex !== index) {
                    launcherModel.move(index, newIndex)
                }
                newIndex = -1
            }
        }

        Behavior on scale {
            NumberAnimation { easing.type: Easing.InOutQuad; duration: 150 }
        }

        ParallelAnimation {
            id: slideMoveAnim
            NumberAnimation { target: launcherItem; property: "x"; to: wrapper.x; duration: 130; easing.type: Easing.OutQuint }
            NumberAnimation { target: launcherItem; property: "y"; to: wrapper.y; duration: 130; easing.type: Easing.OutQuint }
        }

        Image {
            id: iconImage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 8
            }
            width: 100
            height: width
            asynchronous: true
            onStatusChanged: {
                if (status === Image.Error) {
                    console.log("Error loading an app icon, falling back to default.");
                    iconImage.source = ":/images/icons/apps.png";
                }
            }

            Spinner {
                id: spinner
                anchors.centerIn: parent
                enabled: model.object.isLaunching
            }
        }

        // Caption for the icon
        Text {
            id: iconText
            // elide only works if an explicit width is set
            width: parent.width
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 18
            color: 'white'
            anchors {
                left: parent.left
                right: parent.right
                top: iconImage.bottom
                topMargin: 5
            }
        }
    }
}
