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
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

ListView {
    id: appsListView
    orientation: ListView.Horizontal
    property bool onUninstall
    property alias deleter: deleter
    property var switcher: null
    snapMode: ListView.SnapToItem
    spacing: -width*0.25

    Item {
        id: deleter
        anchors.top: parent.top
        property alias remove: remove
        property alias uninstall: uninstall
        Rectangle {
            id: remove
            property alias text: removeLabel.text
            visible: onUninstall
            height: 110
            color: "red"
            width: appsListView.width / 2
            Label {
                id: removeLabel
                anchors.centerIn: parent
                text: "Remove"
                font.pointSize: 8
            }
        }
        Rectangle {
            id: uninstall
            property alias text: uninstallLabel.text
            anchors.left: remove.right
            visible: onUninstall
            color: "red"
            width: appsListView.width / 2
            height: 110
            Label {
                id: uninstallLabel
                anchors.centerIn: parent
                text: "Uninstall"
                font.pointSize: 8
            }
        }
    }

    model: LauncherFolderModel { id: launcherModel }

    delegate: LauncherItemDelegate {
        id: launcherItem
        width: appsListView.width
        height: appsListView.width
        source: model.object.iconId == "" ? ":/images/icons/apps.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
        iconCaption: model.object.title
    }

    Label {
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
