
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

// App Launcher page
// the place for browsing installed applications and launching them

GridView {
    id: gridview
    cellWidth: 115
    cellHeight: cellWidth + 30
    width: Math.floor(parent.width / cellWidth) * cellWidth
    cacheBuffer: gridview.contentHeight
    property Item reorderItem
    property bool onUninstall
    property alias deleter: deleter

    // just for margin purposes
    header: Item {
        height: 100
    }
    footer: Item {
        height: 100
    }

    Item {
        id: deleter
        anchors.top: parent.top
        property alias remove: remove
        property alias uninstall: uninstall
        Rectangle {
            id: remove
            property alias text: lbl.text
            visible: onUninstall
            height: 110
            color: "red"
            width: gridview.width / 2
            Label {
                id: lbl
                anchors.centerIn: parent
                text: "Remove"
                font.pointSize: 8
            }
        }
        Rectangle {
            id: uninstall
            property alias text: lbl2.text
            anchors.left: remove.right
            visible: onUninstall
            color: "red"
            width: gridview.width / 2
            height: 110
            Label {
                id: lbl2
                anchors.centerIn: parent
                text: "Uninstall"
                font.pointSize: 8
            }
        }
    }

    model: LauncherModel { id: launcherModel }

    delegate: LauncherItemDelegate {
        id: launcherItem
        width: gridview.cellWidth
        height: gridview.cellHeight
        source: model.object.iconId == "" ? ":/images/icons/apps.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
        iconCaption: model.object.title
    }
}
