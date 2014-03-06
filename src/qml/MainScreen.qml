/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Window 2.1
import org.nemomobile.time 1.0
import org.nemomobile.configuration 1.0

ApplicationWindow {

    // This is used in the favorites page and in the lock screen
    WallClock {
        id: wallClock
        enabled: true /* XXX: Disable when display is off */
        updateFrequency: WallClock.Minute
    }
    // This is used in the lock screen
    ConfigurationValue {
        id: wallpaperSource
        key: desktop.isPortrait ? "/desktop/meego/background/portrait/picture_filename" : "/desktop/meego/background/landscape/picture_filename"
        defaultValue: "images/graphics-wallpaper-home.jpg"
    }
    id: appWindow

    contentOrientation: Screen.orientation

    // Implements back key navigation
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            if (pageStack.depth > 1) {
                pageStack.pop();
                event.accepted = true;
            } else { Qt.quit(); }
        }
    }
    initialPage: Page {
        Item {
            id: desktop
            property bool isPortrait: width < height

            anchors.fill: parent

            // Pager for swiping between different pages of the home screen
            Pager {
                id: pager

                scale: 0.7 + 0.3 * lockScreen.openingState
                opacity: lockScreen.openingState

                anchors.fill: parent

                model: VisualItemModel {
                    AppLauncher {
                        id: launcher
                        height: pager.height
                    }
                    AppSwitcher {
                        id: switcher
                        width: pager.width
                        height: pager.height
                        visibleInHome: x > -width && x < desktop.width
                    }
                }

                // Initial view should be the AppLauncher
                currentIndex: 1
            }
            Lockscreen {
                id: lockScreen

                width: parent.width
                height: parent.height

                z: 200

                onOpeningStateChanged: {
                    // When fully closed, reset the current page
                    if (openingState !== 0)
                        return

                    // Focus the switcher if any applications are running, otherwise the launcher
                    if (switcher.runningAppsCount > 0) {
                        pager.currentIndex = 2
                    } else {
                        pager.currentIndex = 1
                    }
                }
            }
        }
        tools: Item {
            id: toolsLayoutItem

            anchors.fill: parent

            property string title: "Glacier UI"
            property StackView pageStack: findStackView(toolsLayoutItem)

            //XXX: TEMPORARY CODE, MIGHT CAUSE LAG WHEN PUSHING A PAGE ON THE STACK
            function findStackView(startingItem) {
                var myStack = startingItem
                while (myStack) {
                    if (myStack.hasOwnProperty("currentItem") && myStack.hasOwnProperty("initialItem"))
                            return myStack
                    myStack = myStack.parent
                }
                return null
            }

            Rectangle {
                id: backButton
                width: opacity ? 60 : 0
                anchors.left: parent.left
                anchors.leftMargin: 20
                //check if Stack.view has already been initialized as well
                opacity: (pageStack && (pageStack.depth > 1)) ? 1 : 0
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
                height: 60
                radius: 4
                color: backmouse.pressed ? "#222" : "transparent"
                Behavior on opacity { NumberAnimation{} }
                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "images/navigation_previous_item.png"
                }
                MouseArea {
                    id: backmouse
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: pageStack.pop()
                }
            }

            Label {
                font.pixelSize: 42
                Behavior on x { NumberAnimation { easing.type: Easing.OutCubic } }
                x: backButton.x + backButton.width + 20
                anchors.verticalCenter: parent.verticalCenter
                text: parent.title
            }
        }

    }
}
