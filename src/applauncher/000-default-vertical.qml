/*
 * Copyright (C) 2022 Timo Könnecke <github.com/eLtMosen>
 *               2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2012 Timur Kristóf <venemo@fedoraproject.org>
 *               2011 Tom Swindell <t.swindell@rubyx.co.uk>
 * All rights reserved.
 *
 * BSD License (same as provided)
 */

import QtQuick 2.9
import QtGraphicalEffects 1.12
import org.asteroid.controls 1.0
import Nemo.DBus 2.0

Item {
    id: root
    property alias currentIndex: appsListView.currentIndex
    property alias count: appsListView.count
    property int lastLaunchedIndex: 0

    anchors.fill: parent

    // Debug MouseArea to trace all touch events
    MouseArea {
        id: debugTouchArea
        anchors.fill: parent
        z: 1000
        propagateComposedEvents: true
        enabled: true

        onPressed: {
            console.log("DebugTouch: Pressed at y=", mouseY, "screen height=", parent.height)
            mouse.accepted = false
        }
        onPositionChanged: {
            console.log("DebugTouch: Moved to y=", mouseY, "deltaY=", mouseY - startY)
            mouse.accepted = false
        }
        onReleased: {
            console.log("DebugTouch: Released")
            mouse.accepted = false
        }
        property real startY: 0
        onPressedChanged: { if (pressed) startY = mouseY }
    }

    ListView {
        id: appsListView

        orientation: ListView.Vertical
        snapMode: ListView.SnapToItem
        width: parent.width > parent.height ? parent.height : parent.width
        height: parent.height
        anchors.centerIn: parent
        clip: true
        cacheBuffer: height * 2

        property int currentPos: 0

        onCurrentPosChanged: {
            rightIndicator.animate()
            leftIndicator.animate()
            topIndicator.animate()
            bottomIndicator.animate()
        }

        onAtYBeginningChanged: {
            if ((grid.currentHorizontalPos === 0) && (grid.currentVerticalPos === 1)) {
                forbidTop = !atYBeginning
                grid.changeAllowedDirections()
            }
        }

        Connections {
            target: grid
            function onCurrentVerticalPosChanged() {
                console.log("Grid: currentVerticalPos=", grid.currentVerticalPos, "lastLaunchedIndex=", root.lastLaunchedIndex)
                if (grid.currentVerticalPos === 0) {
                    appsListView.highlightMoveDuration = 0
                    appsListView.currentIndex = 0
                    root.lastLaunchedIndex = 0
                } else if (grid.currentVerticalPos === 1) {
                    appsListView.highlightMoveDuration = 1500
                    forbidTop = !appsListView.atYBeginning
                    grid.changeAllowedDirections()
                    if (root.lastLaunchedIndex > 0) {
                        appsListView.positionViewAtIndex(root.lastLaunchedIndex, ListView.Center)
                    } else {
                        appsListView.positionViewAtIndex(0, ListView.Beginning)
                    }
                }
            }
        }

        model: launcherModel

        delegate: MouseArea {
            id: launcherItem

            width: appsListView.width
            height: width
            enabled: !appsListView.dragging

            onClicked: {
                root.lastLaunchedIndex = index
                model.object.launchApplication()
            }

            DropShadow {
                anchors.fill: circleWrapper
                horizontalOffset: 0
                verticalOffset: 0
                radius: 8.0
                samples: 17
                color: "#66000000"
                source: circleWrapper
                cached: true
            }

            Item {
                id: circleWrapper

                anchors.fill: parent

                Rectangle {
                    id: circle

                    anchors.centerIn: parent
                    width: parent.width * .65
                    height: width
                    radius: width/2
                    color: launcherItem.pressed | fakePressed ? "#dddddd" : "#f8f8f8"
                    opacity: launcherItem.pressed | fakePressed ? .6 : 1

                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
            }

            Icon {
                id: icon

                name: model.object.iconId === "" ? "ios-help" : model.object.iconId
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.03
                }
                width: parent.width * .30
                height: width
                color: launcherItem.pressed | fakePressed ? "#333" : "#666"
            }

            Label {
                id: iconText

                text: model.object.title.toUpperCase() + localeManager.changesObserver
                anchors {
                    top: icon.bottom
                    topMargin: parent.height * 0.024
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width * 0.5
                horizontalAlignment: Text.AlignHCenter
                color: launcherItem.pressed | fakePressed ? "#333" : "#666"
                font {
                    pixelSize: ((appsListView.width > appsListView.height ?
                                    appsListView.height :
                                    appsListView.width) / Dims.l(100)) * Dims.l(5)
                    styleName: "SemiBold"
                }
            }
        }

        Component.onCompleted: {
            launcherCenterColor = alb.centerColor(launcherModel.get(0).filePath);
            launcherOuterColor = alb.outerColor(launcherModel.get(0).filePath);

            toLeftAllowed = false
            toRightAllowed = false
            toBottomAllowed = Qt.binding(function() { return !atYEnd })
            toTopAllowed = Qt.binding(function() { return !atYBeginning })
            forbidTop = Qt.binding(function() { return !atYBeginning })
            forbidBottom = false
            forbidLeft = true
            forbidRight = true
            launcherColorOverride = false
            positionViewAtIndex(0, ListView.Beginning)
        }

        onContentYChanged: {
            var lowerStop = Math.floor(contentY/appsListView.height)
            var upperStop = lowerStop+1
            var ratio = (contentY%appsListView.height)/appsListView.height

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

    // DBus interface for Lipstick
    DBusInterface {
        id: lipstick
        service: "org.nemomobile.lipstick"
        path: "/org/nemomobile/lipstick"
        iface: "org.nemomobile.lipstick"
    }

    // Top-down edge swipe with single trigger
    MultiPointTouchArea {
        id: topEdgeSwipeArea
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: parent.height * 0.25
        z: 999
        touchPoints: [ TouchPoint { id: point1 } ]
        enabled: !appsListView.atYBeginning && grid.currentVerticalPos === 1

        property real startY: 0
        property bool swipeTriggered: false

        onPressed: {
            console.log("TopEdge: Pressed at y=", point1.y)
            startY = point1.y
            swipeTriggered = false
        }

        onUpdated: {
            var deltaY = point1.y - startY
            console.log("TopEdge: Moved to y=", point1.y, "deltaY=", deltaY)
            if (swipeTriggered || (Math.abs(deltaY) > 20 && deltaY > 0)) {
                console.log("TopEdge: Downward swipe detected, exiting")
                swipeTriggered = true

                var contentY = grid.contentY + deltaY
                var currentPanelY = -grid.currentVerticalPos*grid.panelHeight
                contentY = Math.max(contentY, currentPanelY + -grid.panelHeight)
                grid.contentY = contentY

                root.lastLaunchedIndex = 0
            }
        }

        onReleased: {
            console.log("TopEdge: Released")
            if (swipeTriggered) {
                swipeTriggered = false
                grid.moveTo(0, 0)
            }
        }
    }
}
