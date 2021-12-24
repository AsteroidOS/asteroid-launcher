/*
 * Copyright (C) 2021 Timo Könnecke <github.com/eLtMosen>
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

ListView {
    id: appsListView
    orientation: ListView.Horizontal
    snapMode: ListView.SnapToItem
    anchors.fill: parent
    clip: true

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
            if (grid.currentVerticalPos === 1) {
                grid.changeAllowedDirections()
            }
        }
    }

    model: launcherModel

    delegate: MouseArea {
        id: launcherItem
        width: appsListView.width
        height: width
        enabled: !appsListView.dragging

        onClicked: model.object.launchApplication()

        Item {
            id: circleWrapper
            anchors.fill: parent
            Rectangle {
                id: circle
                anchors.centerIn: parent
                width: parent.width * 0.7
                height: width
                radius: width/2
                color: launcherItem.pressed | fakePressed ? "#cccccc" : "#f4f4f4"
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
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -parent.height * 0.03
            width: parent.width * 0.31
            height: width
            color: launcherItem.pressed | fakePressed ? "#444444" : "#666666"
            name: model.object.iconId === "" ? "ios-help" : model.object.iconId
        }

        Label {
            id: iconText
            anchors.top: icon.bottom
            width: parent.width * 0.5
            horizontalAlignment: Text.AlignHCenter
            anchors.topMargin: parent.height * 0.04
            anchors.horizontalCenter: parent.horizontalCenter
            color: launcherItem.pressed | fakePressed ? "#444444" : "#666666"
            font.pixelSize: ((appsListView.width > appsListView.height ? appsListView.height : appsListView.width) / Dims.l(100)) * Dims.l(5)
            font.weight: Font.Medium
            text: model.object.title.toUpperCase() + localeManager.changesObserver
        }
    }

    Component.onCompleted: {
        launcherCenterColor = alb.centerColor(launcherModel.get(0).filePath);
        launcherOuterColor = alb.outerColor(launcherModel.get(0).filePath);

        toLeftAllowed = Qt.binding(function() { return !atXEnd })
        toRightAllowed = Qt.binding(function() { return !atXBeginning })

        toTopAllowed = false
        toBottomAllowed = true
        forbidTop = false
        forbidBottom = false
        forbidLeft = false
        forbidRight = false
        launcherColorOverride = false
        if (grid.currentVerticalPos === 1) {
            grid.changeAllowedDirections()
        }
    }

    onContentXChanged: {
        var lowerStop = Math.floor(contentX/appsListView.width)
        var upperStop = lowerStop+1
        var ratio = (contentX%appsListView.width)/appsListView.width

        if(upperStop + 1 > launcherModel.itemCount || ratio === 0) {
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
