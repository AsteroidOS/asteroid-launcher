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
import org.asteroid.controls 1.0
import "desktop.js" as Desktop

Item {
    id: tuto
    anchors.fill: parent

    property int opacityAnimDuration: 1000
    property real backgroundOpacity: 0.85
    property int pauseDuration: 1000

    state: "WELCOME"

    states: [
        State { name: "WELCOME" },
        State { name: "INDICATORS" },
        State { name: "NOTIFICATIONS" },
        State { name: "TODAY" },
        State { name: "QUICKSETTINGS" },
        State { name: "APPLICATIONS" },
        State { name: "STARTAPP" },
        State { name: "LEAVEAPP" },
        State { name: "ENJOY" },
        State { name: "DONE" }
    ]

    Component.onCompleted: {
        centerIcon.name = "logo-asteroidos"
        //% "Welcome."
        title.text = Qt.binding(function() { return qsTrId("id-tutorial-welcome-title") + localeManager.changesObserver })
        //% "This is AsteroidOS."
        subtitle.text = Qt.binding(function() { return qsTrId("id-tutorial-welcome-subtitle") + localeManager.changesObserver })
    }

    transitions: [
        Transition {
            from: "WELCOME"
            to: "INDICATORS"
            ScriptAction {
                script: {
                    centerIcon.name = "ios-move"
                    //% "Indicators"
                    title.text = qsTrId("id-tutorial-indicators-title")
                    //% "show you possible gestures."
                    subtitle.text = qsTrId("id-tutorial-indicators-subtitle")
                    nextButton.enabled = true 
                }
            }
        },
        Transition {
            from: "INDICATORS"
            to: "NOTIFICATIONS"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        centerIcon.name = "ios-arrow-round-back"
                        //% "Notifications"
                        title.text = qsTrId("id-tutorial-notifications-title")
                        //% "can be accessed on the left."
                        subtitle.text = qsTrId("id-tutorial-notifications-subtitle")
                    }
                }

                ScriptAction { script: Desktop.panelsGrid.animateIndicators() }
                PauseAnimation { duration: pauseDuration }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            from: "NOTIFICATIONS"
            to: "TODAY"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        centerIcon.name = "ios-arrow-round-forward"
                        //% "Today's Events"
                        title.text = qsTrId("id-tutorial-today-title")
                        //% "are on the right."
                        subtitle.text = qsTrId("id-tutorial-today-subtitle")
                        finger.x = Dims.w(10)
                        finger.y = Dims.h(43)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentX"; from: 0.0; to: Dims.w(100); duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(10); to: Dims.w(76); duration: 600 }
                }

                ScriptAction { script: { Desktop.panelsGrid.currentHorizontalPos = -1
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }
                PauseAnimation { duration: pauseDuration }
                ScriptAction { script: finger.opacity = 0.8 }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentX"; from: Dims.w(100); to: 0.0; duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(76); to: Dims.w(10); duration: 600 }
                }

                ScriptAction { script: { Desktop.panelsGrid.currentHorizontalPos = 0
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            from: "TODAY"
            to: "QUICKSETTINGS"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        centerIcon.name = "ios-arrow-round-up"
                        //% "Quick Panel"
                        title.text = qsTrId("id-tutorial-quickpanel-title")
                        //% "is up here."
                        subtitle.text = qsTrId("id-tutorial-quickpanel-subtitle")
                        finger.x = Dims.w(76)
                        finger.y = Dims.h(43)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentX"; from: 0.0; to: -Dims.w(100); duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(76); to: Dims.w(10); duration: 600 }
                }

                ScriptAction { script: { Desktop.panelsGrid.currentHorizontalPos = 1
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }
                PauseAnimation { duration: pauseDuration }
                ScriptAction { script: finger.opacity = 0.8 }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentX"; from: -Dims.w(100); to: 0.0; duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(10); to: Dims.w(76); duration: 600 }
                }

                ScriptAction { script: { Desktop.panelsGrid.currentHorizontalPos = 0
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            from: "QUICKSETTINGS"
            to: "APPLICATIONS"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        centerIcon.name = "ios-arrow-round-down"
                        //% "Apps"
                        title.text = qsTrId("id-tutorial-applications-title")
                        //% "are down there."
                        subtitle.text = qsTrId("id-tutorial-applications-subtitle")
                        finger.y = Dims.h(10)
                        finger.x = Dims.w(43)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentY"; from: 0.0; to: Dims.h(100); duration: 600 }
                    NumberAnimation { target: finger; property: "y"; from: Dims.h(10); to: Dims.h(76); duration: 600 }
                }

                ScriptAction { script: { Desktop.panelsGrid.currentVerticalPos = -1
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }
                PauseAnimation { duration: pauseDuration }
                ScriptAction { script: finger.opacity = 0.8 }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentY"; from: Dims.h(100); to: 0.0; duration: 600 }
                    NumberAnimation { target: finger; property: "y"; from: Dims.h(76); to: Dims.h(10); duration: 600 }
                }

                ScriptAction { script: { Desktop.panelsGrid.currentVerticalPos = 0
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            from: "APPLICATIONS"
            to: "STARTAPP"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        centerIcon.name = "ios-log-in"
                        //% "Start an app"
                        title.text = qsTrId("id-tutorial-startapp-title")
                        //% "by pressing its icon."
                        subtitle.text = qsTrId("id-tutorial-startapp-subtitle")
                        finger.x = Dims.w(43)
                        finger.y = Dims.w(76)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentY"; from: 0.0; to: -Dims.h(100); duration: 600 }
                    NumberAnimation { target: finger; property: "y"; from: Dims.h(76); to: Dims.h(10); duration: 600 }
                }
                ScriptAction { script: { Desktop.panelsGrid.currentVerticalPos = 1
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }
                PauseAnimation { duration: pauseDuration }
                ScriptAction {
                    script: {
                        finger.x = Dims.w(80)
                        finger.y = Dims.h(43)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.appLauncher; property: "contentX"; from: 0.0; to: Dims.w(200); duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(80); to: Dims.w(-20); duration: 500 }
                }
                ScriptAction { script: { Desktop.panelsGrid.currentVerticalPos = 1
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }
                PauseAnimation { duration: 300 }
                ScriptAction { script: finger.opacity = 0.8 }
                ParallelAnimation {
                    NumberAnimation { target: Desktop.appLauncher; property: "contentX"; from: Dims.w(200); to: Dims.w(100); duration: 600 }
                    SequentialAnimation {
                        NumberAnimation { target: finger; property: "x"; from: Dims.w(20); to: Dims.w(50); duration: 300 }
                        ScriptAction { script: finger.opacity = 0.0 }
                    }
                }
                ScriptAction { script: finger.opacity = 0.0 }

                PauseAnimation { duration: pauseDuration }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            from: "STARTAPP"
            to: "LEAVEAPP"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        centerIcon.name = "ios-log-out"
                        //% "Leave an app"
                        title.text = qsTrId("id-tutorial-leaveapp-title")
                        //% "following a rightward gesture."
                        subtitle.text = qsTrId("id-tutorial-leaveapp-subtitle")
                        finger.y = Dims.h(43)
                        finger.x = Dims.w(43)
                        finger.opacity = 0.8
                    }
                }

                ScriptAction {
                    script: {
                        Desktop.appLauncher.fakePressed = true
                        finger.opacity = 0.8
                    }
                }
                PauseAnimation { duration: 500 }
                ScriptAction {
                    script: {
                        Desktop.appLauncher.fakePressed = false
                        finger.opacity = 0.0
                    }
                }

                NumberAnimation { target: fakeAlarmclock; property: "x"; from: Dims.w(100); to: 0.0; duration: 200 }
                ScriptAction { script: fakeAlarmclock.animIndicators() }
                PauseAnimation { duration: pauseDuration }

                ScriptAction {
                    script: {
                        fakeAlarmclock.fakePressed = true
                        finger.opacity = 0.8
                    }
                }
                PauseAnimation { duration: 500 }
                ScriptAction {
                    script: {
                        fakeAlarmclock.fakePressed = false
                        finger.opacity = 0.0
                    }
                }

                NumberAnimation { target: fakeAlarmclock; property: "contentX"; from: 0.0; to: Dims.w(100); duration: 200 }
                ScriptAction { script: fakeAlarmclock.animIndicators() }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            from: "LEAVEAPP"
            to: "ENJOY"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }

                ScriptAction {
                    script: {
                        Desktop.appLauncher.contentX = 0.0

                        centerIcon.name = "ios-happy-outline"
                        //% "Enjoy!"
                        title.text = qsTrId("id-tutorial-enjoy-title")
                        subtitle.text = ""
                        nextButton.iconName = "ios-arrow-dropright"
                        finger.x = Dims.w(00)
                        finger.y = Dims.h(43)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: fakeAlarmclock; property: "contentX"; from: Dims.w(100); to: 0.0; duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(00); to: Dims.w(80); duration: 600 }
                }
                ScriptAction { script: fakeAlarmclock.animIndicators() }

                ScriptAction { script: finger.opacity = 0.0 }
                PauseAnimation { duration: pauseDuration }
                ScriptAction {
                    script: {
                        finger.opacity = 0.8
                        finger.x = Dims.w(00)
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: fakeAlarmclock; property: "x"; from: 0.0; to: Dims.w(100); duration: 600 }
                    NumberAnimation { target: finger; property: "x"; from: Dims.w(00); to: Dims.w(80); duration: 600 }
                }

                ScriptAction { script: finger.opacity = 0.0 }
                PauseAnimation { duration: pauseDuration }
                ScriptAction {
                    script: {
                        finger.y = Dims.h(76)
                        finger.x = Dims.w(43)
                        finger.opacity = 0.8
                    }
                }

                ParallelAnimation {
                    NumberAnimation { target: Desktop.panelsGrid; property: "contentY"; from: -Dims.h(100); to: 0.0; duration: 600 }
                    NumberAnimation { target: finger; property: "y"; from: Dims.h(10); to: Dims.h(76); duration: 600 }
                }
                ScriptAction { script: { Desktop.panelsGrid.currentVerticalPos = 0
                                         Desktop.panelsGrid.animateIndicators()
                                         finger.opacity = 0.0 } }

                ParallelAnimation {
                    OpacityAnimator { target: background;   from: 0.0; to: backgroundOpacity; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 0.0; to: 1.0; duration: opacityAnimDuration }
                }
                ScriptAction { script: nextButton.enabled = true }
            }
        },
        Transition {
            to: "DONE"
            SequentialAnimation {
                ParallelAnimation {
                    OpacityAnimator { target: background;   from: backgroundOpacity; to: 0.0; duration: opacityAnimDuration }
                    OpacityAnimator { target: explanations; from: 1.0; to: 0.0; duration: opacityAnimDuration }
                }
                ScriptAction {
                    script: {
                        firstRun.stopFirstRun()
                        tuto.destroy()
                    }
                }
            }
        }
    ]

    FakeAlarmclock {
        id: fakeAlarmclock
        width: Dims.w(100)
        height: Dims.h(100)
        x: Dims.w(100)
    }

    MouseArea {
        id: eventBlocker
        anchors.fill: parent

        onClicked: ;
        onPressed: ;
        onReleased: ;
        onDoubleClicked: ;
        onPositionChanged: ;
        onPressAndHold: ;
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: backgroundOpacity
    }

    Item {
        id: explanations
        anchors.fill: parent
        opacity: 1.0
        
        Icon {
            id: centerIcon
            width: Dims.l(25)
            height: Dims.l(25)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -Dims.h(15)
        }

        Label {
            id: title
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: centerIcon.bottom
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: subtitle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: title.bottom
            horizontalAlignment: Text.AlignHCenter
        }

        IconButton {
            id: nextButton
            iconName: "ios-arrow-dropright"
            anchors { 
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: Dims.iconButtonMargin
            }
            onClicked: {
                nextButton.enabled = false;
                switch(tuto.state) {
                    case "WELCOME":
                        tuto.state = "INDICATORS";
                        break;
                    case "INDICATORS":
                        tuto.state = "NOTIFICATIONS";
                        break;
                    case "NOTIFICATIONS":
                        tuto.state = "TODAY";
                        break;
                    case "TODAY":
                        tuto.state = "QUICKSETTINGS";
                        break;
                    case "QUICKSETTINGS":
                        tuto.state = "APPLICATIONS";
                        break;
                    case "APPLICATIONS":
                        tuto.state = "STARTAPP";
                        break;
                    case "STARTAPP":
                        tuto.state = "LEAVEAPP";
                        break;
                    case "LEAVEAPP":
                        tuto.state = "ENJOY";
                        break;
                    case "ENJOY":
                        tuto.state = "DONE";
                        break;
                    default:
                        console.log("Tutorial: Unhandled state detected");
                }
            }

            Timer {
                id: longPressTimer
                interval: 2000
                repeat: false
                running: nextButton.pressed
                onTriggered: tuto.state = "DONE";
            }
        }
    }

    Rectangle {
        id: finger
        width: Dims.l(14)
        height: Dims.l(14)
        radius: width/2
        color: "#FFF"
        border.color: "#777"
        border.width: 1
        x: 0
        y: 0
        opacity: 0.0
        Behavior on opacity { OpacityAnimator { duration: 150 } }
    }
}
