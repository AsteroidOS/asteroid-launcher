/*
 * Copyright (C) 2021 Darrel Griët <dgriet@gmail.com>
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

import QtQuick 2.9
import QtGraphicalEffects 1.12
import org.asteroid.controls 1.0

GridView {
    id: appsView
    flow: GridView.FlowLeftToRight
    snapMode: GridView.SnapToRow
    anchors.fill: parent
    clip: true
    cellHeight: appsView.height/2
    cellWidth: appsView.width/2

    preferredHighlightBegin: width /2 - currentItem.width /2
    preferredHighlightEnd: width /2 + currentItem.width /2
    highlightRangeMode: ListView.StrictlyEnforceRange
    contentY: -(width / 2 - (width / 4))

    property int currentPos: 0

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
            if (grid.currentVerticalPos == 0) {
                appsView.highlightMoveDuration = 0
                appsView.currentIndex = 0
            } else if (grid.currentVerticalPos == 1) {
                appsView.highlightMoveDuration = 1500
                forbidTop = false
                grid.changeAllowedDirections()
            }
        }
    }

    onAtYBeginningChanged: {
        // Make sure that the grid doesn't move when the app view is visible.
        if ((grid.currentHorizontalPos == 0) && (grid.currentVerticalPos == 1)) {
            forbidTop = !atYBeginning
            grid.changeAllowedDirections()
        }
    }

    model: launcherModel

    delegate: MouseArea {
        id: launcherItem
        width: appsView.width / 2
        height: appsView.width / 2
        enabled: !appsView.dragging

        onClicked: model.object.launchApplication()

        Item {
            id: circleWrapper
            anchors.fill: parent
            Rectangle {
                id: circle
                anchors.centerIn: parent
                width: parent.width*0.8
                height: parent.height*0.8
                radius: width/2
                color: launcherItem.pressed | fakePressed ? "#cccccc" : "#f4f4f4"
            }
        }
        DropShadow {
            anchors.fill: circleWrapper
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: circleWrapper
            cached: true
        }

        Icon {
            id: icon
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: width
            color: "#666666"
            name: model.object.iconId == "" ? "ios-help" : model.object.iconId
        }

        Label {
            id: iconText
            anchors.top: icon.bottom
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            anchors.topMargin: Dims.h(5)
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.pixelSize: ((appsView.width > appsView.height ? appsView.height : appsView.width) / Dims.l(100)) * Dims.l(5)
            font.weight: Font.Medium
            text: model.object.title.toUpperCase() + localeManager.changesObserver
        }
    }

    Component.onCompleted: {
        launcherCenterColor = alb.centerColor(launcherModel.get(0).filePath);
        launcherOuterColor = alb.outerColor(launcherModel.get(0).filePath);

        toLeftAllowed = false
        toRightAllowed = false
        toBottomAllowed =  Qt.binding(function() { return !atYBeginning })
        toTopAllowed = Qt.binding(function() { return !atYEnd })
        forbidTop = Qt.binding(function() { return !atYBeginning })
        forbidBottom = false
        forbidLeft = false
        forbidRight = false
    }

    onContentYChanged: {
        var lowerStop = Math.floor(contentY/appsView.height)
        var upperStop = lowerStop+1
        var ratio = (contentY%appsView.height)/appsView.height

        if(upperStop + 1 > launcherModel.itemCount || ratio == 0) {
            launcherCenterColor = alb.centerColor(launcherModel.get(lowerStop).filePath);
            launcherOuterColor = alb.outerColor(launcherModel.get(lowerStop).filePath);
            return;
        }

        if(lowerStop < 0) {
            launcherCenterColor = alb.centerColor(launcherModel.get(0).filePath);
            launcherOuterColor = alb.outerColor(launcherModel.get(0).filePath);
            return;
        }

        var upperCenterColor = alb.centerColor(launcherModel.get(upperStop).filePath);
        var lowerCenterColor = alb.centerColor(launcherModel.get(lowerStop).filePath);

        launcherCenterColor = Qt.rgba(
                    upperCenterColor.r * ratio + lowerCenterColor.r * (1-ratio),
                    upperCenterColor.g * ratio + lowerCenterColor.g * (1-ratio),
                    upperCenterColor.b * ratio + lowerCenterColor.b * (1-ratio)
                );

        var upperOuterColor = alb.outerColor(launcherModel.get(upperStop).filePath);
        var lowerOuterColor = alb.outerColor(launcherModel.get(lowerStop).filePath);

        launcherOuterColor = Qt.rgba(
                    upperOuterColor.r * ratio + lowerOuterColor.r * (1-ratio),
                    upperOuterColor.g * ratio + lowerOuterColor.g * (1-ratio),
                    upperOuterColor.b * ratio + lowerOuterColor.b * (1-ratio)
                );

        currentPos = Math.round(lowerStop+ratio)
    }
}
