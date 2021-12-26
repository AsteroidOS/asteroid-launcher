/*
 * Copyright (C) 2021 Darrel Griët <dgriet@gmail.com>
 *               2021 Timo Könnecke <github.com/eLtMosen>
 *               2015 Florent Revest <revestflo@gmail.com>
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

import QtQuick 2.15
import QtGraphicalEffects 1.12
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

ListView {
    id: appsView
    anchors.fill: parent
    preferredHighlightBegin: appsView.height/2 - appsView.height/12
    preferredHighlightEnd: appsView.height/2 + appsView.height/12
    highlightRangeMode: ListView.StrictlyEnforceRange

    property int currentPos: 0
    // Scaling for when the launcher is shown as full screen (1.0) or in the settings app (0.5).
    property var viewScale: (appsView.width > appsView.height ? appsView.height : appsView.width) / Dims.l(100)

    onCurrentPosChanged: {
        rightIndicator.animate()
        leftIndicator.animate()
        topIndicator.animate()
        bottomIndicator.animate()
    }

    Connections {
        target: grid
        function onCurrentVerticalPosChanged() {
            // Move app view to beginning when the watchface is visible.
            if (grid.currentVerticalPos === 0) {
                appsView.highlightMoveDuration = 0
                appsView.currentIndex = 0
            } else if (grid.currentVerticalPos === 1) {
                appsView.highlightMoveDuration = 1500
                forbidTop = false
                grid.changeAllowedDirections()
            }
        }
    }

    onAtYBeginningChanged: {
        // Make sure that the grid doesn't move when the app view is visible.
        if ((grid.currentHorizontalPos === 0) && (grid.currentVerticalPos === 1)) {
            forbidTop = !atYBeginning
            grid.changeAllowedDirections()
        }
    }
    model: launcherModel

    delegate: MouseArea {
        // We want items to move to the left when an item is near the middle of the screen:
        //  / 1
        // | 2
        //  \ 3
        // To achieve this we need to know the current y location of the element. This is provided by the FileModel.
        // Using the index of the item and the current location of the top of the listview(contentY) we can find the location of a specific item.
        // Next we use the Pythagoras rule (x^2+y^2=r^2) to align the item around the left edge.
        // Rewriting Pythagoras rule: sqrt(r^2 - y^2) => sqrt(listview_height/2^2 - location_item_y^2)
        // Finally we add a small padding (Dims.w(5)) so that the item is not touching the left 'bezel'.
        property var screenRadius: appsView.height/2
        property var itemLocationY: (launcherItem.height * (appsView.contentY/launcherItem.height - index) - launcherItem.height/2)
        property var bezelOffset: screenRadius - Math.sqrt(Math.pow(screenRadius, 2) - Math.pow((screenRadius + itemLocationY),2))
        property var normalizedBezelOffset: 1.0 - (bezelOffset / screenRadius)

        id: launcherItem
        height: appsView.height/6
        width: appsView.width
        enabled: !appsView.dragging
        opacity: normalizedBezelOffset

        onClicked: model.object.launchApplication()

        Item {
            width: parent.width
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: (DeviceInfo.hasRoundScreen ? bezelOffset : 0) + Dims.w(5)

            Item {
                id: circleWrapper
                width: parent.height * 0.8
                height: width
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                Rectangle {
                    id: circle
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: width/2
                    opacity: launcherItem.pressed | fakePressed ? 0.8 : 1.0
                    color: alb.centerColor(launcherModel.get(index).filePath)
                    Behavior on opacity {
                        PropertyAnimation {
                            target: circle
                            duration: 70
                        }
                    }
                }
            }
            DropShadow {
                anchors.fill: circleWrapper
                horizontalOffset: 0
                verticalOffset: 0
                radius: 8.0
                samples: 12
                color: "#80000000"
                source: circleWrapper
                cached: true
            }

            Icon {
                id: icon
                anchors.centerIn: circleWrapper
                width: circleWrapper.width * 0.70
                height: width
                color: launcherItem.pressed | fakePressed ? "#ffffffff" : "#eeffffff"
                name: model.object.iconId === "" ? "ios-help" : model.object.iconId
                Behavior on color {
                    PropertyAnimation {
                                    target: icon
                                    property: "color"
                                    duration: 70

                                }
                }
            }
            Label {
                id: iconText
                anchors.left: circleWrapper.right
                width: parent.width
                anchors.leftMargin: parent.width * 0.04
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: (Math.exp((normalizedBezelOffset)) - 1) * viewScale * Dims.l(6)
                font.letterSpacing: Dims.l(0.2)
                font.styleName: "Bold"
                style: (normalizedBezelOffset >= 0.99) ? Text.Outline : Text.Normal
                styleColor: alb.centerColor(launcherModel.get(index).filePath)
                text: model.object.title + localeManager.changesObserver
            }
        }
    }

    Component.onCompleted: {
        toLeftAllowed = false
        toRightAllowed = false
        toBottomAllowed =  Qt.binding(function() { return !atYBeginning })
        toTopAllowed = Qt.binding(function() { return !atYEnd })
        forbidTop = Qt.binding(function() { return !atYBeginning })
        forbidBottom = false
        forbidLeft = false
        forbidRight = false
        launcherColorOverride = true
    }

    onContentYChanged: {
        var lowerStop = Math.floor(contentY/(appsView.height/6))
        var upperStop = lowerStop+1
        var ratio = (contentY%appsView.height)/(appsView.height/6)
        currentPos = Math.round(lowerStop+ratio)
    }
}
