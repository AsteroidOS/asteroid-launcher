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

import QtQuick 2.0
import org.nemomobile.lipstick 0.1

ListView {
    id: appsListView
    orientation: ListView.Horizontal
    snapMode: ListView.SnapToItem

    property bool toTopAllowed:    false
    property bool toBottomAllowed: false
    property bool toLeftAllowed:   true
    property bool toRightAllowed:  false
    property int currentPos: 0

    onCurrentPosChanged: {
        toLeftAllowed = (currentPos!=launcherModel.itemCount-1)
        toRightAllowed  = (currentPos!=0)

        rightIndicator.animate()
        leftIndicator.animate()
        topIndicator.animate()
        bottomIndicator.animate()
    }

    model: LauncherModel { id: launcherModel }

    delegate: LauncherItemDelegate {
        id: launcherItem
        width: appsListView.width
        height: appsListView.width
        iconName: model.object.iconId == "" ? "ios-help" : model.object.iconId
        iconCaption: model.object.title.toUpperCase()
        enabled: !appsListView.dragging
    }

    Component.onCompleted: {
        launcherCenterColor = alb.centerColor(launcherModel.get(0).filePath);
        launcherOuterColor = alb.outerColor(launcherModel.get(0).filePath);
    }

    onContentXChanged: {
        var lowerStop = Math.floor(contentX/appsListView.width)
        var upperStop = lowerStop+1
        var ratio = (contentX%appsListView.width)/appsListView.width

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

    Text {
        id: emptyIndicator
        visible: launcherModel.itemCount === 0
        horizontalAlignment: Text.AlignHCenter

        text: "<b>No apps<br>installed</b>"
        font.pointSize: 12
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
    }
}
