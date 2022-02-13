/*
 * Copyright (C) 2022 Timo Könnecke <github.com/eLtMosen>
 *               2021 Darrel Griët <dgriet@gmail.com>
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

Item {
    id: root

    property int currentPressedIndex: 0
    property bool clickToggle: false
    property bool pressToggle: false
    property bool dragStop: false
    property string appTitle: ""
    property real clickY: 0

    GridView {
        id: appsView

        flow: GridView.FlowLeftToRight
        snapMode: GridView.SnapToRow
        anchors.fill: parent
        anchors.leftMargin: parent.width * .026
        anchors.rightMargin: parent.width * .026
        clip: true
        cellHeight: appsView.height / 3.15
        cellWidth: appsView.width / 3
        preferredHighlightBegin: width / 3 - currentItem.width / 3
        preferredHighlightEnd: width / 3 + currentItem.width / 3
        highlightRangeMode: ListView.StrictlyEnforceRange
        contentY: -(width / 3 - (width / 6))

        property int currentPos: 0

        onCurrentPosChanged: {
            rightIndicator.animate()
            leftIndicator.animate()
            topIndicator.animate()
            bottomIndicator.animate()
        }

        onDragStarted: {
            dragStop = true
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
            id: launcherItem

            width: appsView.width / 3
            height: width
            enabled: !appsView.dragging

            property int pressAndHoldDuration: 200
            signal timedPressAndHold()

            Timer {
                id:  pressAndHoldTimer

                property bool dragStopper: dragStop

                interval: parent.pressAndHoldDuration
                running: false
                repeat: false
                onTriggered: {
                     if (!dragStopper) {
                         parent.timedPressAndHold()
                     }
                     else {
                         root.dragStop = false
                     }
                }
            }

            onClicked: {
                clickToggle = true
                model.object.launchApplication()
            }

            onPressed: {
                pressAndHoldTimer.start();
                root.dragStop = false
            }

            onPressedChanged: {
                appTitle = model.object.title
            }

            onReleased: {
                pressAndHoldTimer.stop();
            }

            onTimedPressAndHold: {
                appTitle = model.object.title
                clickToggle = false
                pressToggle ? pressToggle = false : pressToggle = true
                currentPressedIndex = index
            }

            Connections {
                target: appLauncher
                function onFakePressedChanged() {
                    appTitle = model.object.title                   
                }
            }

            Item {
                id: circleWrapper

                width: parent.width * .86
                height: width
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * .08
                }

                Rectangle {
                    id: circle

                    anchors.centerIn: parent
                    width: parent.width
                    height: width
                    radius: width/2
                    color: !pressAndHoldTimer.running ?
                               launcherItem.pressed | fakePressed ?
                                           alb.centerColor(launcherModel.get(currentPressedIndex).filePath) :
                                           "#f4f4f4" : "#f4f4f4"
                    Behavior on color {
                        PropertyAnimation { target: circle; property: "color"; duration: 70 }
                    }
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

                width: circleWrapper.width * .70
                height: width
                anchors.centerIn: circleWrapper
                color: !pressAndHoldTimer.running ?
                           launcherItem.pressed | fakePressed ?
                                       "#ffffff" :
                                       "#555555" : "#555555"
                name: model.object.iconId === "" ? "ios-help" : model.object.iconId
                Behavior on color {
                    PropertyAnimation { target: icon; property: "color"; duration: 70 }
                }
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

    MouseArea {
        id: absoluteMouse

        anchors.fill: parent
        propagateComposedEvents: true

        onPressed: {
            clickY = Math.round(mouse.y)
            mouse.accepted = false
        }
        onClicked: mouse.accepted = false
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPositionChanged: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }

    Rectangle {
        id: titleShutter

        opacity: 0
        visible: !root.clickToggle
        anchors.centerIn: hoverTitle
        width: root.width
        height: root.height * .22
        color: alb.centerColor(launcherModel.get(currentPressedIndex).filePath)
    }

    Text {
        id: hoverTitle

        property string tempTitle: appTitle
        property real hoverTextOffset: root.clickY > Dims.h(48) ? -Dims.h(62) : Dims.h(62)
        property bool rootPressToggle: root.pressToggle

        width: parent.width
        color: "#ffffff"
        opacity: 0
        visible: !root.clickToggle
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
        style: Text.Outline;
        styleColor: alb.centerColor(launcherModel.get(currentPressedIndex).filePath)
        font {
            pixelSize: ((appsView.width > appsView.height ? appsView.height : appsView.width) / Dims.l(100)) * Dims.l(8)
            styleName: "Condensed Medium"
            letterSpacing: -parent.width * .002
        }
        text: appTitle.toUpperCase() + localeManager.changesObserver

        Behavior on rootPressToggle {
            SequentialAnimation {
                id: fadeText

                NumberAnimation { target: hoverTitle; property: "anchors.verticalCenterOffset"; to: hoverTitle.hoverTextOffset; duration: 0}
                NumberAnimation { target: hoverTitle; property: "opacity"; to: 1; duration: 0}
                NumberAnimation { target: titleShutter; property: "opacity"; to: .85; duration: 0}

                PropertyAction{}

                NumberAnimation { target: hoverTitle; property: "anchors.verticalCenterOffset"; to: -hoverTitle.hoverTextOffset + (hoverTitle.hoverTextOffset * 1.62); duration: 100; easing.type: Easing.InSine}

                PauseAnimation { duration: 800 }

                ParallelAnimation {
                    NumberAnimation { target: hoverTitle; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InSine}
                    NumberAnimation { target: titleShutter; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InSine}
                    NumberAnimation { target: hoverTitle; property: "anchors.verticalCenterOffset"; to: hoverTitle.hoverTextOffset; duration: 200; easing.type: Easing.InSine}
                }
            }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 2.0
            samples: 5
            color: "#88000000"
        }
    }
}
