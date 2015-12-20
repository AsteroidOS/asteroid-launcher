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
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import org.asteroid.launcher 1.0

Item {
    id: switcherRoot

    property bool closeMode: false
    property bool visibleInHome: false
    property alias runningAppsCount: switcherModel.itemCount
    property var switchModel: switcherModel

    onVisibleInHomeChanged: {
        // Exit close mode when scrolling out of view
        if (!visibleInHome && closeMode) {
            closeMode = false;
        }
    }

    Flickable {
        id: flickable
        contentHeight: gridview.height
        width: parent.width - 10 // see comment re right anchor below

        MouseArea {
            height: flickable.contentHeight > flickable.height ? flickable.contentHeight : flickable.height
            width: flickable.width
            onPressAndHold: closeMode = !closeMode
            onClicked: {
                if (closeMode)
                    closeMode = false
            }
        }

        anchors {
            top: parent.top
            bottom: toolBar.top
            left: parent.left
            // no right anchor to avoid double margin (complicated math)
            margins: 10
        }

        Grid {
            id: gridview
            columns: 2
            spacing: 10
            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                }
            }

            Repeater {
                id: gridRepeater
                model: LauncherWindowModel {
                    id:switcherModel
                }

                delegate: Item {
                    width: (flickable.width - (gridview.spacing * gridview.columns)) / gridview.columns
                    height: width * (desktop.height / desktop.width)

                    // The outer Item is necessary because of animations in SwitcherItem changing
                    // its size, which would break the Grid. 
                    SwitcherItem {
                        id: switcherItem
                        width: parent.width
                        height: parent.height
                    }

                    function close() {
                        switcherItem.close()
                    }
                }
            }
        }
    }

    Rectangle {
        id: toolBar
        color: 'black'
        Rectangle {
            anchors.top   : toolBar.top
            anchors.left  : toolBar.left
            anchors.right : toolBar.right
            height: 1
            color: '#333333'
        }
        z: 202
        height: toolBarDone.height + 2*padding
        property int padding: 3

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: switcherRoot.closeMode ? 0 : -height
        }

        Behavior on anchors.bottomMargin { PropertyAnimation { duration: 100 } }

        Button {
            id: toolBarDone
            width: parent.width / 2.5
            height: 40
            anchors {
                top: parent.top
                topMargin: toolBar.padding
                right: parent.horizontalCenter
                rightMargin: toolBar.padding
            }
            text: 'Done'
            onClicked: {
                switcherRoot.closeMode = false;
            }
            style: ButtonStyle {
                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 8
                    text: control.text
                }
            }
        }

        Button {
            id: toolBarCloseAll
            width: toolBarDone.width
            height: toolBarDone.height
            anchors {
                top: parent.top
                topMargin: toolBar.padding
                left: parent.horizontalCenter
                leftMargin: toolBar.padding
            }
            text: 'Close all'
            onClicked: {
                // TODO: use close animation inside item
                for (var i = gridRepeater.count - 1; i >= 0; i--) {
                    gridRepeater.itemAt(i).close()
                }
            }
            style: ButtonStyle {
                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 8
                    text: control.text
                }
            }
        }
    }

    // Empty switcher indicator
    Label {
        visible: switcherModel.itemCount === 0
        horizontalAlignment: Text.AlignHCenter

        text: "<b>No apps<br>open</b>"
        color: "white"
        font.pointSize: 12
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
    }
}
